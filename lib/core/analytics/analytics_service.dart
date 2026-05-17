import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_event.dart';

abstract class AnalyticsService {
  void track(AnalyticsEvent event);
}

class DebugAnalyticsService implements AnalyticsService {
  @override
  void track(AnalyticsEvent event) {
    if (kDebugMode) {
      debugPrint('[analytics] ${event.name} ${event.properties}');
    }
  }
}

final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => DebugAnalyticsService());