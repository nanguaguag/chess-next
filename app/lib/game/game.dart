import 'package:flutter/material.dart';

import '../config/local_data.dart';

// Channels
const kChannelCommon = 'Common';
const kChannelMainland = 'Mainland';
const kChannelCurrent = kChannelMainland;

enum GameScene {
  unknown,
  battle,
  gameNotation,
}

bool isVs(GameScene scene) => true;

class GameColors {
  //
  static const primary = Color(0xFF461220);
  static const boardBackground = Color(0xFFEBC38D);
  static const boardLine = Color(0x996D000D);
  static const boardTips = Color(0x666D000D);
}

class BoardTheme {
  //
  static const defaultTheme = BoardTheme();
  static const highContrastTheme = BoardTheme(
    blackPieceColor: Colors.black,
    blackPieceTextColor: Colors.white,
    redPieceColor: Colors.white,
    redPieceTextColor: Colors.black,
  );

  final Color focusPoint, blurPoint;
  final Color blackPieceColor, blackPieceBorderColor;
  final Color redPieceColor, redPieceBorderColor;
  final Color blackPieceTextColor, redPieceTextColor;

  const BoardTheme({
    this.focusPoint = const Color(0xCCFF8B00),
    this.blurPoint = const Color(0xCCFF8B00),
    this.blackPieceColor = const Color(0xFF222222),
    this.blackPieceBorderColor = const Color(0xFFFF8B00),
    this.redPieceColor = const Color(0xFF7B0000),
    this.redPieceBorderColor = const Color(0xFFFF8B00),
    this.blackPieceTextColor = const Color(0xCCFFFFFF),
    this.redPieceTextColor = const Color(0xCCFFFFFF),
  });
}

class GameFonts {
  //
  static TextStyle ui({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontFamily: LocalData().uiFont.value,
      height: height,
    );
  }

  static TextStyle art({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontFamily: LocalData().artFont.value,
      height: height,
    );
  }

  static TextStyle artForce({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontFamily: LocalData().artFont.value,
      height: height,
    );
  }
}
