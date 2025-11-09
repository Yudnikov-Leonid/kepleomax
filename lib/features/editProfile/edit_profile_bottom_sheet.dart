import 'package:flutter/material.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key});

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Button(text: 'Cancel', onPressed: () {
                Navigator.of(context).pop();
              }),
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              _Button(text: 'Save', fontWeight: FontWeight.w600, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 26),
          KlmTextField(
            controller: _nameController,
            label: 'Username',
            onChanged: (newName) {},
          ),
          const SizedBox(height: 20),
          KlmTextField(
            controller: _descriptionController,
            multiline: true,
            maxLength: 200,
            label: 'Description',
            onChanged: (newName) {},
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.text,
    required this.onPressed,
    this.fontWeight = FontWeight.w500,
  });

  final String text;
  final VoidCallback onPressed;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: context.textTheme.bodyLarge?.copyWith(
          color: KlmColors.primaryColor.shade800,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
