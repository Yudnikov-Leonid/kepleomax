part of '../chat_screen.dart';

class _Bottom extends StatefulWidget {
  const _Bottom({required ValueChanged<String>? onSend, super.key})
      : _onSend = onSend;

  final ValueChanged<String>? _onSend;

  @override
  State<_Bottom> createState() => _BottomState();
}

class _BottomState extends State<_Bottom> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  if (_controller.text.isEmpty) return;
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