import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveAuthenticationKeyManager extends FlutterAuthenticationKeyManager {
  static const _boxName = 'auth_box';
  static const _keyName = 'auth_key';

  Box? _box;

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<String?> get() async {
    final box = await _getBox();
    final String? key = box.get(_keyName);
    final cleaned = _cleanKey(key);
    return cleaned;
  }

  @override
  Future<void> put(String key) async {
    final cleaned = _cleanKey(key);
    if (cleaned == null) return;
    final box = await _getBox();
    await box.put(_keyName, cleaned);
  }

  @override
  Future<void> remove() async {
    final box = await _getBox();
    await box.delete(_keyName);
  }

  @override
  Future<String?> toHeaderValue([String? key]) async {
    final String? rawKey =
        (key != null && key.isNotEmpty)
        ? key
        : await get();

    final String? clean = _cleanKey(rawKey);
    if (clean == null) return null;

    return 'Bearer $clean';
  }

  String? _cleanKey(String? rawKey) {
    if (rawKey == null) return null;

    String cleaning = rawKey.trim();

    if (cleaning.toLowerCase().startsWith('bearer ')) {
      cleaning = cleaning.substring(7).trim();
    }

    final cleanKey = cleaning
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(RegExp(r'\s+'), '');

    if (cleanKey.isEmpty) return null;

    final colonIndex = cleanKey.indexOf(':');
    if (colonIndex <= 0 || colonIndex == cleanKey.length - 1) {
      return cleanKey;
    }

    final idPart = cleanKey.substring(0, colonIndex);
    if (int.tryParse(idPart) == null) {
      return null;
    }

    return cleanKey;
  }
}
