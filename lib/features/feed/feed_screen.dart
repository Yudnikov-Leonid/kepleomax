import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/features/post/bloc/post_list_bloc.dart';
import 'package:kepleomax/features/post/post_list_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _scrollController = ScrollController();
  late final PostListBloc _postBloc;

  /// callbacks
  @override
  void initState() {
    _postBloc = PostListBloc(
      postRepository: Dependencies
          .of(context)
          .postRepository,
      userId: null,
    )
      ..add(const PostListEventLoad());
    _scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// listeners
  void _onScrollListener() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 180) {
      _postBloc.add(const PostListEventLoadMore());
    }
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<PostListBloc>(
        create: (context) => _postBloc,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _postBloc.add(const PostListEventLoad());
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  KlmAppBar(context, 'Feed'),
                  const SizedBox(height: 10),
                  PostListWidget(key: Key('feed_posts'), isUserPage: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
