import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/tracker_tool.dart';
import 'tracker_event.dart';
import 'tracker_state.dart';

const _kPrefix = 'synap_tracker_';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  Timer? _autoResetTimer;
  final _notifs = FlutterLocalNotificationsPlugin();

  TrackerBloc() : super(TrackerState.initial()) {
    on<TrackerLoaded>(_onLoad);
    on<TrackerUsageLogged>(_onUsageLogged);
    on<TrackerUsageSet>(_onUsageSet);
    on<TrackerManualReset>(_onManualReset);
    on<TrackerAutoResetChecked>(_onAutoResetCheck);
    on<TrackerToolToggled>(_onToolToggled);
    on<TrackerToolPinned>(_onToolPinned);
    on<TrackerCustomToolAdded>(_onCustomToolAdded);

    _initNotifs();
    add(TrackerLoaded());

    _autoResetTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => add(TrackerAutoResetChecked()),
    );
  }

  Future<void> _initNotifs() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings();
    await _notifs.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> _sendNotif({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const android = AndroidNotificationDetails(
      'synap_tracker', 'Free Tier Alerts',
      channelDescription: 'AI tool usage alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _notifs.show(
      id, title, body,
      const NotificationDetails(android: android),
    );
  }

  Future<void> _onLoad(TrackerLoaded e, Emitter<TrackerState> emit) async {
    emit(state.copyWith(status: TrackerStatus.loading));
    final prefs = await SharedPreferences.getInstance();
    final tools = TrackerCatalog.all.map((tool) {
      final raw = prefs.getString('$_kPrefix${tool.id}');
      if (raw == null) return tool;
      try {
        return tool.withSavedData(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        return tool;
      }
    }).toList();
    emit(state.copyWith(status: TrackerStatus.ready, tools: tools));
    add(TrackerAutoResetChecked());
  }

  Future<void> _onUsageLogged(
      TrackerUsageLogged e, Emitter<TrackerState> emit) async {
    final tools = _copyTools();
    final idx   = tools.indexWhere((t) => t.id == e.toolId);
    if (idx == -1) return;

    final tool       = tools[idx];
    final wasLow     = tool.isLow;
    final wasExhausted = tool.isExhausted;

    tools[idx] = tool.copyWith(
      usedCount:     (tool.usedCount + e.count).clamp(0, tool.freeLimit),
      lastResetTime: tool.lastResetTime ?? DateTime.now(),
    );

    await _saveTool(tools[idx]);

    if (!wasLow && tools[idx].isLow) {
      await _sendNotif(
        id: idx,
        title: '⚠️ ${tools[idx].name} running low!',
        body:  '${tools[idx].remaining} ${tools[idx].unitShort} left. ${tools[idx].tipWhenLow}',
      );
    }
    if (!wasExhausted && tools[idx].isExhausted) {
      await _sendNotif(
        id: idx + 100,
        title: '🔴 ${tools[idx].name} limit reached!',
        body:  'Resets in ${tools[idx].countdownLabel}. Switch to ${tools[idx].switchTo}.',
      );
    }

    emit(state.copyWith(
      tools:       tools,
      alertToolId: tools[idx].isLow || tools[idx].isExhausted
          ? tools[idx].id : null,
    ));
  }

  Future<void> _onUsageSet(
      TrackerUsageSet e, Emitter<TrackerState> emit) async {
    final tools = _copyTools();
    final idx   = tools.indexWhere((t) => t.id == e.toolId);
    if (idx == -1) return;
    tools[idx] = tools[idx].copyWith(
      usedCount:     e.count.clamp(0, tools[idx].freeLimit),
      lastResetTime: tools[idx].lastResetTime ?? DateTime.now(),
    );
    await _saveTool(tools[idx]);
    emit(state.copyWith(tools: tools));
  }

  Future<void> _onManualReset(
      TrackerManualReset e, Emitter<TrackerState> emit) async {
    final tools = _copyTools();
    final idx   = tools.indexWhere((t) => t.id == e.toolId);
    if (idx == -1) return;
    tools[idx] = tools[idx].copyWith(
      usedCount: 0, lastResetTime: DateTime.now(),
    );
    await _saveTool(tools[idx]);
    await _sendNotif(
      id: idx + 200,
      title: '✅ ${tools[idx].name} reset!',
      body:  '${tools[idx].freeLimit} ${tools[idx].unitShort} available again.',
    );
    emit(state.copyWith(tools: tools, clearAlert: true));
  }

  Future<void> _onAutoResetCheck(
      TrackerAutoResetChecked e, Emitter<TrackerState> emit) async {
    final tools  = _copyTools();
    bool changed = false;
    for (int i = 0; i < tools.length; i++) {
      final t = tools[i];
      if (t.isTracking && t.shouldAutoReset && t.usedCount > 0) {
        tools[i] = t.copyWith(usedCount: 0, lastResetTime: DateTime.now());
        await _saveTool(tools[i]);
        changed = true;
        await _sendNotif(
          id: i + 300,
          title: '🔄 ${tools[i].name} reset!',
          body:  '${tools[i].freeLimit} ${tools[i].unitShort} are back. Go create!',
        );
      }
    }
    if (changed) emit(state.copyWith(tools: tools, clearAlert: true));
  }

  Future<void> _onToolToggled(
      TrackerToolToggled e, Emitter<TrackerState> emit) async {
    final tools = _copyTools();
    final idx   = tools.indexWhere((t) => t.id == e.toolId);
    if (idx == -1) return;
    tools[idx] = tools[idx].copyWith(isTracking: !tools[idx].isTracking);
    if (tools[idx].isTracking && tools[idx].lastResetTime == null) {
      tools[idx] = tools[idx].copyWith(lastResetTime: DateTime.now());
    }
    await _saveTool(tools[idx]);
    emit(state.copyWith(tools: tools));
  }

  Future<void> _onToolPinned(
      TrackerToolPinned e, Emitter<TrackerState> emit) async {
    final tools = _copyTools();
    final idx   = tools.indexWhere((t) => t.id == e.toolId);
    if (idx == -1) return;
    tools[idx] = tools[idx].copyWith(isPinned: !tools[idx].isPinned);
    await _saveTool(tools[idx]);
    emit(state.copyWith(tools: tools));
  }

  Future<void> _onCustomToolAdded(
      TrackerCustomToolAdded e, Emitter<TrackerState> emit) async {
    final custom = TrackerTool(
      id:           'custom_${DateTime.now().millisecondsSinceEpoch}',
      name:         e.name,
      emoji:        e.emoji,
      freeLimit:    e.freeLimit,
      unit:         UsageUnit.credits,
      resetPeriod:  ResetPeriod.daily,
      tipWhenLow:   'You are running low on ${e.name}',
      switchTo:     'another tool',
      colorHex:     0xFF6EE7F7,
      isTracking:   true,
      lastResetTime: DateTime.now(),
    );
    final tools = [..._copyTools(), custom];
    await _saveTool(custom);
    emit(state.copyWith(tools: tools));
  }

  List<TrackerTool> _copyTools() =>
      state.tools.map((t) => t.copyWith()).toList();

  Future<void> _saveTool(TrackerTool t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kPrefix${t.id}', jsonEncode(t.toJson()));
  }

  @override
  Future<void> close() {
    _autoResetTimer?.cancel();
    return super.close();
  }
}
