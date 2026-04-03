import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

typedef PhotoActionCallback = void Function(String? photoPath);

Future<void> showPhotoActionPopup({
  required BuildContext context,
  required bool hasPhoto,
  required PhotoActionCallback onResult,
  BuildContext? targetContext,
}) {
  return showGlassPopup(
    context: context,
    targetContext: targetContext,
    targetOffset: Offset(MediaQuery.of(context).size.width * 0.33, -AppSpacing.xs),
    items: [
      GlassPopupItem(
        label: tr(LocaleKeys.meal_take_photo),
        icon: CupertinoIcons.camera,
        onTap: () {
          Navigator.of(context).pop();
          _pickPhoto(context, ImageSource.camera, onResult);
        },
      ),
      GlassPopupItem(
        label: tr(LocaleKeys.meal_upload_photo),
        icon: CupertinoIcons.photo_on_rectangle,
        onTap: () {
          Navigator.of(context).pop();
          _pickPhoto(context, ImageSource.gallery, onResult);
        },
      ),
      if (hasPhoto)
        GlassPopupItem(
          label: tr(LocaleKeys.meal_remove_photo),
          icon: CupertinoIcons.trash,
          color: AppColors.error,
          onTap: () {
            Navigator.of(context).pop();
            onResult(null);
          },
        ),
    ],
  );
}

Future<void> _pickPhoto(BuildContext context, ImageSource source, PhotoActionCallback onResult) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: source);
  print('[PhotoPopup] pickImage result: ${image?.path}');
  if (image == null) return;
  final storedPath = await MediaStorage.persistMealPhoto(image.path);
  print('[PhotoPopup] persistMealPhoto result: $storedPath');
  if (storedPath == null) return;
  print('[PhotoPopup] calling onResult with: $storedPath');
  onResult(storedPath);
}
