import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/animations.dart';
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
import 'widgets/page_transitions.dart';

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

/// 路由配置
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // 启动页 - 淡入淡出
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionDuration: AppAnimations.fadeTransition,
        transitionsBuilder: PageTransitions.fadeTransition,
      ),
    ),
    // 聊天页 - 小红书风格
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: ChatScreen()),
        transitionDuration: AppAnimations.pageTransition,
        transitionsBuilder: PageTransitions.xiaohongshuTransition,
      ),
    ),
    // 日程页 - 小红书风格
    GoRoute(
      path: '/schedule',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: ScheduleScreen()),
        transitionDuration: AppAnimations.pageTransition,
        transitionsBuilder: PageTransitions.xiaohongshuTransition,
      ),
    ),
    // 发现页 - 小红书风格
    GoRoute(
      path: '/discover',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: DiscoverScreen()),
        transitionDuration: AppAnimations.pageTransition,
        transitionsBuilder: PageTransitions.xiaohongshuTransition,
      ),
    ),
    // 统计页 - 小红书风格
    GoRoute(
      path: '/stats',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: StatsScreen()),
        transitionDuration: AppAnimations.pageTransition,
        transitionsBuilder: PageTransitions.xiaohongshuTransition,
      ),
    ),
    // 设置页 - 小红书风格
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SwipeablePage(child: SettingsScreen()),
        transitionDuration: AppAnimations.pageTransition,
        transitionsBuilder: PageTransitions.xiaohongshuTransition,
      ),
    ),
    // 添加任务页 - 模态框底部滑入
    GoRoute(
      path: '/add-todo',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AddTodoScreen(),
        transitionDuration: AppAnimations.modalTransition,
        transitionsBuilder: PageTransitions.slideUpTransition,
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
