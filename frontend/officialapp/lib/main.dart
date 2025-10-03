import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'pages/user_regristration/login_page.dart';
import 'widgets/protected_page.dart';
import 'services/handle_reload.dart';
import 'pages/play_page.dart';
import 'services/version_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/user_regristration/startprogress_page.dart';
import 'pages/user_regristration/StartRegisterPage0.dart';
import 'pages/user_regristration/1RegisterPage.dart';
import 'pages/user_regristration/2RegisterPage.dart';
import 'pages/user_regristration/3RegisterPage.dart';
import 'pages/user_regristration/4RegisterPage.dart';
import 'pages/user_regristration/5RegisterPage.dart';
import 'pages/user_regristration/6RegisterPage.dart';
import 'pages/user_regristration/ResetPasswordPage.dart';
import 'pages/features/checkin_page.dart';
import 'pages/inbox_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
      title: 'officialapp',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF6246EA),
        primarySwatch: Colors.purple,
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

      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
          settings: settings,
        );

      case '/register1':
      return MaterialPageRoute(
        builder: (_) => RegisterPage1(),
        settings: settings,
      );

      case '/register2':
      return MaterialPageRoute(
        builder: (_) => RegisterPage2(),
        settings: settings,
      );

      case '/register3':
      return MaterialPageRoute(
        builder: (_) => RegisterPage3(),
        settings: settings,
      );

      case '/register4':
      return MaterialPageRoute(
        builder: (_) => RegisterPage4(),
        settings: settings,
      );

      case '/register5':
      return MaterialPageRoute(
        builder: (_) => RegisterPage5(),
        settings: settings,
      );

      case '/register6':
      return MaterialPageRoute(
        builder: (_) => RegisterPage6(),
        settings: settings,
      );

      case "/start-progress":
      return MaterialPageRoute(builder: (_) => StartprogressPage(),
      settings: settings,);
      
      case "/start-register":
      return MaterialPageRoute(builder: (_) => StartRegisterPage0(),
      settings: settings,);
      
      case "/reset-password":
      return MaterialPageRoute(builder: (_) => ResetPasswordPage(),
      settings: settings,);

      case '/feature/checkin':
        return MaterialPageRoute(
          builder: (_) => ProtectedPage(child: CheckInPage()),
          settings: settings,
        );
      case '/inbox':
        return MaterialPageRoute(
          builder: (_) => ProtectedPage(child: InboxPage()),
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
          body: Center(child: Text('Feature not found')),
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
