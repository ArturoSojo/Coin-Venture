class FeatureFlags {
  const FeatureFlags({
    this.historyEnabled = true,
    this.settingsEnabled = true,
    this.autoRefreshEnabled = true,
  });

  final bool historyEnabled;
  final bool settingsEnabled;
  final bool autoRefreshEnabled;

  static const defaultFlags = FeatureFlags();
}
