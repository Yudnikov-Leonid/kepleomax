part of '../post_editor_screen.dart';

class _Images extends StatelessWidget {
  const _Images({required List<ImageUrlOrFile> images, required bool isLoading})
      : _images = images,
        _isLoading = isLoading;

  final List<ImageUrlOrFile> _images;
  final bool _isLoading;

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _images
            .mapIndexed(
              (i, image) => IgnorePointer(
            ignoring: _isLoading,
            child: LongPressDraggable<int>(
              data: i,
              feedback: SizedBox(height: 150, child: _image(image)),
              childWhenDragging: Container(
                margin: const EdgeInsets.only(right: 5),
                height: 150,
                child: _image(image, color: Colors.grey.shade300),
              ),
              child: DragTarget<int>(
                onAcceptWithDetails: (details) {
                  context.read<PostEditorBloc>().add(
                    PostEditorEventSwapPhotos(
                      indexOne: i,
                      indexTwo: details.data,
                    ),
                  );
                },
                builder: (context, _, _) {
                  return Container(
                    key: Key('image-${image.url}-${image.file?.path}-$i'),
                    margin: const EdgeInsets.only(right: 5),
                    height: 150,
                    child: Stack(
                      children: [
                        _image(image),
                        if (!_isLoading)
                          Positioned(
                            right: 0,
                            child: IconButton.filled(
                              onPressed: () {
                                context.read<PostEditorBloc>().add(
                                  PostEditorEventRemovePhoto(index: i),
                                );
                              },
                              icon: const Icon(
                                Icons.close,
                                fontWeight: FontWeight.bold,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withAlpha(75),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(5),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _image(ImageUrlOrFile image, {Color? color}) {
    return image.url != null
        ? KlmCachedImage(imageUrl: flavor.imageUrl + image.url!, color: color)
        : Image.file(image.file!, color: color);
  }
}