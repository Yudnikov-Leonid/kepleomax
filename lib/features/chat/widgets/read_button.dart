part of '../chat_screen.dart';

class _ReadButton extends StatefulWidget {
  const _ReadButton({required ScrollController scrollController, super.key})
    : _scrollController = scrollController;

  final ScrollController _scrollController;

  @override
  State<_ReadButton> createState() => _ReadButtonState();
}

class _ReadButtonState extends State<_ReadButton> {
  static const _offsetToShow = 200;
  double _lastPosition = 0;

  void _onScrollListener() {
    if (_lastPosition < _offsetToShow &&
        widget._scrollController.offset > _offsetToShow) {
      setState(() {});
    } else if (_lastPosition > _offsetToShow &&
        widget._scrollController.offset < _offsetToShow) {
      setState(() {});
    }
    _lastPosition = widget._scrollController.offset;
  }

  @override
  void initState() {
    widget._scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget._scrollController.removeListener(_onScrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (oldState, newState) {
        if (newState is! ChatStateBase) return false;

        if (oldState is! ChatStateBase) return true;

        return oldState.data != newState.data;
      },
      builder: (context, state) {
        if (state is! ChatStateBase) return const SizedBox();

        final data = state.data;
        if (state.data.messages.isEmpty) return const SizedBox();
        final allMessagesIsRead =
            data.messages.first.user.isCurrent || data.messages.first.isRead;
        final isScrolledUp = widget._scrollController.positions.length == 1
            ? widget._scrollController.offset > _offsetToShow
            : false;
        if ((allMessagesIsRead && !isScrolledUp) || data.isLoading)
          return const SizedBox();
        return Padding(
          padding: const EdgeInsets.only(bottom: 75),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                shape: const CircleBorder(),
                elevation: 1,
                backgroundColor: Colors.white,
                isExtended: true,
                child: Transform.rotate(
                  angle: 270 * math.pi / 180,
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                ),
                onPressed: () {
                  widget._scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                  if (!allMessagesIsRead) {
                    context.read<ChatBloc>().add(const ChatEventReadAllMessages());
                  }
                },
              ),
              if (!allMessagesIsRead)
                Positioned(
                  top: -14,
                  child: Container(
                    width: 35,
                    decoration: const BoxDecoration(
                      color: KlmColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Center(
                      child: Text(
                        data.messages.where((e) => !e.isRead).length.toString(),
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
