import 'package:flutter/material.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';
import 'package:kepleomax/features/editProfile/edit_profile_bottom_sheet.dart';
import 'package:kepleomax/features/user/post_widget.dart';
import 'package:num_remap/num_remap.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class EditUserBottomSheetPage extends ModalBottomSheetRoute {
  EditUserBottomSheetPage({
    required super.builder,
    required super.isScrollControlled,
  });
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late final _scrollController = AutoScrollController(
    viewportBoundaryGetter: () =>
        Rect.fromLTRB(0, MediaQuery.of(context).viewPadding.top, 0, 0),
  );

  void _onScrolled() {
    //print(_scrollController.offset);
    setState(() {});
  }

  @override
  void initState() {
    _scrollController.addListener(_onScrolled);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrolled);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.userOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha(
          !_scrollController.hasClients
              ? 0
              : _scrollController.offset.remap(0, 90, 0, 255).clamp(0, 255).toInt(),
        ),
        surfaceTintColor: Colors.white,
        leading: KlmBackButton(),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              AppNavigator.canPop = false;

              await showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                backgroundColor: Colors.white,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => EditProfileBottomSheet(),
                isDismissible: false,
                //enableDrag: false,
              );

              AppNavigator.canPop = true;
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Text(
                  'Edit profile',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text(
                  'Logout',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
        title: Opacity(
          opacity: !_scrollController.hasClients
              ? 0
              : _scrollController.offset.remap(110, 130, 0, 1).clamp(0, 1),
          child: Text(
            user.username,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            // print('scroll start');
          } else if (notification is ScrollEndNotification) {
            //print('scroll end, offset: ${_scrollController.offset}');
            final offset = _scrollController.offset;
            if (offset > 0 && offset <= 75) {
              //print('scroll to index 0');
              _scrollController.scrollToIndex(
                0,
                preferPosition: AutoScrollPosition.end,
              );
            } else if (offset > 75 && offset < 125) {
              //print('scroll to index 1');
              _scrollController.scrollToIndex(
                1,
                preferPosition: AutoScrollPosition.begin,
              );
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          key: Key('scroll_profile'),
          padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
          controller: _scrollController,
          child: Column(
            children: [
              AutoScrollTag(
                key: Key('top_scroll_tag'),
                controller: _scrollController,
                index: 0,
                highlightColor: Colors.red,
                child: Center(
                  child: Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              AutoScrollTag(
                key: Key('bottom_of_username_scroll_tag'),
                controller: _scrollController,
                index: 1,
                highlightColor: Colors.red,
                child: const SizedBox(height: 16),
              ),
              Text(
                user.username,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Very cool and amazing description',
                style: context.textTheme.bodyLarge?.copyWith(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, weight: 4, color: Colors.black, size: 24),
                        const SizedBox(width: 2),
                        Text(
                          'Post',
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Divider(thickness: 5, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              PostWidget(
                post: Post(
                  user: user,
                  content:
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                  likesCount: 22,
                  createdAt: 1762682274000,
                  updatedAt: 1762682474000,
                ),
              ),
              const SizedBox(height: 1000),
              const Text('END'),
            ],
          ),
        ),
      ),
    );
  }
}
