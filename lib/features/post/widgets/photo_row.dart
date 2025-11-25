part of '../post_widget.dart';

/// not in use now
class _PhotosRow extends StatefulWidget {
  const _PhotosRow({required this.images, required this.maxHeight});

  final List<String> images;
  final double maxHeight;

  @override
  State<_PhotosRow> createState() => _PhotosRowState();
}

class _PhotosRowState extends State<_PhotosRow> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenSize.width;
    final maxHeight = widget.maxHeight;

    return Stack(
      children: [
        SizedBox(
          height: maxHeight,
          width: screenWidth,
          child: PageView(
            controller: PageController(initialPage: 0),
            onPageChanged: (newIndex) {
              setState(() {
                _index = newIndex;
              });
            },
            children: widget.images
                .mapIndexed(
                  (i, image) => _PhotoWidget(
                width: screenWidth,
                height: maxHeight,
                index: i,
                imagesToOpen: widget.images,
              ),
            )
                .toList(),
          ),
        ),
        Positioned(
          right: 7,
          top: 7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
            child: Text(
              '${_index + 1}/${widget.images.length}',
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}