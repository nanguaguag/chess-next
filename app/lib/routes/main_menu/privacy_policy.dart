import 'dart:io';

import 'package:flutter/material.dart';
import '../../config/local_data.dart';

Future openPrivacyPolicy(BuildContext context) async {
  //
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('隐私政策', style: TextStyle(fontSize: 25)),
      content: SingleChildScrollView(
        child: Text(
          '我们的应用可能访问你的剪贴板，'
          '主要目的是从剪贴板读取你从其它象棋 App 里面复制的 FEN 局面记录，'
          '方便你快速地在我们的应用中进行局面分析。\n\n'
          '此外，为了方便你在关于中复制我们的 QQ 群号，我们也会设置剪贴板内容。\n\n'
          '我们尊重并保护所有使用服务用户的个人隐私权，'
          '并会按照本隐私权政策的规定使用您的个人信息。\n\n'
          '我们将以高度的勤勉、审慎义务对待这些信息。必要的时候我们会更新本隐私权政策。'
          '您可以要求我们抹除所有关于您的个人数据，'
          '包括并不限于您的设备信息、操作日志等。\n\n'
          '如果同意，请点击「同意」按钮！',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('拒绝'),
          onPressed: () async {
            LocalData().acceptedPrivacyPolicy.value = false;
            await LocalData().save();
            exit(0);
          },
        ),
        TextButton(
          child: const Text('同意'),
          onPressed: () async {
            Navigator.of(context).pop();
            LocalData().acceptedPrivacyPolicy.value = true;
            await LocalData().save();
          },
        )
      ],
    ),
  );
}
