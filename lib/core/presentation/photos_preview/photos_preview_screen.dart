import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:kepleomax/core/presentation/caching_image.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/main.dart';
import 'package:num_remap/num_remap.dart';
import 'package:path_provider/path_provider.dart';

part 'swipe_view.dart';

part 'photo.dart';

/// constants
const int _minAlpha = 150;
const int _distanceToReachMinAlpha = 100;
const int _distanceToClose = 150;
const double _maxScaleFactor = 4;
const double _swipeViewHeight = 2600;

const double _scaleFactorOnDoubleTapWhenOnlyYAxes = 1.5;
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

  double get _defaultOffset => (_swipeViewHeight - context.screenSize.height) / 2;

  /// swipe up/down controller
  final ScrollController _scrollController = ScrollController();

  /// zoom controllers
  final _transformControllers = <TransformationController>[];

  late final _pageController = PageController(
    viewportFraction: 1,
    initialPage: _index,
  );

  @override
  void initState() {
    _index = widget.initialIndex;
    _scrollController.addListener(_setState);
    _pageController.addListener(_setState);
    for (int i = 0; i < widget.urls.length; i++) {
      final controller = TransformationController();
      controller.addListener(_setState);
      _transformControllers.add(controller);
    }

    Future.delayed(Duration.zero, () {
      /// need setState to apply scrollOffset on start
      setState(() {});
      _scrollController.jumpTo(_defaultOffset);
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_setState);
    _scrollController.dispose();
    _pageController.removeListener(_setState);
    _pageController.dispose();
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
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black.withAlpha(_getAlpha()),
        appBar: _showAppBar
            ? _AppBar(
                title: '${_index + 1}/${widget.urls.length}',
                getAlpha: _getAlpha,
                onSave: () async {
                  try {
                    String savedTo = 'gallery';
                    final String path;
                    if (Platform.isIOS) {
                      path = (await getApplicationDocumentsDirectory()).path;
                    } else {
                      Directory? directory = Directory(
                        '/storage/emulated/0/Download',
                      );

                      if (!await directory.exists()) {
                        directory = await getExternalStorageDirectory();
                        savedTo = 'external storage';
                      }

                      if (directory == null) throw Exception("Can't save image");

                      path = '${directory.path}/${widget.urls[_index]}';
                    }

                    await Dio().download(
                      flavor.imageUrl + widget.urls[_index],
                      path,
                    );
                    await Gal.putImage(path);
                    if (mounted) {
                      Fluttertoast.showToast(msg: 'Image saved to $savedTo');
                    }
                  } catch (e, st) {
                    logger.e(e, stackTrace: st);
                    if (mounted) {
                      Fluttertoast.showToast(msg: 'Failed to save image');
                    }
                  }
                },
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
              height: _swipeViewHeight,
              child: PageView(
                physics: _isInZoom ? NeverScrollableScrollPhysics() : null,
                controller: _pageController,
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
                      (i, url) => Stack(
                        children: [
                          Column(
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
                          Container(
                            height: double.infinity,
                            width: _getLeftLineWidth(),
                            color: Colors.black,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: context.screenSize.height,
                              width: _getRightLineWidth(),
                              color: Colors.black,
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
      ),
    );
  }

  double get _maxLinesWidth => context.screenSize.width * 0.1;

  double _getRightLineWidth() {
    final pos = _viewPagePos;
    if (pos < 0.1) {
      return 0;
    } else if (pos < 0.7) {
      return pos.remap(0.1, 0.7, 0, _maxLinesWidth);
    } else if (pos < 0.9) {
      return _maxLinesWidth;
    }

    return pos.remap(0.9, 1, _maxLinesWidth, 0);
  }

  double _getLeftLineWidth() {
    final pos = _viewPagePos;
    if (pos < 0.1) {
      return pos.remap(0, 0.1, 0, _maxLinesWidth);
    } else if (pos < 0.7) {
      return pos.remap(0.1, 0.7, _maxLinesWidth, 0);
    }

    return 0;
  }

  double get _viewPagePos =>
      _pageController.hasClients ? (_pageController.page ?? 0) % 1 : 0;

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
    required VoidCallback onSave,
  }) : _title = title,
       _getAlpha = getAlpha,
       _onSave = onSave;

  final String _title;
  final int Function({int minAlpha, int maxAlpha}) _getAlpha;
  final VoidCallback _onSave;

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
          onSelected: (value) async {
            if (value == 'save') {
              _onSave();
            }
          },
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
