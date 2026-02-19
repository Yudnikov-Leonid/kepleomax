import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/unfocus_widget.dart';
import 'package:kepleomax/core/scopes/user_activity_scope.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';
import 'package:kepleomax/core/scopes/connection_scope.dart';
import 'package:kepleomax/features/chats/bloc/chats_bloc.dart';

final mainNavigatorGlobalKey = GlobalKey();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatsBloc(
          messengerRepository: Dependencies.of(context).messengerRepository,
          connectionRepository: Dependencies.of(context).connectionRepository,
        )),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: KlmColors.primaryColor),
        ),
        themeMode: ThemeMode.light,
        builder: (context, _) {
          return UnfocusWidget(
            child: AuthScope(
              builder: (context, userId) => ConnectionScope(
                key: Key('chat_scope_$userId'),
                child: UserActivityScope(
                  connectionRepository: Dependencies.of(context).connectionRepository,
                  child: AppNavigator(
                    initialState: [const MainPage()],
                    navigatorKey: mainNavigatorKey,
                    key: mainNavigatorGlobalKey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
