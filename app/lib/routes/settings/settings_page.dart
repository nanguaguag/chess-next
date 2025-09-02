import 'dart:io';

import 'package:chessroad/engine/hybrid_engine.dart';
import 'package:chessroad/routes/main_menu/privacy_policy.dart';
import 'package:chessroad/ui/review_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/local_data.dart';
import '../../services/audios.dart';
import '../../ui/snack_bar.dart';
import 'pikafish_params_page.dart';
import 'show_about.dart';

class SettingsPage extends StatefulWidget {
  //
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  //
  int _titleClicked = 0;

  updateLoginState(bool _) {
    if (mounted) setState(() {});
  }

  changeEngineConfig() async {
    //
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const PikafishParamsPage()),
    );

    await HybridEngine().applyNativeEngineConfig();
  }

  switchCloudEngine(bool value) async {
    //
    setState(() => LocalData().cloudEngineEnabled.value = value);
    LocalData().save();
  }

  switchThinkingArrow(bool value) async {
    //
    setState(() => LocalData().thinkingArrowEnabled.value = value);
    LocalData().save();
  }

  switchMusic(bool value) async {
    //
    setState(() => LocalData().bgmEnabled.value = value);

    if (LocalData().bgmEnabled.value) {
      Audios.loopBgm();
    } else {
      Audios.stopBgm();
    }
    LocalData().save();
  }

  switchTone(bool value) async {
    //
    setState(() => LocalData().toneEnabled.value = value);
    LocalData().save();
  }

  switchHighContrast(bool value) async {
    //
    setState(() => LocalData().highContrast.value = value);
    LocalData().save();
  }

  changeFont() {
    //
    callback(String? fontFamily) async {
      //
      Navigator.of(context).pop();
      setState(() {
        LocalData().artFont.value = fontFamily!;
      });
      LocalData().save();
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            RadioListTile(
              title: const Text('小隶'),
              groupValue: LocalData().artFont.value as String,
              value: 'XiaoLi',
              onChanged: callback,
            ),
            const Divider(),
            RadioListTile(
              title: const Text('中山体'),
              groupValue: LocalData().artFont.value as String,
              value: 'ZhongSan',
              onChanged: callback,
            ),
            const Divider(),
            RadioListTile(
              title: const Text('启体'),
              groupValue: LocalData().artFont.value as String,
              value: 'QiTi',
              onChanged: callback,
            ),
            const Divider(),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //
    final TextStyle headerStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            Text('引擎设置', style: headerStyle),
            const SizedBox(height: 10.0),
            Card(
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    value: LocalData().cloudEngineEnabled.value,
                    title: Text('启用云库'),
                    onChanged: switchCloudEngine,
                  ),
                  _buildDivider(),
                  ListTile(
                    title: Text('皮卡鱼参数'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text('配置'),
                        Icon(Icons.keyboard_arrow_right),
                      ],
                    ),
                    onTap: changeEngineConfig,
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    value: LocalData().thinkingArrowEnabled.value,
                    title: Text('引擎思考箭头'),
                    onChanged: switchThinkingArrow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('声音', style: headerStyle),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    value: LocalData().bgmEnabled.value,
                    title: Text('背景音乐'),
                    onChanged: switchMusic,
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    value: LocalData().toneEnabled.value,
                    title: Text('提示音效'),
                    onChanged: switchTone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Text('棋盘', style: headerStyle),
            const SizedBox(height: 10.0),
            Card(
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('字体'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          LocalData().artFont.value == 'QiTi'
                              ? '启体'
                              : LocalData().artFont.value == 'ZhongSan'
                                  ? '中山体'
                                  : '小隶',
                        ),
                        const Icon(Icons.keyboard_arrow_right),
                      ],
                    ),
                    onTap: changeFont,
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    value: LocalData().highContrast.value,
                    title: Text('使用强对比色'),
                    onChanged: switchHighContrast,
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: clickAboutTitle,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: WidgetStateProperty.all(Colors.transparent),

                // 关键点：用主题里的颜色，而不是写死
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context).colorScheme.primary; // 点击时高亮
                    }
                    return Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color; // 正常文本颜色
                  },
                ),

                textStyle: WidgetStateProperty.all(
                  Theme.of(context).textTheme.bodyMedium, // 跟随系统字体大小/颜色
                ),
              ),
              child: Text('关于', style: headerStyle),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  if (Platform.isIOS)
                    ListTile(
                      title: Text('五星好评'),
                      trailing: const Icon(
                        Icons.keyboard_arrow_right,
                      ),
                      onTap: () => ReviewPanel.popRequest(force: true),
                    ),
                  if (Platform.isIOS) _buildDivider(),
                  ListTile(
                    title: Text('隐私政策'),
                    trailing: const Icon(
                      Icons.keyboard_arrow_right,
                    ),
                    onTap: () => openPrivacyPolicy(context),
                  ),
                  _buildDivider(),
                  ListTile(
                    title: Text('关于'),
                    trailing: const Icon(
                      Icons.keyboard_arrow_right,
                    ),
                    onTap: () => showAbout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60.0),
          ],
        ),
      ),
    );
  }

  Container _buildDivider() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        height: 1.0,
      );

  @override
  void dispose() {
    super.dispose();
  }

  void clickAboutTitle() {
    //
    _titleClicked++;

    if (_titleClicked >= 5) {
      //
      LocalData().debugMode.value = !LocalData().debugMode.value;

      _titleClicked = 0;

      showSnackBar('DebugMode: ${LocalData().debugMode.value}');
    }
  }
}
