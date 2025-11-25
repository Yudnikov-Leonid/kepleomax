part of '../chat_screen.dart';

class _TechMessage extends StatelessWidget {
  const _TechMessage({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      margin: const EdgeInsets.only(bottom: 6, top: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}