import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/parse_time.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                post.user.username,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 19,
                ),
              ),
              const Expanded(child: SizedBox()),
              IconButton(onPressed: () {}, icon: Icon(Icons.edit, size: 20)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            post.content,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/favorite_icon.svg', height: 24),
                    const SizedBox(width: 4),
                    Text(
                      post.likesCount.toString(),
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              Tooltip(
                message:
                    '${ParseTime.unixTimeToPreciseDate(post.createdAt)}${post.updatedAt == null ? '' : '\nedited: ${ParseTime.unixTimeToPreciseDate(post.updatedAt!)}'}',
                triggerMode: TooltipTriggerMode.tap,
                preferBelow: false,
                showDuration: Duration(seconds: 5),
                child: Text(
                  ParseTime.unixTimeToDate(post.createdAt),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
