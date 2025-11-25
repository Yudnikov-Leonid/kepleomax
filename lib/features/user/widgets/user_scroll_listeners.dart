part of '../user_screen.dart';

class _ScrollControllerListeners extends StatefulWidget {
  const _ScrollControllerListeners({
    required this.controller,
    required this.userId,
    required this.child,
  });

  final AutoScrollController controller;
  final int userId;
  final Widget child;

  @override
  State<_ScrollControllerListeners> createState() =>
      _ScrollControllerListenersState();
}

class _ScrollControllerListenersState extends State<_ScrollControllerListeners> {
  late PostListBloc _postBloc;

  /// callbacks
  @override
  void initState() {
    _postBloc = PostListBloc(
      postRepository: Dependencies.of(context).postRepository,
      userId: widget.userId,
    )..add(const PostListEventLoad());
    widget.controller.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScrollListener);
    super.dispose();
  }

  /// listeners
  void _onScrollListener() {
    if (widget.controller.offset >
        widget.controller.position.maxScrollExtent - 180) {
      _postBloc.add(const PostListEventLoadMore());
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final offset = widget.controller.offset;
      if (offset > 0 && offset <= 75) {
        widget.controller.scrollToIndex(0, preferPosition: AutoScrollPosition.end);
      } else if (offset > 75 && offset < 125) {
        widget.controller.scrollToIndex(1, preferPosition: AutoScrollPosition.begin);
      }
    }
    return false;
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostListBloc>(
      create: (context) => _postBloc,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: widget.child,
      ),
    );
  }
}