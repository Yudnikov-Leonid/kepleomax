import 'package:flutter/material.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';

class KlmTextField extends StatefulWidget {
  const KlmTextField({
    required this.controller,
    required this.onChanged,
    this.label,
    this.hint,
    this.isPassword = false,
    this.showErrors = false,
    this.validators = const [],
    this.maxLength,
    this.readOnly = false,
    this.multiline = false,
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool isPassword;
  final ValueChanged<String> onChanged;
  final bool showErrors;
  final List<String? Function(String)> validators;
  final int? maxLength;
  final bool readOnly;
  final bool multiline;

  @override
  State<KlmTextField> createState() => _KlmTextFieldState();
}

class _KlmTextFieldState extends State<KlmTextField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String? _error() {
    if (!widget.showErrors) {
      return null;
    }

    for (final validator in widget.validators) {
      final check = validator(widget.controller.text);
      if (check != null) {
        return check;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (newFocus) {
        setState(() {});
      },
      child: Stack(
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.multiline ? null : 1,
            maxLength: widget.maxLength ?? 50,
            keyboardType: widget.multiline ? TextInputType.multiline : null,
            onChanged: (value) {
              setState(() {});
              widget.onChanged(value);
            },
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              floatingLabelStyle: context.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
              suffix: widget.readOnly
                  ? null
                  : widget.controller.text.isNotEmpty
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: InkWell(
                        onTap: () {
                          widget.controller.clear();
                          widget.onChanged('');
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    )
                  : null,
              counter: const SizedBox(),
              contentPadding: EdgeInsets.only(
                bottom: 15,
                left: 15,
                right: 15,
                top: 15,
              ),
              isDense: true,
              focusedBorder: _getFocusedBorder(),
              focusedErrorBorder: _getBorder(_error() != null),
              enabledBorder: _getBorder(_error() != null),
              errorBorder: _getBorder(_error() != null),
              errorText: _error(),
              //labelText: widget.label,
              label: widget.label == null
                  ? null
                  : Container(
                      color: Colors.white,
                      child: Text(
                        widget.label!,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
              hintText: _focusNode.hasFocus || widget.controller.text.isNotEmpty
                  ? ''
                  : widget.hint,
              hintStyle: const TextStyle(color: Colors.grey),
              labelStyle: context.textTheme.titleLarge?.copyWith(color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          if (widget.maxLength != null)
            Positioned(
              bottom: _error() != null ? 32 : 4,
              right: 10,
              child: Text('${widget.controller.text.length}/${widget.maxLength}'),
            ),
        ],
      ),
    );
  }

  InputBorder? _getFocusedBorder() => widget.readOnly
      ? _getBorder(false)
      : OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 3,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        );

  InputBorder? _getBorder(bool isError) {
    if (isError) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: KlmColors.errorRed,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: widget.controller.text.isEmpty || widget.readOnly
            ? KlmColors.inactiveColor
            : KlmColors.primaryColor,
        width: 2,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    );
  }
}
