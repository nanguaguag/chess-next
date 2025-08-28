// pikafish.dart (适配新版 FFI)
import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:io' show sleep;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:chessroad/common/prt.dart';

import 'ffi.dart';
import 'pikafish_state.dart';

/// A wrapper for C++ engine (adapted to new C API).
class Pikafish {
  final Completer<Pikafish>? completer;

  final _state = _PikafishState();

  final _stdoutController = StreamController<String>.broadcast();

  final _stdoutPort = ReceivePort();

  late StreamSubscription _stdoutSubscription;

  Isolate? _stdoutIsolate;

  Pikafish._({this.completer}) {
    // Listen to messages from polling isolate (stdout lines)
    _stdoutSubscription = _stdoutPort.listen((message) {
      if (message is String) {
        _stdoutController.sink.add(message);
      } else {
        prt('[pikafish] The stdout isolate sent non-string: $message');
      }
    });

    // Start initialization asynchronously
    _startEngineAndSpawnPoller().then(
      (success) {
        final state = success ? PikafishState.ready : PikafishState.error;
        _state._setValue(state);
        if (state == PikafishState.ready) {
          completer?.complete(this);
        } else {
          completer?.completeError(StateError('pikafish init failed'));
        }
      },
      onError: (e) {
        prt('[pikafish] init failed: $e');
        _state._setValue(PikafishState.error);
        completer?.completeError(e);
      },
    );
  }

  static Pikafish? _instance;

  /// Create instance (single-instance enforced)
  factory Pikafish() {
    if (_instance != null) {
      throw StateError('Multiple instances are not supported, yet.');
    }
    _instance = Pikafish._();
    return _instance!;
  }

  /// The current state of the underlying C++ engine.
  ValueListenable<PikafishState> get state => _state;

  /// The standard output stream.
  Stream<String> get stdout => _stdoutController.stream;

  /// Send a line to engine stdin.
  set stdin(String line) {
    final stateValue = _state.value;
    if (stateValue != PikafishState.ready) {
      throw StateError('Pikafish is not ready ($stateValue)');
    }

    prt('engine=< $line');

    final ptr = line.toNativeUtf8();
    try {
      nativeSend(ptr);
    } finally {
      calloc.free(ptr);
    }
  }

  /// Stops the C++ engine and cleans up resources.
  /// This will send "quit" and call nativeShutdown, then stop the poller isolate.
  Future<void> dispose() async {
    // send quit
    try {
      final qptr = 'quit'.toNativeUtf8();
      nativeSend(qptr);
      calloc.free(qptr);
    } catch (e) {
      prt('[pikafish] error sending quit: $e');
    }

    // ask native to shutdown (blocks until native threads join)
    try {
      nativeShutdown();
    } catch (e) {
      prt('[pikafish] nativeShutdown error: $e');
    }

    // stop and kill the polling isolate (it loops forever otherwise)
    if (_stdoutIsolate != null) {
      try {
        _stdoutIsolate!.kill(priority: Isolate.immediate);
      } catch (e) {
        prt('[pikafish] kill stdout isolate error: $e');
      }
      _stdoutIsolate = null;
    }

    // cleanup stream and port
    await _stdoutSubscription.cancel();
    _stdoutPort.close();
    await _stdoutController.close();

    _state._setValue(PikafishState.disposed);
    _instance = null;
  }

  /// Internal: init native and spawn polling isolate
  Future<bool> _startEngineAndSpawnPoller() async {
    // 1) init native engine (this starts engine thread on native side)
    final initResult = nativeInit();
    if (initResult != 0) {
      prt('[pikafish] nativeInit returned $initResult');
      return false;
    }

    // 2) spawn polling isolate
    try {
      // The entrypoint expects a SendPort
      final sp = _stdoutPort.sendPort;
      _stdoutIsolate = await Isolate.spawn<_PollerInitData>(
        _isolateStdoutEntry,
        _PollerInitData(sp),
        // use paused: false default
      );
    } catch (e) {
      prt('[pikafish] Failed to spawn stdout isolate: $e');
      // if spawn failed we should call nativeShutdown to cleanup
      try {
        nativeShutdown();
      } catch (_) {}
      return false;
    }

    return true;
  }
}

/// Data wrapper for isolate entry (keeps it stable typing)
class _PollerInitData {
  final SendPort stdoutPort;
  _PollerInitData(this.stdoutPort);
}

/// Polling isolate entrypoint (top-level). It loops calling nativePoll(),
/// sends back strings via stdoutPort, and sleeps briefly when no data.
void _isolateStdoutEntry(_PollerInitData data) {
  final SendPort stdoutPort = data.stdoutPort;

  // We have to import sleep from dart:io (synchronous) here.
  // Note: this isolate will be killed by the main isolate on dispose.
  while (true) {
    try {
      final ptr = nativePoll();
      if (ptr.address != 0) {
        final s = ptr.cast<Utf8>().toDartString();
        // free native string
        nativeFree(ptr as Pointer<Void>);
        // send back to main isolate
        stdoutPort.send(s);
      } else {
        // no data available right now
        // sleep a short while to avoid busy spin
        sleep(Duration(milliseconds: 10));
      }
    } catch (e) {
      // If any unexpected error happens, send a message (optional) and terminate
      stdoutPort.send('[pikafish] stdout poll isolate error: $e');
      return;
    }
  }
}

/// Internal state helper
class _PikafishState extends ChangeNotifier
    implements ValueListenable<PikafishState> {
  PikafishState _value = PikafishState.starting;

  @override
  PikafishState get value => _value;

  _setValue(PikafishState v) {
    if (_value == v) return;
    _value = v;
    notifyListeners();
  }
}
