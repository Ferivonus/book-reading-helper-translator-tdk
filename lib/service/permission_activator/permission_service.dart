import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request storage permission based on Android version.
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    PermissionStatus status;

    if (sdkInt >= 33) {
      // For Android 13 and above, we request 'manageExternalStorage'
      // because standard 'storage' permission is deprecated for documents.
      status = await Permission.manageExternalStorage.request();
    } else {
      // For Android 12 and below, standard storage permission works.
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      debugPrint("Permission granted.");
      return true;
    } else if (status.isPermanentlyDenied) {
      debugPrint("Permission permanently denied. Opening settings...");
      await openAppSettings();
      return false;
    } else {
      debugPrint("Permission denied.");
      return false;
    }
  }

  static Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      return await Permission.manageExternalStorage.isGranted;
    } else {
      return await Permission.storage.isGranted;
    }
  }
}
