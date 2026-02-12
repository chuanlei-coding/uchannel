import 'package:flutter/widgets.dart';

/// 应用间距常量
///
/// 统一管理应用中的间距值，保持一致性
class Spacing {
  Spacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // EdgeInsets 预设
  static const allXS = EdgeInsets.all(xs);
  static const allSM = EdgeInsets.all(sm);
  static const allMD = EdgeInsets.all(md);
  static const allLG = EdgeInsets.all(lg);
  static const allXL = EdgeInsets.all(xl);

  static const horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const verticalMD = EdgeInsets.symmetric(vertical: md);
  static const verticalLG = EdgeInsets.symmetric(vertical: lg);

  static const onlyTopMD = EdgeInsets.only(top: md);
  static const onlyBottomMD = EdgeInsets.only(bottom: md);
}
