import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/client_model.dart';

/// Storage Service
///
/// Handles secure storage of authentication tokens and user data
/// Falls back to shared_preferences, then file-based storage if needed
class StorageService {
  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences? _prefs;
  final Directory? _storageDir;
  bool _useSecureStorage = true;
  bool _useFileStorage = false;

  StorageService._(this._secureStorage, this._prefs, this._storageDir);

  // Public constructor for creating temporary instances
  StorageService.empty() 
      : _secureStorage = null, 
        _prefs = null, 
        _storageDir = null,
        _useSecureStorage = false,
        _useFileStorage = false;

  /// Factory constructor that tries secure storage first, falls back to shared_preferences, then file storage
  static Future<StorageService> create() async {
    FlutterSecureStorage? secureStorage;
    SharedPreferences? prefs;
    Directory? storageDir;
    bool useSecureStorage = true;
    bool useFileStorage = false;

    try {
      secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
      // Test if secure storage works
      await secureStorage.write(key: '_test', value: 'test');
      await secureStorage.delete(key: '_test');
      developer.log('✅ Using FlutterSecureStorage', name: 'Storage');
    } catch (e) {
      developer.log('⚠️ Secure storage not available, trying SharedPreferences: $e', name: 'Storage');
      useSecureStorage = false;
      secureStorage = null;
      
      try {
        prefs = await SharedPreferences.getInstance();
        developer.log('✅ Using SharedPreferences', name: 'Storage');
      } catch (e2) {
        developer.log('⚠️ SharedPreferences also not available: $e2', name: 'Storage');
        developer.log('⚠️ Trying file-based storage...', name: 'Storage');
        
        try {
          // Use file-based storage as fallback
          final appDir = await getApplicationDocumentsDirectory();
          storageDir = Directory(path.join(appDir.path, 'laapak_storage'));
          if (!await storageDir.exists()) {
            await storageDir.create(recursive: true);
          }
          useFileStorage = true;
          developer.log('✅ Using file-based storage', name: 'Storage');
        } catch (e3) {
          developer.log('⚠️ File storage also not available: $e3', name: 'Storage');
          developer.log('⚠️ Storage will be disabled - session will not persist', name: 'Storage');
          storageDir = null;
        }
      }
    }

    final service = StorageService._(secureStorage, prefs, storageDir);
    service._useSecureStorage = useSecureStorage;
    service._useFileStorage = useFileStorage;
    return service;
  }

  // Storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyClient = 'client_data';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  /// Save JWT token
  Future<void> saveToken(String token) async {
    try {
      if (_useSecureStorage && _secureStorage != null) {
        final secureStorage = _secureStorage;
        await secureStorage.write(key: _keyToken, value: token);
      } else if (_prefs != null) {
        final prefs = _prefs;
        await prefs.setString(_keyToken, token);
      } else if (_useFileStorage && _storageDir != null) {
        final storageDir = _storageDir;
        final file = File(path.join(storageDir.path, _keyToken));
        await file.writeAsString(token);
      } else {
        developer.log('⚠️ No storage available - token not saved', name: 'Storage');
        return;
      }
      developer.log('✅ Token saved successfully', name: 'Storage');
    } catch (e) {
      developer.log('⚠️ Failed to save token: $e', name: 'Storage');
    }
  }

  /// Get saved JWT token
  Future<String?> getToken() async {
    try {
      if (_useSecureStorage && _secureStorage != null) {
        final secureStorage = _secureStorage;
        return await secureStorage.read(key: _keyToken);
      } else if (_prefs != null) {
        final prefs = _prefs;
        return prefs.getString(_keyToken);
      } else if (_useFileStorage && _storageDir != null) {
        final storageDir = _storageDir;
        final file = File(path.join(storageDir.path, _keyToken));
        if (await file.exists()) {
          return await file.readAsString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save client data
  Future<void> saveClient(ClientModel client) async {
    try {
      final json = jsonEncode(client.toJson());
      if (_useSecureStorage && _secureStorage != null) {
        final secureStorage = _secureStorage;
        await secureStorage.write(key: _keyClient, value: json);
      } else if (_prefs != null) {
        final prefs = _prefs;
        await prefs.setString(_keyClient, json);
      } else if (_useFileStorage && _storageDir != null) {
        final storageDir = _storageDir;
        final file = File(path.join(storageDir.path, _keyClient));
        await file.writeAsString(json);
      } else {
        developer.log('⚠️ No storage available - client data not saved', name: 'Storage');
        return;
      }
      developer.log('✅ Client data saved successfully', name: 'Storage');
    } catch (e) {
      developer.log('⚠️ Failed to save client data: $e', name: 'Storage');
    }
  }

  /// Get saved client data
  Future<ClientModel?> getClient() async {
    try {
      String? json;
      if (_useSecureStorage && _secureStorage != null) {
        final secureStorage = _secureStorage;
        json = await secureStorage.read(key: _keyClient);
      } else if (_prefs != null) {
        final prefs = _prefs;
        json = prefs.getString(_keyClient);
      } else if (_useFileStorage && _storageDir != null) {
        final storageDir = _storageDir;
        final file = File(path.join(storageDir.path, _keyClient));
        if (await file.exists()) {
          json = await file.readAsString();
        }
      }
      
      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return ClientModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    try {
      if (_useSecureStorage && _secureStorage != null) {
        final secureStorage = _secureStorage;
        await secureStorage.delete(key: _keyToken);
        await secureStorage.delete(key: _keyClient);
      } else if (_prefs != null) {
        final prefs = _prefs;
        await prefs.remove(_keyToken);
        await prefs.remove(_keyClient);
      } else if (_useFileStorage && _storageDir != null) {
        final storageDir = _storageDir;
        final tokenFile = File(path.join(storageDir.path, _keyToken));
        final clientFile = File(path.join(storageDir.path, _keyClient));
        if (await tokenFile.exists()) await tokenFile.delete();
        if (await clientFile.exists()) await clientFile.delete();
      }
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  /// Check if user is logged in (has token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save notification enabled preference
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (_useSecureStorage && _secureStorage != null) {
        final secureStorage = _secureStorage;
        await secureStorage.write(
          key: _keyNotificationsEnabled,
          value: enabled.toString(),
        );
      } else if (_prefs != null) {
        final prefs = _prefs;
        await prefs.setBool(_keyNotificationsEnabled, enabled);
      } else if (_useFileStorage && _storageDir != null) {
        final storageDir = _storageDir;
        final file = File(path.join(storageDir.path, _keyNotificationsEnabled));
        await file.writeAsString(enabled.toString());
      }
      developer.log('✅ Notification preference saved: $enabled', name: 'Storage');
    } catch (e) {
      developer.log('⚠️ Failed to save notification preference: $e', name: 'Storage');
    }
  }

  /// Get notification enabled preference (defaults to true if not set)
  Future<bool> getNotificationsEnabled() async {
    try {
      if (_useSecureStorage && _secureStorage != null) {
        final secureStorage = _secureStorage;
        final value = await secureStorage.read(key: _keyNotificationsEnabled);
        return value == 'true';
      } else if (_prefs != null) {
        final prefs = _prefs;
        return prefs.getBool(_keyNotificationsEnabled) ?? true; // Default to enabled
      } else if (_useFileStorage && _storageDir != null) {
        final storageDir = _storageDir;
        final file = File(path.join(storageDir.path, _keyNotificationsEnabled));
        if (await file.exists()) {
          final value = await file.readAsString();
          return value == 'true';
        }
      }
      return true; // Default to enabled
    } catch (e) {
      return true; // Default to enabled on error
    }
  }
}

