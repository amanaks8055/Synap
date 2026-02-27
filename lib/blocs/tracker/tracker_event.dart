abstract class TrackerEvent { const TrackerEvent(); }

class TrackerLoaded extends TrackerEvent {}

class TrackerUsageLogged extends TrackerEvent {
  final String toolId;
  final int count;
  const TrackerUsageLogged(this.toolId, {this.count = 1});
}

class TrackerUsageSet extends TrackerEvent {
  final String toolId;
  final int count;
  const TrackerUsageSet(this.toolId, this.count);
}

class TrackerManualReset extends TrackerEvent {
  final String toolId;
  const TrackerManualReset(this.toolId);
}

class TrackerAutoResetChecked extends TrackerEvent {}

class TrackerToolToggled extends TrackerEvent {
  final String toolId;
  const TrackerToolToggled(this.toolId);
}

class TrackerToolPinned extends TrackerEvent {
  final String toolId;
  const TrackerToolPinned(this.toolId);
}

class TrackerCustomToolAdded extends TrackerEvent {
  final String name;
  final String emoji;
  final int freeLimit;
  const TrackerCustomToolAdded({
    required this.name,
    required this.emoji,
    required this.freeLimit,
  });
}
