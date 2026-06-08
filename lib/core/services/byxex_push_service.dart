import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ByxexPushService {
  static const String _appId = 'b72b5a97-182a-4e19-ba15-323b775224b0';

  bool _initialized = false;

  // Singleton
  static final ByxexPushService _instance = ByxexPushService._internal();
  factory ByxexPushService() => _instance;
  ByxexPushService._internal();

  // Simple logger helper
  void _log(String message) => debugPrint('[ByxexPushService] $message');

  // Generic error-safe wrapper
  Future<T?> _safeCall<T>(String action, Future<T?> Function() fn) async {
    try {
      return await fn();
    } catch (e, st) {
      _log('Error during $action: $e');
      if (kDebugMode) {
        _log('$st');
      }
      return null;
    }
  }

  Future<void> init([String userId = '']) async {
    if (_initialized) return;

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      OneSignal.initialize(_appId);

      await _safeCall('setUserIdentity', () async {
        await _setUserIdentity(userId);
        return null;
      });

      await _safeCall('requestPermissions', () async {
        await _requestPermissions();
        return null;
      });

      _setupHandlers();
      _initialized = true;

      _log('Initialized successfully');
    } catch (e) {
      _log('Error initializing: $e');
    }
  }

  Future<void> _setUserIdentity(String userId) async {
    if (userId.isEmpty) return;
    try {
      await OneSignal.login(userId);
      _log('User identity set: $userId');
    } catch (e) {
      _log('Error setting user identity: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
      _log('Requested notification permission');
    } catch (e) {
      _log('Error requesting permissions: $e');
    }
  }

  void _setupHandlers() {
    _setForegroundHandler();
    _setClickHandler();
    _setInAppMessageHandler();
  }

  void _setForegroundHandler() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final notification = event.notification;
      _log('Notification received: ${notification.title}');
    });
  }

  void _setClickHandler() {
    OneSignal.Notifications.addClickListener((event) {
      _log('Notification clicked');
    });
  }

  void _setInAppMessageHandler() {
    OneSignal.InAppMessages.addClickListener((event) {
      _log('In-app message clicked');
    });
  }

  bool _ensureInitialized(String action) {
    if (!_initialized) {
      _log('Warning: not initialized when calling $action');
      return false;
    }
    return true;
  }

  Future<void> setTag(String key, String value) async {
    if (!_ensureInitialized('setTag')) return;
    await _safeCall('setTag', () async {
      await OneSignal.User.addTags({key: value});
      _log('Tag set: $key = $value');
      return null;
    });
  }

  Future<void> removeTag(String key) async {
    if (!_ensureInitialized('removeTag')) return;
    await _safeCall('removeTag', () async {
      await OneSignal.User.removeTag(key);
      _log('Tag removed: $key');
      return null;
    });
  }

  Future<void> setTags(Map<String, String> tags) async {
    if (!_ensureInitialized('setTags')) return;
    await _safeCall('setTags', () async {
      await OneSignal.User.addTags(tags);
      _log('Tags set: ${tags.keys.join(', ')}');
      return null;
    });
  }

  Future<String?> getDeviceId() async {
    if (!_ensureInitialized('getDeviceId')) return null;
    return await _safeCall<String?>('getDeviceId', () async {
      final pushSubscription = OneSignal.User.pushSubscription;
      final deviceId = pushSubscription.id;
      _log('Device ID: $deviceId');
      return deviceId;
    });
  }

  Future<bool> isPermissionGranted() async {
    final result = await _safeCall<bool>('isPermissionGranted', () async {
      final permission = OneSignal.Notifications.permission;
      return permission;
    });
    return result ?? false;
  }

  Future<void> logout() async {
    if (!_initialized) return;
    await _safeCall('logout', () async {
      await OneSignal.logout();
      _initialized = false;
      _log('Logged out from notifications');
      return null;
    });
  }

  void dispose() {
    _initialized = false;
  }
}
