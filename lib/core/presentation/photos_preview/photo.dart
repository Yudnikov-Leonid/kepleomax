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

  bool get _isOnlyXAxes => _childSize == null ? false : _childSize!.aspectRatio > 1;

  bool get _isOnlyYAxes => _childSize == null
      ? false
      : (_childSize!.aspectRatio * 100).round() / 100 <
            context.screenSize.aspectRatio;

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenSize.height;
    final double topPadding = _childSize == null
        ? 0
        : ((screenHeight - _childSize!.height) / 2);
    //print('topPadding: $topPadding, childSize: ${_childSize?.height}');

    return GestureDetector(
      onDoubleTapDown: _onDoubleTap,
      child: InteractiveViewer(
        panAxis: _isOnlyXAxes
            ? PanAxis.horizontal
            : _isOnlyYAxes
            ? PanAxis.vertical
            : PanAxis.free,
        constrained: false,
        clipBehavior: Clip.none,
        transformationController: _controller,
        maxScale: _maxScaleFactor,
        minScale: 1,
        boundaryMargin: _isOnlyXAxes || _isOnlyYAxes
            ? EdgeInsets.zero
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
                child: ColoredBox(
                  color: Colors.green,
                  child: KlmCachedImage(
                    imageUrl:  flavor.imageUrl + widget.url,
                    key: _childKey,
                  ),
                ),
              ),
            ],
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

      print(
        'child: ${_childSize!.width}, screen: ${context.screenSize.width}, aspect: ${_childSize!.aspectRatio}, screenAspect: ${context.screenSize.aspectRatio}',
      );

      final double newY;
      if (_childSize == null) {
        newY = center.dy;
      } else if (_isOnlyXAxes) {
        newY = topPadding + _childSize!.height / 2;
      } else {
        /// 1.668 - magicNumber, but it works
        final minY = topPadding * 1.668;
        final maxY = screenHeight - minY;

        newY = center.dy < minY
            ? minY
            : center.dy > maxY
            ? maxY
            : center.dy;
      }

      final double newX;
      if (_isOnlyYAxes) {
        newX = context.screenSize.width / 2;
      } else {
        newX = center.dx;
      }

      final Matrix4 matrix = Matrix4.identity()
        ..translate(newX, newY)
        ..scale(_isOnlyYAxes ? 1.4 : _scaleFactorOnDoubleTap)
        ..translate(-newX, -newY);

      endMatrix = matrix;
    }

    _zoomAnimation = Matrix4Tween(
      begin: _controller.value,
      end: endMatrix,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_zoomAnimationController));
    _zoomAnimationController.forward(from: 0);
  }
}
