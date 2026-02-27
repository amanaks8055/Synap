import '../../models/tracker_tool.dart';

enum TrackerStatus { initial, loading, ready, error }

class TrackerState {
  final TrackerStatus status;
  final List<TrackerTool> tools;
  final String? alertToolId;
  final String? errorMessage;

  const TrackerState({
    required this.status,
    required this.tools,
    this.alertToolId,
    this.errorMessage,
  });

  factory TrackerState.initial() => const TrackerState(
    status: TrackerStatus.initial,
    tools: [],
  );

  List<TrackerTool> get activeTools =>
      tools.where((t) => t.isTracking).toList()
        ..sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          if (a.isExhausted && !b.isExhausted) return 1;
          if (!a.isExhausted && b.isExhausted) return -1;
          return b.usagePct.compareTo(a.usagePct);
        });

  List<TrackerTool> get exhaustedTools =>
      activeTools.where((t) => t.isExhausted).toList();

  List<TrackerTool> get lowTools =>
      activeTools.where((t) => t.isLow).toList();

  List<TrackerTool> get healthyTools =>
      activeTools.where((t) => t.isHealthy).toList();

  List<TrackerTool> get catalogTools =>
      tools.where((t) => !t.isTracking).toList();

  TrackerTool? get bestToolNow {
    final healthy = activeTools
        .where((t) => !t.isExhausted && t.isHealthy)
        .toList();
    if (healthy.isEmpty) return null;
    return healthy.reduce((a, b) => a.remaining > b.remaining ? a : b);
  }

  TrackerState copyWith({
    TrackerStatus? status,
    List<TrackerTool>? tools,
    String? alertToolId,
    String? errorMessage,
    bool clearAlert = false,
  }) => TrackerState(
    status:       status       ?? this.status,
    tools:        tools        ?? this.tools,
    alertToolId:  clearAlert   ? null : (alertToolId ?? this.alertToolId),
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
