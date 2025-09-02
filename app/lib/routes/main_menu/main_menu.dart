import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../game/game.dart';
import '../battle/battle_page.dart';
import '../saved_manuals.dart';
import 'readme.dart';

class MainMenu extends StatefulWidget {
  //
  const MainMenu({Key? key}) : super(key: key);

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  //
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //
    final ButtonStyle menuBtnStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.all(20)),
    );
    Widget buildActionCtrls() {
      return Expanded(
        flex: 4,
        child: Column(
          children: [
            TextButton(
              style: menuBtnStyle,
              child: Text(
                '人机练习',
                style: TextStyle(fontSize: 25),
              ),
              onPressed: () => navigateTo(GameScene.battle),
            ),
            const Expanded(child: SizedBox()),
            TextButton(
              style: menuBtnStyle,
              child: Text(
                '我的对局',
                style: TextStyle(fontSize: 25),
              ),
              onPressed: () => navigateTo(GameScene.gameNotation),
            ),
            const Expanded(child: SizedBox()),
            TextButton(
              style: menuBtnStyle,
              child: Text(
                '版本说明',
                style: TextStyle(fontSize: 25),
              ),
              onPressed: () => showReadme(context),
            ),
            const Expanded(flex: 4, child: SizedBox()),
          ],
        ),
      );
    }

    final mainEntries = Center(
      child: Column(
        children: <Widget>[
          const Expanded(flex: 2, child: SizedBox()),
          buildActionCtrls(),
          const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          mainEntries,
        ],
      ),
    );
  }

  navigateTo(GameScene scene) async {
    //
    Widget page;

    switch (scene) {
      case GameScene.battle:
        page = const BattlePage();
        break;

      case GameScene.gameNotation:
        page = const SavedManuals();
        break;

      case GameScene.unknown:
        throw 'Scene is not define.';
    }

    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => page),
    );
  }
}
