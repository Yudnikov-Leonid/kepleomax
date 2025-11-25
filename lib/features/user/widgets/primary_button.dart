part of '../user_screen.dart';

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.isCurrentUser, required this.navigateToPage});

  final bool isCurrentUser;
  final AppPage navigateToPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: KlmColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextButton(
          onPressed: () {
            AppNavigator.withKeyOf(context, mainNavigatorKey)!.push(navigateToPage);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCurrentUser ? Icons.add : Icons.message_sharp,
                weight: 4,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 4),
              Text(
                isCurrentUser ? 'Post' : 'Message',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}