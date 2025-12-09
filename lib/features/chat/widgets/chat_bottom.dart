part of '../chat_screen.dart';

class _ChatBottom extends StatefulWidget {
  const _ChatBottom({
    required ValueChanged<String>? onSend,
    required this.isLoading,
    super.key,
  }) : _onSend = onSend;

  final ValueChanged<String>? _onSend;
  final bool isLoading;

  @override
  State<_ChatBottom> createState() => _ChatBottomState();
}

class _ChatBottomState extends State<_ChatBottom> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        width: context.screenSize.width,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: KlmTextField(
                  controller: _controller,
                  hint: 'Message',
                  onChanged: (newText) {},
                  multiline: true,
                  maxLength: 4000,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: widget._onSend == null
                    ? null
                    : () {
                        if (_controller.text.isEmpty || widget.isLoading) return;
                        widget._onSend!(_controller.text.trim());
                        _controller.clear();
                        setState(() {});
                      },
                style: IconButton.styleFrom(backgroundColor: KlmColors.primaryColor),
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
