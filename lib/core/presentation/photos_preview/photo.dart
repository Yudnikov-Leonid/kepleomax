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

/// TODO refactor
class _PhotoState extends State<_Photo> with SingleTickerProviderStateMixin {
  late AnimationController _zoomController;
  Animation<Matrix4>? _zoomAnimation;

  TransformationController get _controller => widget.transformationController;

  final GlobalKey _childKey = GlobalKey();
  Size? _childSize;

  bool _isOnlyXAxes = false;

  bool _isOnlyYAxes = false;

  /// callbacks
  @override
  void initState() {
    _controller.addListener(_setState);
    _zoomController =
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
          _isOnlyXAxes = _childSize!.aspectRatio > 1;
          _isOnlyYAxes = (_childSize!.aspectRatio * 100).round() / 100 <
              context.screenSize.aspectRatio;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_setState);
    _zoomController.dispose();
    super.dispose();
  }

  /// listeners
  void _setState() {
    setState(() {});
  }

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
        transformationController: _controller,
        panAxis: _isOnlyXAxes
            ? PanAxis.horizontal
            : _isOnlyYAxes
            ? PanAxis.vertical
            : PanAxis.free,
        constrained: false,
        clipBehavior: Clip.none,
        maxScale: _maxScaleFactor,
        scaleEnabled: false,
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
                    ? const BoxConstraints()
                    : BoxConstraints(
                        maxHeight: _childSize!.height > screenHeight
                            ? screenHeight
                            : _childSize!.height,
                      ),
                child: KlmCachedImage(
                  imageUrl: flavor.imageUrl + widget.url,
                  errorColor: Colors.white,
                  width: context.imageMaxWidth,
                  key: _childKey,
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
        ..scale(
          _isOnlyYAxes
              ? _scaleFactorOnDoubleTapWhenOnlyYAxes
              : _scaleFactorOnDoubleTap,
        )
        ..translate(-newX, -newY);

      endMatrix = matrix;
    }

    _zoomAnimation = Matrix4Tween(
      begin: _controller.value,
      end: endMatrix,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_zoomController));
    _zoomController.forward(from: 0);
  }
}
