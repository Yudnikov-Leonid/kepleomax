import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/main.dart';

import 'bloc/post_editor_bloc.dart';
import 'bloc/post_editor_state.dart';

class PostEditorScreen extends StatelessWidget {
  const PostEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostEditorBloc>(
      create: (context) => PostEditorBloc(
        filesRepository: Dependencies.of(context).filesRepository,
        postRepository: Dependencies.of(context).postRepository,
      ),
      child: BlocListener<PostEditorBloc, PostEditorState>(
        listener: (context, state) {
          if (state is PostEditorStateError) {
            context.showSnackBar(text: state.message, color: KlmColors.errorRed);
          }

          if (state is PostEditorStateExit) {
            AppNavigator.withKeyOf(context, mainNavigatorKey)!.pop();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _AppBar(),
          body: _Body(),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostEditorBloc, PostEditorState>(
      buildWhen: (oldState, newState) {
        if (newState is! PostEditorStateBase) return false;

        if (oldState is! PostEditorStateBase) return true;

        return !listEquals(oldState.data.images, newState.data.images) ||
            oldState.data.isLoading != newState.data.isLoading;
      },
      builder: (context, state) {
        if (state is! PostEditorStateBase) return SizedBox();

        final data = state.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _Images(images: data.images, isLoading: data.isLoading),
                      TextFormField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: data.isLoading ? '' : 'Write something here...',
                        ),
                        maxLength: 4000,
                        readOnly: data.isLoading,
                        onChanged: (newText) {
                          context.read<PostEditorBloc>().add(
                            PostEditorEventEditText(newText: newText),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: data.isLoading || data.images.length >= imagesCountLimit
                    ? null
                    : () {
                        context.read<PostEditorBloc>().add(
                          const PostEditorEventAddPhotos(),
                        );
                      },
                child: Text(
                  'Add photos',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: data.isLoading || data.images.length >= imagesCountLimit
                        ? KlmColors.inactiveColor
                        : KlmColors.primaryColor.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _Images extends StatelessWidget {
  const _Images({required List<ImageUrlOrFile> images, required bool isLoading})
    : _images = images,
      _isLoading = isLoading;

  final List<ImageUrlOrFile> _images;
  final bool _isLoading;

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) return SizedBox();

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
                        PostEditorEventSwapPhotos(indexOne: i, indexTwo: details.data),
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
                                  icon: Icon(Icons.close, fontWeight: FontWeight.bold),
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
        ? Image.network(flavor.imageUrl + image.url!, color: color)
        : Image.file(image.file!, color: color);
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostEditorBloc, PostEditorState>(
      buildWhen: (oldState, newState) {
        if (newState is! PostEditorStateBase) return false;

        if (oldState is! PostEditorStateBase) return true;

        return oldState.data != newState.data;
      },
      builder: (context, state) {
        if (state is! PostEditorStateBase) return SizedBox();

        final data = state.data;
        return AppBar(
          centerTitle: true,
          scrolledUnderElevation: 0.0,
          forceMaterialTransparency: true,
          title: Text(
            'New Post',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: data.isLoading
                  ? KlmColors.inactiveColor
                  : KlmColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
            onPressed: data.isLoading
                ? null
                : () {
                    AppNavigator.pop(context);
                  },
          ),
          actions: [
            TextButton(
              onPressed: data.isLoading || data.isEmpty()
                  ? null
                  : () {
                      context.read<PostEditorBloc>().add(
                        const PostEditorEventPost(),
                      );
                    },
              child: data.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: KlmColors.inactiveColor,
                      ),
                    )
                  : Text(
                      'Post',
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: data.isLoading || data.isEmpty()
                            ? KlmColors.inactiveColor
                            : KlmColors.primaryColor,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
