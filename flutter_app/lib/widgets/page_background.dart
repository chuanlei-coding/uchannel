import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 页面背景装饰组件
///
/// 提供统一的圆形色块背景装饰，支持配置位置和颜色
class PageBackground extends StatelessWidget {
  /// 左上角圆形配置
  final BackgroundCircle? topLeft;

  /// 右上角圆形配置
  final BackgroundCircle? topRight;

  /// 左下角圆形配置
  final BackgroundCircle? bottomLeft;

  /// 右下角圆形配置
  final BackgroundCircle? bottomRight;

  const PageBackground({
    super.key,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  /// 默认背景装饰 - 左上和右下
  factory PageBackground.defaultDecorations({Key? key}) {
    return PageBackground(
      key: key,
      topLeft: BackgroundCircle(
        widthFactor: 0.5,
        heightFactor: 0.5,
        color: AppColors.brandSage,
        alpha: 0.05,
      ),
      bottomRight: BackgroundCircle(
        widthFactor: 0.4,
        heightFactor: 0.4,
        color: AppColors.brandTeal,
        alpha: 0.05,
      ),
    );
  }

  /// 对称背景装饰 - 左上和左下
  factory PageBackground.leftAligned({Key? key}) {
    return PageBackground(
      key: key,
      topLeft: BackgroundCircle(
        widthFactor: 0.5,
        heightFactor: 0.4,
        color: AppColors.brandSage,
        alpha: 0.05,
      ),
      bottomLeft: BackgroundCircle(
        widthFactor: 0.4,
        heightFactor: 0.3,
        color: AppColors.brandTeal,
        alpha: 0.05,
      ),
    );
  }

  /// 完整背景装饰 - 四个角落
  factory PageBackground.full({Key? key}) {
    return PageBackground(
      key: key,
      topLeft: BackgroundCircle(
        widthFactor: 0.5,
        heightFactor: 0.5,
        color: AppColors.brandSage,
        alpha: 0.1,
      ),
      bottomRight: BackgroundCircle(
        widthFactor: 0.5,
        heightFactor: 0.5,
        color: AppColors.brandTeal,
        alpha: 0.1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        if (topLeft != null) _buildCircle(topLeft!, screenSize, -1, -1),
        if (topRight != null) _buildCircle(topRight!, screenSize, 1, -1),
        if (bottomLeft != null) _buildCircle(bottomLeft!, screenSize, -1, 1),
        if (bottomRight != null) _buildCircle(bottomRight!, screenSize, 1, 1),
      ],
    );
  }

  Widget _buildCircle(
    BackgroundCircle circle,
    Size screenSize,
    int horizontalDirection,
    int verticalDirection,
  ) {
    final width = screenSize.width * circle.widthFactor;
    final height = screenSize.height * circle.heightFactor;

    return Positioned(
      top: verticalDirection == -1
          ? -screenSize.height * 0.1
          : screenSize.height * 0.1,
      left: horizontalDirection == -1
          ? -screenSize.width * 0.1
          : null,
      right: horizontalDirection == 1
          ? -screenSize.width * 0.1
          : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circle.color.withValues(alpha: circle.alpha),
        ),
      ),
    );
  }
}

/// 背景圆形配置
class BackgroundCircle {
  final double widthFactor;
  final double heightFactor;
  final Color color;
  final double alpha;

  const BackgroundCircle({
    required this.widthFactor,
    required this.heightFactor,
    required this.color,
    this.alpha = 0.05,
  });
}
