import 'package:flutter/painting.dart';

/// 应用圆角常量
///
/// 统一管理应用中的圆角半径，保持一致性
class AppBorderRadius {
  AppBorderRadius._();

  // 圆角半径值
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double full = 999.0;

  // BorderRadius 预设
  static const allXS = BorderRadius.all(Radius.circular(xs));
  static const allSM = BorderRadius.all(Radius.circular(sm));
  static const allMD = BorderRadius.all(Radius.circular(md));
  static const allLG = BorderRadius.all(Radius.circular(lg));
  static const allXL = BorderRadius.all(Radius.circular(xl));
  static const allXXL = BorderRadius.all(Radius.circular(xxl));
  static const allXXXL = BorderRadius.all(Radius.circular(xxxl));
  static const allFull = BorderRadius.all(Radius.circular(full));

  // 仅顶部圆角
  static const topLG = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
  static const topXL = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static const topXXL = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  // 仅底部圆角
  static const bottomLG = BorderRadius.vertical(
    bottom: Radius.circular(lg),
  );
  static const bottomXL = BorderRadius.vertical(
    bottom: Radius.circular(xl),
  );

  // 仅左侧圆角
  static const leftLG = BorderRadius.horizontal(
    left: Radius.circular(lg),
  );

  // 仅右侧圆角
  static const rightLG = BorderRadius.horizontal(
    right: Radius.circular(lg),
  );

  // 根据用途命名的圆角
  /// 按钮圆角
  static const button = allFull;

  /// 卡片圆角
  static const card = allLG;

  /// 模态框圆角
  static const modal = allXXL;

  /// 输入框圆角
  static const input = allFull;

  /// 图标按钮圆角
  static const iconButton = allLG;

  /// 标签圆角
  static const tag = allSM;

  /// 头像圆角
  static const avatar = allFull;
}

/// 圆角扩展方法
extension BorderRadiusExtension on BorderRadius {
  /// 复制并修改所有圆角半径
  BorderRadius copyWith({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? this.topLeft.x),
      topRight: Radius.circular(topRight ?? this.topRight.x),
      bottomLeft: Radius.circular(bottomLeft ?? this.bottomLeft.x),
      bottomRight: Radius.circular(bottomRight ?? this.bottomRight.x),
    );
  }
}
