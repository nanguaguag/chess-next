import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ffi/ffi.dart';

DynamicLibrary _openLibpikafish() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libpikafish.so');
  } else if (Platform.isMacOS) {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    // exeDir 通常是 chessroad.app/Contents/MacOS
    final libPath = p.join(exeDir, '../Resources', 'libpikafish.dylib');
    return DynamicLibrary.open(libPath);
  } else {
    throw UnsupportedError('Unsupported platform');
  }
}

final DynamicLibrary _nativeLib = _openLibpikafish(); // 你的实现保持不变

// int pikafish_init();
final int Function() nativeInit = _nativeLib
    .lookup<NativeFunction<Int32 Function()>>('pikafish_init')
    .asFunction();

// int pikafish_shutdown();
final int Function() nativeShutdown = _nativeLib
    .lookup<NativeFunction<Int32 Function()>>('pikafish_shutdown')
    .asFunction();

// ssize_t pikafish_send(const char *);  -> returns number bytes written (intptr)
final int Function(Pointer<Utf8>) nativeSend = _nativeLib
    .lookup<NativeFunction<IntPtr Function(Pointer<Utf8>)>>('pikafish_send')
    .asFunction();

// char* pikafish_poll();  -> returns NULL if no line available
final Pointer<Utf8> Function() nativePoll = _nativeLib
    .lookup<NativeFunction<Pointer<Utf8> Function()>>('pikafish_poll')
    .asFunction();

// void pikafish_free(char*);
final void Function(Pointer<Void>) nativeFree = _nativeLib
    .lookup<NativeFunction<Void Function(Pointer<Void>)>>('pikafish_free')
    .asFunction();
