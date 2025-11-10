import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';

import '../navigation/app_navigator.dart';

class KlmAppBar extends AppBar {
  KlmAppBar(BuildContext context, String title, {Widget? leading, super.key})
    : super(
        leading: InkWell(
          onTap: () {
            AppNavigator.of(
              context,
            )?.push(UserPage(userId: AuthScope.userOf(context).id));
          },
          child:
              leading ??
              Container(
                margin: const EdgeInsets.all(12),
                child: UserImage(url: AuthScope.userOf(context).profileImage),
              ),
        ),
        titleSpacing: 5,
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: context.textTheme.labelLarge?.copyWith(fontSize: 24),
        ),
      );
}

class KlmBackButton extends StatelessWidget {
  const KlmBackButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed:
          onPressed ??
          () {
            AppNavigator.pop(context);
          },
      icon: Icon(Icons.arrow_back_ios_new),
    );
  }
}
