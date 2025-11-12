part of 'photos_preview_screen.dart';

class _Photo extends StatefulWidget {
  const _Photo({
    super.key,
    required this.url,
    required this.transformationController,
  });

  final String url;
  final TransformationController transformationController;

  @override
  State<_Photo> createState() => _PhotoState();
}

class _PhotoState extends State<_Photo> with SingleTickerProviderStateMixin {
  /// zoom controller
  late AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;

  TransformationController get _controller => widget.transformationController;

  void _setState() {
    setState(() {});
  }

  @override
  void initState() {
    _controller.addListener(_setState);
    _zoomAnimationController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 150))
      ..addListener(() {
        _controller.value = _zoomAnimation!.value;
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
      _childKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _childSize = renderBox.size;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_setState);
    _zoomAnimationController.dispose();
    super.dispose();
  }

  final GlobalKey _childKey = GlobalKey();
  Size? _childSize;

  // EdgeInsets? _getBoundaryMargin() {
  //   final screenHeight = MediaQuery.of(context).size.height;
  //
  //   if (_childSize != null) {
  //     final verticalMargin = (screenHeight - _childSize!.height) / 2;
  //     final marginBehindScreen = (2600 - screenHeight) / 2;
  //     print('verticalMargin: $verticalMargin, childSize: ${_childSize!.height}, marginBehindScreen: $marginBehindScreen');
  //     return EdgeInsets.symmetric(vertical: verticalMargin + marginBehindScreen);
  //   }
  //
  //   return null;
  // }

  bool get _isOnlyXAxes =>
      _childSize == null
          ? false
          : _childSize!.height / context.screenSize.width < 1 / 1;

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;
    final double topPadding = _childSize == null
        ? 0
        : ((screenHeight - _childSize!.height) / 2);
    //print('topPadding: $topPadding, childSize: ${_childSize?.height}');

    return GestureDetector(
      onDoubleTapDown: _onDoubleTap,
      child: Padding(
        padding: EdgeInsets.only(top: 0),
        child: InteractiveViewer(
          panAxis: _isOnlyXAxes ? PanAxis.horizontal : PanAxis.free,
          constrained: false,
          clipBehavior: Clip.none,
          transformationController: _controller,
          maxScale: _maxScaleFactor,
          minScale: 1,
          boundaryMargin: _isOnlyXAxes
              ? EdgeInsets.only(bottom: 0)
              : EdgeInsets.symmetric(vertical: -topPadding),
          child: SizedBox(
            width: context.screenSize.width,
            height: screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: _childSize == null
                      ? BoxConstraints()
                      : BoxConstraints(
                    maxHeight: _childSize!.height > screenHeight
                        ? screenHeight
                        : _childSize!.height,
                  ),
                  child: KlmCachedImage(
                    key: _childKey,
                    imageUrl: flavor.imageUrl + widget.url,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDoubleTap(TapDownDetails details) {
    final Matrix4 endMatrix;

    if (_controller.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      final center = details.localPosition;
      final screenHeight = context.screenSize.height;

      /// check click in bounds of image
      final topPadding = (screenHeight - _childSize!.height) / 2;
      if (center.dy < topPadding || center.dy > (screenHeight - topPadding)) {
        return;
      }

      final double newY;
      if (_childSize == null) {
        newY = center.dy;
      } else if (_isOnlyXAxes) {
        newY = topPadding + _childSize!.height / 2;
      } else {
        /// 1.668 - magicNumber
        final minY = topPadding * 1.668;
        final maxY = screenHeight - minY;

        newY = center.dy < minY
            ? minY
            : center.dy > maxY
            ? maxY
            : center.dy;
      }

      final Matrix4 matrix = Matrix4.identity()
        ..translate(center.dx, newY)
        ..scale(_scaleFactorOnDoubleTap)
        ..translate(-center.dx, -newY);

      endMatrix = matrix;
    }

    _zoomAnimation = Matrix4Tween(
      begin: _controller.value,
      end: endMatrix,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_zoomAnimationController));
    _zoomAnimationController.forward(from: 0);
  }
}