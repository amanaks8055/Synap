// lib/services/extension_sync_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blocs/tracker/tracker_bloc.dart';
import '../blocs/tracker/tracker_event.dart';

class ExtensionSyncService {
  final TrackerBloc trackerBloc;
  Timer? _timer;
  DateTime? _lastSync;
  bool _running = false;

  ExtensionSyncService(this.trackerBloc);

  void start() {
    if (_running) return;
    _running = true;
    _sync();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _sync());
  }

  void stop() {
    _timer?.cancel();
    _running = false;
  }

  Future<void> _sync() async {
    try {
      final uid = await _getUid();
      final res = await Supabase.instance.client
          .from('extension_sync')
          .select('payload, updated_at')
          .eq('user_id', uid)
          .maybeSingle();

      if (res == null) {
        return;
      }

      // Naya data hai to hi update karo
      final updatedAt = DateTime.tryParse(
          res['updated_at'] as String? ?? '');
      if (updatedAt != null &&
          _lastSync != null &&
          !updatedAt.isAfter(_lastSync!)) {
        return;
      }

      _lastSync = updatedAt ?? DateTime.now();

      final payload = res['payload'] as Map<String, dynamic>;
      payload.forEach((toolId, data) {
        if (data is Map && data['used'] != null) {
          trackerBloc.add(
            TrackerUsageSet(toolId, (data['used'] as num).toInt()));
        }
      });

      debugPrint('[Sync] Extension data updated ✓');
    } catch (e) {
      // Silent fail — extension install nahi hai toh chalega
      debugPrint('[Sync] Skipped: $e');
    }
  }

  Future<String> _getUid() async {
    final prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('synap_ext_uid');
    if (uid != null) return uid;
    uid = 'ext_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    await prefs.setString('synap_ext_uid', uid);
    return uid;
  }

  Future<void> forceSync() => _sync();
}
