import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

Future<bool> showLocationPermissionRationale(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Use your location?'),
        content: const Text(
          'GoodTooGrab uses your precise location to centre the map on you and show nearby surprise bags. '
          'You can change this any time in system or browser settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
