import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/settings_service.dart';
import 'services/chat_service.dart';
import 'screens/splash_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_todo_screen.dart';
import 'widgets/swipeable_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化设置服务
  final settingsService = SettingsService();
  await settingsService.init();

  // 初始化聊天服务
  final chatService = ChatService();
  await chatService.init();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFDFBF7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(VitaApp(
    settingsService: settingsService,
    chatService: chatService,
  ));
}

/// iOS 风格的页面转场动画配置
/// 实现类似微信的平行滑动效果：新页面从右侧滑入，旧页面同时向左推移
class PageTransitionUtils {
  /// Push 转场 - iOS/微信风格平行滑动
  /// 新页面从右侧滑入，旧页面向左推移并变暗
  static Widget pushTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 使用 iOS 标准的缓动曲线
    const curve = Curves.easeInOut;
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), // 从屏幕右侧外开始
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    );
  }

  /// 用于旧页面的转场 - 向左推移并变暗
  /// 这是 iOS 导航的关键特性：两个页面同时移动
  static Widget pushTransitionBackground(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOut;
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    // 旧页面向左移动 30% 并变暗
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.3, 0.0),
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 1.0,
          end: 0.8,
        ).animate(curvedAnimation),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Modal 转场 - 从底部滑入（用于添加任务弹窗）
  static Widget modalTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeOutCubic;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0), // 从屏幕底部外开始
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: curve),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Modal 转场的背景遮罩效果
  static Widget modalTransitionBackground(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 0.5).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
        ),
        child: child,
      ),
    );
  }

  /// Fade 转场 - 用于首页
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
      ),
      child: child,
    );
  }
}

/// 路由配置
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: PageTransitionUtils.fadeTransition,
      ),
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: ChatScreen()),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: PageTransitionUtils.pushTransition,
        // 同时移动背景页面
        reverseTransitionDuration: const Duration(milliseconds: 280),
      ),
    ),
    GoRoute(
      path: '/schedule',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: ScheduleScreen()),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: PageTransitionUtils.pushTransition,
      ),
    ),
    GoRoute(
      path: '/discover',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: DiscoverScreen()),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: PageTransitionUtils.pushTransition,
      ),
    ),
    GoRoute(
      path: '/stats',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: StatsScreen()),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: PageTransitionUtils.pushTransition,
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: SettingsScreen()),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: PageTransitionUtils.pushTransition,
      ),
    ),
    GoRoute(
      path: '/add-todo',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AddTodoScreen(),
        transitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: PageTransitionUtils.modalTransition,
      ),
    ),
  ],
);

/// Vita 应用主入口
class VitaApp extends StatelessWidget {
  final SettingsService settingsService;
  final ChatService chatService;

  const VitaApp({
    super.key,
    required this.settingsService,
    required this.chatService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider.value(value: chatService),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp.router(
            title: 'Vita',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
