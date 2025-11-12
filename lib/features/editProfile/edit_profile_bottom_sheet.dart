import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/validators.dart';
import 'package:kepleomax/main.dart';

import '../../core/presentation/caching_image.dart';
import '../../core/presentation/user_image.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({
    required this.profile,
    required this.onSave,
    super.key,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isClosing = false;
  bool _isButtonPressed = false;
  bool _isImageEdited = false;
  String? _imageUrl;

  @override
  void initState() {
    final user = widget.profile.user;
    _imageUrl = user.profileImage.isEmpty ? null : user.profileImage;
    _nameController.text = user.username;
    _descriptionController.text = widget.profile.description;
    super.initState();
  }

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
              _Button(
                text: 'Cancel',
                onPressed: _isClosing
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
              ),
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 4),
                    child: ClipOval(
                      child: _imageUrl == null
                          ? DefaultUserIcon()
                          : _isImageEdited
                          ? Image.file(File(_imageUrl!), fit: BoxFit.cover)
                          : KlmCachedImage(
                              imageUrl: flavor.imageUrl + _imageUrl!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton.filled(
                      onPressed: _isClosing ? null : _editImage,
                      icon: Icon(Icons.edit),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(5),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton.filled(
                      onPressed: _isClosing ? null : _removeImage,
                      icon: Icon(Icons.close, fontWeight: FontWeight.w600),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.all(5),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
                ],
              ),
              _Button(
                text: 'Save',
                fontWeight: FontWeight.w600,
                onPressed: _isClosing
                    ? null
                    : () {
                        setState(() {
                          _isButtonPressed = true;
                        });

                        /// TODO fix dry with validators (also used below in KlmTextField)
                        if (UiValidator.emptyValidator(_nameController.text) !=
                            null) {
                          return;
                        }

                        setState(() {
                          _isClosing = true;
                        });
                        final oldProfile = widget.profile;
                        final newProfile = oldProfile.copyWith(
                          description: _descriptionController.text,
                          user: oldProfile.user.copyWith(
                            username: _nameController.text,
                            profileImage: _isImageEdited
                                ? _imageUrl ?? ''
                                : oldProfile.user.profileImage,
                          ),
                        );
                        widget.onSave(newProfile);
                        Navigator.of(context).pop();
                      },
              ),
            ],
          ),
          const SizedBox(height: 26),
          KlmTextField(
            controller: _nameController,
            label: 'Username',
            onChanged: (newName) {},
            readOnly: _isClosing,
            showErrors: _isButtonPressed,
            validators: [UiValidator.emptyValidator],
          ),
          const SizedBox(height: 20),
          KlmTextField(
            controller: _descriptionController,
            multiline: true,
            maxLength: 200,
            label: 'Description',
            onChanged: (newName) {},
            showErrors: _isButtonPressed,
            readOnly: _isClosing,
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Future<void> _removeImage() async {
    setState(() {
      _imageUrl = null;
      _isImageEdited = true;
    });
  }

  Future<void> _editImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _imageUrl = image.path;
        _isImageEdited = true;
      });
    }
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.text,
    required this.onPressed,
    this.fontWeight = FontWeight.w500,
  });

  final String text;
  final VoidCallback? onPressed;
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
