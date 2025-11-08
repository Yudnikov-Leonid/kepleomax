import 'package:flutter/material.dart';
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
    this.maxLength = 50,
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
    if (!widget.showErrors || _focusNode.hasFocus) {
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
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLength: widget.maxLength,
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {});
        },
        decoration: InputDecoration(
          floatingLabelStyle: context.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.w300,
          ),
          suffix: widget.controller.text.isNotEmpty
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: InkWell(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged('');
                      setState(() {});
                    },
                    child: const Icon(Icons.close, color: Colors.black, size: 20),
                  ),
                )
              : null,
          counter: const SizedBox(),
          contentPadding: EdgeInsets.only(bottom: 15, left: 15, right: 15, top: 15),
          isDense: true,
          focusedBorder: _getFocusedBorder(),
          focusedErrorBorder: _getBorder(_error() != null),
          enabledBorder: _getBorder(_error() != null),
          errorBorder: _getBorder(_error() != null),
          errorText: _error(),
          //labelText: widget.label,
          label: widget.label == null
              ? null
              : Container(color: Colors.white, child: Text(widget.label!)),
          hintText: _focusNode.hasFocus ? '' : widget.hint,
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: context.textTheme.titleLarge?.copyWith(color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  InputBorder? _getFocusedBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: Colors.blue, width: 2),
  );

  InputBorder? _getBorder(bool isError) {
    if (isError) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: context.themeData.colorScheme.error, width: 2),
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: widget.controller.text.isNotEmpty
            ? Colors.blueAccent
            : Colors.blueGrey,
        width: 2,
      ),
    );
  }
}
