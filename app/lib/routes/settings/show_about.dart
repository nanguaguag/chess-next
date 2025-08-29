import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../ui/snack_bar.dart';

showAbout(BuildContext context) async {
  //
  final packageInfo = await PackageInfo.fromPlatform();
  final version = '${packageInfo.version} (${packageInfo.buildNumber})';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text(
        '关于 Chess-Next ',
        style: TextStyle(fontSize: 25),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 5),
          const Text('版本'),
          Text(version),
          const SizedBox(height: 15),
          const Text('QQ 群（招募中）'),
          Linkify(
            onOpen: (link) {
              Clipboard.setData(const ClipboardData(text: '1058552094'));
              showSnackBar('群号已复制！');
            },
            text: 'http://1058552094',
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
