import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kepleomax/core/presentation/caching_image.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/main.dart';
import 'package:num_remap/num_remap.dart';

part 'swipe_view.dart';
part 'photo.dart';

/// constants
const double _defaultOffset = 843;
const int _minAlpha = 150;
const int _distanceToReachMinAlpha = 100;
const int _distanceToClose = 150;
const double _maxScaleFactor = 4;
/// change carefully
const double _scaleFactorOnDoubleTap = 2.5;

class PhotosPreviewScreen extends StatefulWidget {
  const PhotosPreviewScreen({
    required this.urls,
    required this.initialIndex,
    super.key,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<PhotosPreviewScreen> createState() => _PhotosPreviewScreenState();
}

class _PhotosPreviewScreenState extends State<PhotosPreviewScreen> {
  late int _index;
  bool _showAppBar = true;

  /// swipe up/down controller
  final _scrollController = ScrollController(initialScrollOffset: _defaultOffset);

  /// zoom controllers
  final _transformControllers = <TransformationController>[];

  @override
  void initState() {
    _index = widget.initialIndex;
    _scrollController.addListener(_setState);
    for (int i = 0; i < widget.urls.length; i++) {
      final controller = TransformationController();
      controller.addListener(_setState);
      _transformControllers.add(controller);
    }

    Future.delayed(Duration.zero, () {
      /// need setState to apply scrollOffset on start
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_setState);
    _scrollController.dispose();
    for (final controller in _transformControllers) {
      controller.removeListener(_setState);
      controller.dispose();
    }
    if (!_showAppBar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black.withAlpha(_getAlpha()),
      appBar: _showAppBar
          ? _AppBar(
              title: '${_index + 1}/${widget.urls.length}',
              getAlpha: _getAlpha,
            )
          : null,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showAppBar = !_showAppBar;
            if (_showAppBar) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            } else {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            }
          });
        },

        /// need here so zoom by double tap can work
        onDoubleTap: () {},
        child: _SwipeView(
          scrollController: _scrollController,
          onExit: () {
            Navigator.pop(context);
          },
          canScroll: () => !_isInZoom,
          child: SizedBox(
            height: 2600,
            child: PageView(
              physics: _isInZoom ? NeverScrollableScrollPhysics() : null,
              controller: PageController(viewportFraction: 1, initialPage: _index),
              onPageChanged: (newIndex) {
                setState(() {
                  // for (final controller in _transformControllers) {
                  //   controller.value = Matrix4.identity();
                  // }
                  _index = newIndex;
                });
              },
              children: widget.urls
                  .mapIndexed(
                    (i, url) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: context.screenSize.height,
                          ),
                          child: _Photo(
                            key: Key('photo_${i}_$url'),
                            url: url,
                            transformationController: _transformControllers[i],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _setState() {
    setState(() {});
  }

  bool get _isInZoom => _transformControllers
      .where((controller) => controller.value.getMaxScaleOnAxis() >= 1.05)
      .isNotEmpty;

  int _getAlpha({int minAlpha = _minAlpha, int maxAlpha = 255}) {
    if (!_scrollController.hasClients) return 0;
    final offset = _scrollController.offset;

    if (offset > _defaultOffset + _distanceToReachMinAlpha ||
        offset < _defaultOffset - _distanceToReachMinAlpha) {
      return minAlpha;
    }
    return _scrollController.offset
        .remap(
      _defaultOffset,
      _defaultOffset +
          (_distanceToReachMinAlpha * (offset > _defaultOffset ? 1 : -1)),
      maxAlpha,
      minAlpha,
    )
        .toInt();
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required String title,
    required int Function({int minAlpha, int maxAlpha}) getAlpha,
  }) : _title = title,
       _getAlpha = getAlpha;

  final String _title;
  final int Function({int minAlpha, int maxAlpha}) _getAlpha;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withAlpha(_getAlpha(minAlpha: 0, maxAlpha: 130)),
      foregroundColor: Colors.white.withAlpha(_getAlpha(minAlpha: 0)),
      surfaceTintColor: Colors.transparent,
      title: Text(_title),
      automaticallyImplyLeading: false,
      leading: KlmBackButton(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem<String>(value: 'save', child: Text('Save to gallery')),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}