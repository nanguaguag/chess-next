import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../game/game.dart';
import 'board/thinking_board_widget.dart';
import 'ruler.dart';

const _paddingH = 10.0;

double _additionPaddingH = 0;

Widget createChessBoard(BuildContext context, GameScene scene,
    {Function(BuildContext, int)? onBoardTap, bool opponentHuman = false}) {
  //
  // 当屏幕的纵横比小于16/9时，限制棋盘的宽度
  final windowSize = MediaQuery.of(context).size;
  double height = windowSize.height, width = windowSize.width;

  if (height / width < Ruler.kProperAspectRatio) {
    width = height / Ruler.kProperAspectRatio;
    _additionPaddingH = (windowSize.width - width) / 2 + Ruler.kBoardMargin;
  }

  final boardWidget = ThinkingBoardWidget(
    width - _paddingH * 2,
    onBoardTap,
    opponentHuman: opponentHuman,
  );

  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: _additionPaddingH,
      vertical: Ruler.kBoardMargin,
    ),
    child: boardWidget,
  );
}

double boardPaddingH(BuildContext context) {
  //
  // 当屏幕的纵横比小于16/9时，限制棋盘的宽度
  final windowSize = MediaQuery.of(context).size;
  double height = windowSize.height, width = windowSize.width;

  if (height / width < Ruler.kProperAspectRatio) {
    width = height / Ruler.kProperAspectRatio;
  }

  return (windowSize.width - (width - _paddingH * 2)) / 2;
}

String titleFor(BuildContext context, GameScene scene) {
  //
  switch (scene) {
    //
    case GameScene.battle:
      return '人机练习';

    case GameScene.gameNotation:
      return '我的对局';

    case GameScene.unknown:
      break;
  }

  throw 'Scene is node define.';
}

void drawText(
  Canvas canvas,
  String text,
  TextStyle textStyle, {
  Offset? centerLocation,
  Offset? startLocation,
  Offset? endLocation,
}) {
  //
  final textSpan = TextSpan(text: text, style: textStyle);
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  )..layout();

  if (startLocation != null) {
    textPainter.paint(canvas, startLocation);
    return;
  }

  final textSize = textPainter.size;

  if (endLocation != null) {
    textPainter.paint(canvas, endLocation - Offset(textSize.width, 0));
    return;
  }

  if (centerLocation != null) {
    //
    final metric = textPainter.computeLineMetrics()[0];

    // 从顶上算，文字的 Baseline 在 2/3 高度线上
    final textOffset = centerLocation -
        Offset(
          textSize.width / 2,
          metric.baseline - textSize.height / 3 + 1,
        );

    textPainter.paint(canvas, textOffset);
  }
}
