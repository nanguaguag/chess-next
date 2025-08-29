import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../ui/snack_bar.dart';

showReadme(BuildContext context) {
  //
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Chess-Next'),
      content: Linkify(
        text: '这里是Chess-Next象棋！\n\n'
            '使用了目前棋力最强的开源引擎 - 皮卡鱼\n\n'
            '祝您体验愉快~',
      ),
      actions: <Widget>[
        TextButton(
          child: Text('知道了'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

Future<void> openLink(String url, BuildContext context) async {
  //
  bool success;
  try {
    success = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    success = false;
  }

  if (!success) {
    Clipboard.setData(ClipboardData(text: url));
    showSnackBar('链接已复制到剪贴板！');
  }
}
