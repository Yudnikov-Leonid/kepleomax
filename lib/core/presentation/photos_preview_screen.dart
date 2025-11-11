import 'package:flutter/material.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/main.dart';

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

  @override
  void initState() {
    _index = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text('${_index + 1}/${widget.urls.length}'),
      leading: KlmBackButton(),
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem<String>(value: 'save', child: Text('Save to gallery')),
          ],
        ),
      ],
    ),
    body: PageView(
      controller: PageController(
        viewportFraction: 1,
        initialPage: _index,
      ),
      onPageChanged: (newIndex) {
        setState(() {
          _index = newIndex;
        });
      },
      children: widget.urls.map(_photo).toList(),
    ),
  );

  Widget _photo(String url) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 0),
    child: Image.network(flavor.imageUrl + url, fit: BoxFit.contain),
  );
}
