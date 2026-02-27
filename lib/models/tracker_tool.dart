enum ResetPeriod { threeHours, daily, weekly, monthly }
enum UsageUnit   { messages, credits, queries, images, minutes }

class TrackerTool {
  final String id;
  final String name;
  final String emoji;
  final int freeLimit;
  final UsageUnit unit;
  final ResetPeriod resetPeriod;
  final String tipWhenLow;
  final String switchTo;
  final int colorHex;

  int      usedCount;
  DateTime? lastResetTime;
  bool     isPinned;
  bool     isTracking;

  TrackerTool({
    required this.id,
    required this.name,
    required this.emoji,
    required this.freeLimit,
    required this.unit,
    required this.resetPeriod,
    required this.tipWhenLow,
    required this.switchTo,
    required this.colorHex,
    this.usedCount    = 0,
    this.lastResetTime,
    this.isPinned     = false,
    this.isTracking   = false,
  });

  int    get remaining    => (freeLimit - usedCount).clamp(0, freeLimit);
  double get usagePct     => (usedCount / freeLimit).clamp(0.0, 1.0);
  bool   get isExhausted  => usedCount >= freeLimit;
  bool   get isLow        => usagePct >= 0.8 && !isExhausted;
  bool   get isHealthy    => usagePct < 0.5;

  String get unitShort {
    switch (unit) {
      case UsageUnit.messages: return 'msgs';
      case UsageUnit.credits:  return 'credits';
      case UsageUnit.queries:  return 'queries';
      case UsageUnit.images:   return 'images';
      case UsageUnit.minutes:  return 'mins';
    }
  }

  Duration get resetDuration {
    switch (resetPeriod) {
      case ResetPeriod.threeHours: return const Duration(hours: 3);
      case ResetPeriod.daily:      return const Duration(hours: 24);
      case ResetPeriod.weekly:     return const Duration(days: 7);
      case ResetPeriod.monthly:    return const Duration(days: 30);
    }
  }

  bool get shouldAutoReset {
    if (lastResetTime == null) return false;
    return DateTime.now().isAfter(lastResetTime!.add(resetDuration));
  }

  Duration get timeUntilReset {
    if (lastResetTime == null) return Duration.zero;
    final next = lastResetTime!.add(resetDuration);
    final diff = next.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get countdownLabel {
    final d = timeUntilReset;
    if (d == Duration.zero) return 'Ready to reset!';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }

  String get resetPeriodLabel {
    switch (resetPeriod) {
      case ResetPeriod.threeHours: return 'Resets every 3h';
      case ResetPeriod.daily:      return 'Resets daily';
      case ResetPeriod.weekly:     return 'Resets weekly';
      case ResetPeriod.monthly:    return 'Resets monthly';
    }
  }

  TrackerTool copyWith({
    int?      usedCount,
    DateTime? lastResetTime,
    bool?     isPinned,
    bool?     isTracking,
  }) => TrackerTool(
    id: id, name: name, emoji: emoji, freeLimit: freeLimit,
    unit: unit, resetPeriod: resetPeriod, tipWhenLow: tipWhenLow,
    switchTo: switchTo, colorHex: colorHex,
    usedCount:     usedCount     ?? this.usedCount,
    lastResetTime: lastResetTime ?? this.lastResetTime,
    isPinned:      isPinned      ?? this.isPinned,
    isTracking:    isTracking    ?? this.isTracking,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'usedCount': usedCount,
    'lastResetTime': lastResetTime?.toIso8601String(),
    'isPinned': isPinned,
    'isTracking': isTracking,
  };

  TrackerTool withSavedData(Map<String, dynamic> json) => copyWith(
    usedCount:     json['usedCount']     as int?  ?? 0,
    lastResetTime: json['lastResetTime'] != null
        ? DateTime.parse(json['lastResetTime'] as String) : null,
    isPinned:      json['isPinned']      as bool? ?? false,
    isTracking:    json['isTracking']    as bool? ?? false,
  );
}

// ── Default tool catalog ──────────────────────────────────────
class TrackerCatalog {
  static List<TrackerTool> get all => [
    TrackerTool(
      id: 'chatgpt_gpt4o', name: 'ChatGPT GPT-4o', emoji: '🤖',
      freeLimit: 40, unit: UsageUnit.messages, resetPeriod: ResetPeriod.threeHours,
      tipWhenLow: 'Switch to Claude — same quality, fresh daily limit',
      switchTo: 'Claude', colorHex: 0xFF10A37F,
    ),
    TrackerTool(
      id: 'claude', name: 'Claude Sonnet', emoji: '✦',
      freeLimit: 40, unit: UsageUnit.messages, resetPeriod: ResetPeriod.daily,
      tipWhenLow: 'Switch to ChatGPT or Gemini for rest of today',
      switchTo: 'ChatGPT', colorHex: 0xFFD97706,
    ),
    TrackerTool(
      id: 'gemini', name: 'Gemini Pro', emoji: '♊',
      freeLimit: 60, unit: UsageUnit.queries, resetPeriod: ResetPeriod.daily,
      tipWhenLow: 'Switch to Perplexity for research queries',
      switchTo: 'Perplexity', colorHex: 0xFF4285F4,
    ),
    TrackerTool(
      id: 'perplexity', name: 'Perplexity Pro', emoji: '🔍',
      freeLimit: 5, unit: UsageUnit.queries, resetPeriod: ResetPeriod.daily,
      tipWhenLow: 'Use Gemini or standard Perplexity for remaining searches',
      switchTo: 'Gemini', colorHex: 0xFF20B2AA,
    ),
    TrackerTool(
      id: 'midjourney', name: 'Midjourney', emoji: '🎨',
      freeLimit: 25, unit: UsageUnit.images, resetPeriod: ResetPeriod.monthly,
      tipWhenLow: 'Switch to Ideogram or Adobe Firefly — both free',
      switchTo: 'Ideogram', colorHex: 0xFF7C3AED,
    ),
    TrackerTool(
      id: 'suno', name: 'Suno AI', emoji: '🎵',
      freeLimit: 50, unit: UsageUnit.credits, resetPeriod: ResetPeriod.daily,
      tipWhenLow: 'Try Udio for remaining music generations today',
      switchTo: 'Udio', colorHex: 0xFFEC4899,
    ),
    TrackerTool(
      id: 'cursor', name: 'Cursor AI', emoji: '⌨️',
      freeLimit: 2000, unit: UsageUnit.messages, resetPeriod: ResetPeriod.monthly,
      tipWhenLow: 'Switch to GitHub Copilot free tier',
      switchTo: 'GitHub Copilot', colorHex: 0xFF06B6D4,
    ),
    TrackerTool(
      id: 'gamma', name: 'Gamma App', emoji: '📊',
      freeLimit: 10, unit: UsageUnit.credits, resetPeriod: ResetPeriod.monthly,
      tipWhenLow: 'Try Canva AI presentations',
      switchTo: 'Canva AI', colorHex: 0xFF8B5CF6,
    ),
  ];
}
