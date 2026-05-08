import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    try {
      // For Android 13+ (Tiramisu), use READ_MEDIA_AUDIO
      if (Platform.isAndroid) {
        // Try READ_MEDIA_AUDIO first (Android 13+)
        final audioStatus = await Permission.audio.request();
        if (audioStatus.isGranted) {
          return true;
        }
        
        // Fallback to READ_EXTERNAL_STORAGE for older Android versions
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          return true;
        }
        
        // If status is denied, return false
        return false;
      }
      
      // For iOS
      if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.request();
        return status.isGranted;
      }
      
      return false;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }
}
