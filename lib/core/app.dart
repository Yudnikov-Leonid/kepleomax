import 'package:flutter/material.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/scopes/activity_scope.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';
import 'package:kepleomax/core/scopes/chat_scope.dart';

final mainNavigatorGlobalKey = GlobalKey();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context).focusedChild;
        if (currentFocus != null && !currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: KlmColors.primaryColor),
        ),
        // darkTheme: ThemeData(
        //   brightness: Brightness.dark,
        //   scaffoldBackgroundColor: Colors.black,
        //   appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        // ),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        builder: (context, _) {
          return AuthScope(
            builder: (context, userId) => ChatScope(
              key: Key('chat_scope_$userId'),
              child: ActivityScope(
                connectionRepository: Dependencies.of(context).connectionRepository,
                child: AppNavigator(
                  initialState: [const MainPage()],
                  navigatorKey: mainNavigatorKey,
                  key: mainNavigatorGlobalKey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
