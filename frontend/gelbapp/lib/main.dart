import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'pages/friends_page.dart';
import 'pages/statistics_page.dart';
import 'pages/profile_page.dart';
import 'pages/create_lobby_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'widgets/protected_page.dart';
import 'services/handle_reload.dart';
import 'pages/play_page.dart';
import 'services/version_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
  ReloadHandler().init();
  WidgetsBinding.instance.addPostFrameCallback((_) {
  checkForUpdateAndShow();
});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'GelbApp',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFEDD37),
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic>? _getRoute(RouteSettings settings) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('Navigator', navigatorKey.currentContext.toString());
    });
    switch (settings.name) {
      // Routes without animation:
      case '/':
        return _noAnimationRoute(ProtectedPage(child: HomePage()), settings);
      case '/friends':
        return _noAnimationRoute(ProtectedPage(child: FriendsPage()), settings);
      case '/statistics':
        return _noAnimationRoute(ProtectedPage(child: StatisticsPage()), settings);
      case '/profile':
        return _noAnimationRoute(ProtectedPage(child: ProfilePage()), settings);

      // Routes with default animation:
    case '/create_lobby':
      return MaterialPageRoute(
        builder: (_) => ProtectedPage(child: CreateLobbyPage()),
        settings: settings,
      );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegisterPage(),
          settings: settings,
        );
      default:
        if (settings.name != null && settings.name!.startsWith('/play/')) {
          final uri = Uri.parse(settings.name!);
          final segments = uri.pathSegments;

          if (segments.length >= 3 && segments[0] == 'play') {
            final roundId = int.tryParse(segments[1]);
            final flagStr = segments[2].toLowerCase();
            final flag = flagStr == 'true';

            if (roundId != null) {
              return MaterialPageRoute(
              builder: (_) => ProtectedPage(child: PlayPage(roundId: roundId, flag: flag)),
              settings: settings,
            );
            }
          }
          return null;
        }
        return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
      }
    }

  PageRoute _noAnimationRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
