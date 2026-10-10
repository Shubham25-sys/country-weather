class Formatters {
  Formatters._();

  /// 1428627663 -> "1.43B", 41798407 -> "41.8M", 12500 -> "12.5K".
  static String compactNumber(int? value) {
    if (value == null) return 'N/A';
    if (value >= 1000000000) return '${_trim(value / 1000000000)}B';
    if (value >= 1000000) return '${_trim(value / 1000000)}M';
    if (value >= 1000) return '${_trim(value / 1000)}K';
    return value.toString();
  }

  /// 41798407 -> "41,798,407".
  static String groupedNumber(int? value) {
    if (value == null) return 'N/A';
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
  }

  /// 20.5937 -> "20.5937° N".
  static String latitude(double value) =>
      '${value.abs().toStringAsFixed(4)}° ${value >= 0 ? 'N' : 'S'}';

  static String longitude(double value) =>
      '${value.abs().toStringAsFixed(4)}° ${value >= 0 ? 'E' : 'W'}';

  static String _trim(double value) {
    final fixed = value.toStringAsFixed(value >= 100 ? 0 : (value >= 10 ? 1 : 2));
    return fixed.contains('.') ? fixed.replaceAll(RegExp(r'\.?0+$'), '') : fixed;
  }
}
