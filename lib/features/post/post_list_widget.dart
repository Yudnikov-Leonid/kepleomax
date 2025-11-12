import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_button.dart';
import 'package:kepleomax/features/post/bloc/post_list_state.dart';
import 'package:kepleomax/features/post/post_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'bloc/post_list_bloc.dart';

/// must be BlocProvider above with PostListBloc
class PostListWidget extends StatelessWidget {
  const PostListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostListBloc, PostListState>(
      builder: (context, state) {
        if (state is PostListStateLoading) {
          return Skeletonizer(
            child: Column(
              children: [
                PostWidget(post: Post.loading()),
                PostWidget(post: Post.loading()),
                PostWidget(post: Post.loading()),
                Text('-----------------------'),
                const SizedBox(height: 16),
              ],
            ),
          );
        } else if (state is PostListStateError) {
          return Center(
            child: Column(
              children: [
                Text(
                  state.message,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                KlmButton(
                  onPressed: () {
                    context.read<PostListBloc>().add(PostListEventLoad());
                  },
                  text: 'Retry',
                  width: 120,
                ),
              ],
            ),
          );
        } else if (state is PostListStateBase) {
          final data = state.data;
          return Column(
            children: [
              ...data.posts.map((post) => PostWidget(post: post)),

              if (data.isAllPostsLoaded)
                Container(
                  height: 50,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Text(
                      '${data.posts.length} ${data.posts.length == 1 ? 'post' : 'posts'}',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                )
              else
                PostWidget(post: Post.loading()),
            ],
          );
        }

        return SizedBox();
      },
    );
  }
}
