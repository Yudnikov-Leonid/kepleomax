part of 'photos_preview_screen.dart';

class _SwipeView extends StatefulWidget {
  const _SwipeView({
    required this.scrollController,
    required this.onExit,
    required this.canScroll,
    required this.child,
  });

  final ScrollController scrollController;
  final VoidCallback onExit;
  final bool Function() canScroll;
  final Widget child;

  @override
  State<_SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<_SwipeView> {
  /// automatically by controller.animateTo
  bool _isScrollingToPosition = false;

  /// when the user touches the screen
  bool _isScrollingByUser = false;
  ScrollPhysics? _scrollPhysics = const AlwaysScrollableScrollPhysics();

  double get _defaultOffset => (_swipeViewHeight - context.screenSize.height) / 2;

  get controller => widget.scrollController;

  /// scroll to the edge or default position, depends on current scrollPosition
  void _performScroll() {
    if (_isScrollingToPosition) return;
    _isScrollingToPosition = true;

    final offset = controller.offset;
    final topBound = _defaultOffset - _distanceToClose;
    final bottomBound = _defaultOffset + _distanceToClose;

    /// _scrollController.animateTo doesn't work without a Future
    Future.delayed(const Duration(milliseconds: 10), () {
      if (offset < bottomBound && offset > topBound) {
        /// scroll back to default
        controller!
            .animateTo(
          _defaultOffset,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        )
            .whenComplete(() {
          _isScrollingToPosition = false;
        });
      } else {
        /// closing dialog
        final maxScrollPosition = controller.position.maxScrollExtent;
        controller.animateTo(
          offset < topBound ? 0.0 : maxScrollPosition.toDouble(),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
        if (mounted) {
          setState(() {
            _scrollPhysics = const NeverScrollableScrollPhysics();
          });
          widget.onExit();
        }
      }
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      /// scroll stopped. ScrollView can have an inertia and this event can
      /// be invoked only ~1 sec after user raised a finger
      _performScroll();
    }

    /// to prevent inertia, that can took ~1 sec after the user raised a finger
    if (notification is ScrollUpdateNotification) {
      if (!_isScrollingByUser && notification.dragDetails != null) {
        /// user puts a finger and scrolls
        _isScrollingByUser = true;
      } else if (_isScrollingByUser && notification.dragDetails == null) {
        /// user raised a finer, handle scroll
        _isScrollingByUser = false;
        _performScroll();
      }

      /// other cases:
      /// if _isScrollingByUser && details != null -> user is scrolling now, no need to handle
      /// if !_isScrollingByUser && details == null -> impossible condition
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _onScrollNotification,
      child: SingleChildScrollView(
        controller: controller,
        physics: widget.canScroll()
            ? _scrollPhysics
            : const NeverScrollableScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}
