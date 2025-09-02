import 'dart:io';

import 'package:chessroad/engine/hybrid_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:chessroad/config/local_data.dart';
import 'package:chessroad/routes/main_menu/privacy_policy.dart';

import '../../ad/ad.dart';
import 'game/board_state.dart';
import 'game/page_state.dart';
import 'routes/main_menu/main_menu.dart';
import 'routes/settings/settings_page.dart';
import 'services/audios.dart';

void main() async {
  //
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ChessRoadApp());

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  if (Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: []);
  }
}

class ChessRoadApp extends StatefulWidget {
  //
  static final navKey = GlobalKey<NavigatorState>();
  static get context => navKey.currentContext;

  const ChessRoadApp({Key? key}) : super(key: key);

  @override
  ChessRoadAppState createState() => ChessRoadAppState();
}

class ChessRoadAppState extends State<ChessRoadApp>
    with WidgetsBindingObserver {
  //
  int _selectedIndex = 0;
  bool _waitingInit = true;

  @override
  void initState() {
    //
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();

    initAsync();
  }

  // 两个页面对应底部导航栏
  final List<Widget> _screens = [
    MainMenu(),
    SettingsPage(),
  ];

  Future<void> initAsync() async {
    //
    await LocalData().load();

    if (!mounted) return;

    await Ad.instance.init();

    Audios.init();

    await HybridEngine().startup();

    setState(() => _waitingInit = false);

    Audios.loopBgm();
  }

  Future<void> startSplashAd(bool newUser) async {
    //
    if (!newUser) {
      //
      int counterDown = 30;

      while ((!mounted || !Ad.instance.initCompleted) && counterDown > 0) {
        await Future.delayed(const Duration(milliseconds: 100));
        counterDown--;
      }

      if (counterDown > 0 && mounted) {
        await Ad.instance.showSplashVideo(context);
      }
    }
  }

  // 在依赖变化或首次插入 widget 树时调用
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_waitingInit == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!LocalData().acceptedPrivacyPolicy.value) {
          await openPrivacyPolicy(context);
        }
      });
    }
  }

  String charRepeat(String ch, int times) {
    //
    var result = '';

    for (var i = 0; i < times; i++) {
      result += ch;
    }

    return result;
  }

  Widget getMainApp() {
    if (_waitingInit) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "首页",
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: "设置",
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BoardState>(create: (_) => BoardState()),
        ChangeNotifierProvider<PageState>(create: (_) => PageState()),
      ],
      child: MaterialApp(
        navigatorKey: ChessRoadApp.navKey,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.system, // 暗黑模式跟随系统
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        home: getMainApp(),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        WakelockPlus.enable();
        Audios.loopBgm();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        Audios.stopBgm();
        HybridEngine().stop();
        WakelockPlus.disable();
        break;
      case AppLifecycleState.detached:
        Audios.release();
        WakelockPlus.disable();
        HybridEngine().shutdown();
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
