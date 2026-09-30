import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Newer Android draws apps edge-to-edge, which slid screens under the
/// status bar and the bottom bars under the system nav buttons. The whole
/// app now lives inside the safe area ([safeAppFrame], applied in
/// `MaterialApp.builder`); the strips behind the system bars stay white
/// with dark icons.
const systemBarsStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
);

Widget safeAppFrame(Widget child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarsStyle,
      child: ColoredBox(color: Colors.white, child: SafeArea(child: child)),
    );
