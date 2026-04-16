import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveAuthenticationKeyManager extends FlutterAuthenticationKeyManager {
  static const _boxName = 'auth_box';
  static const _keyName = 'auth_key';

  @override
  Future<String?> get() async {
    final box = await Hive.openBox(_boxName);
    final String? key = box.get(_keyName);
    final cleaned = _cleanKey(key);
    print('DEBUG: HiveKeyManager.get() -> |$cleaned|');
    return cleaned;
  }

  @override
  Future<void> put(String key) async {
    print('DEBUG: HiveKeyManager.put() called with: |$key|');
    final cleaned = _cleanKey(key);
    if (cleaned == null) {
      print('DEBUG: HiveKeyManager - KEY REJECTED: Validation failed for |$key|');
      return;
    }

    final box = await Hive.openBox(_boxName);
    print('DEBUG: HiveKeyManager - Internal box state before clear: ${box.get(_keyName)}');
    
    // Explicitly clear to avoid any weird persistence issues
    await box.clear();
    await box.put(_keyName, cleaned);
    
    print('DEBUG: HiveKeyManager - SUCCESS: New key stored: |$cleaned|');
  }

  @override
  Future<void> remove() async {
    print('DEBUG: HiveKeyManager.remove()');
    final box = await Hive.openBox(_boxName);
    await box.delete(_keyName);
  }

  @override
  Future<String?> toHeaderValue([String? authenticationKey]) async {
    // Both get() and the parameter are now subject to cleaning
    final String? rawKey =
        (authenticationKey != null && authenticationKey.isNotEmpty)
        ? authenticationKey
        : await get();

    final String? clean = _cleanKey(rawKey);
    if (clean == null) return null;

    final header = 'Bearer $clean';
    print('DEBUG: HiveKeyManager.toHeaderValue() -> |$header|');
    return header;
  }

  String? _cleanKey(String? rawKey) {
    if (rawKey == null) return null;

    // 1. Initial trim
    String cleaning = rawKey.trim();

    // 2. EXPLICITLY strip "Bearer " if it's there (common source of 401/500 errors)
    if (cleaning.toLowerCase().startsWith('bearer ')) {
      cleaning = cleaning.substring(7).trim();
    }

    // 3. Remove non-printable control chars and quotes
    final cleanKey = cleaning
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(RegExp(r'[^\x21-\x7E]'), '') // ASCII 33-126 (no spaces)
        .replaceAll(' ', '');

    if (cleanKey.isEmpty) return null;

    // Validation: Expect "id:key"
    final colonIndex = cleanKey.indexOf(':');
    if (colonIndex <= 0 || colonIndex == cleanKey.length - 1) {
      print(
        'WARNING: HiveKeyManager - Key format unexpected (no colon), returning raw: |$cleanKey|',
      );
      return cleanKey;
    }

    final idPart = cleanKey.substring(0, colonIndex);
    if (int.tryParse(idPart) == null) {
      print(
        'DEBUG: HiveKeyManager - Malformed key (ID not integer): |$cleanKey|',
      );
      return null;
    }

    return cleanKey;
  }
}
