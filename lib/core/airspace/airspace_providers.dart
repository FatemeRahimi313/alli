import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/airspace/air_object.dart';
import '../../data/models/airspace/airspace_status.dart';
import '../providers.dart';
import 'airspace_service.dart';

final airspaceServiceProvider = Provider<AirspaceService>((ref) {
  return AirspaceService();
});

final airspaceObjectsProvider =
    StateNotifierProvider<AirspaceNotifier, AsyncValue<List<AirObject>>>((ref) {
  return AirspaceNotifier(ref);
});

final airspaceSnapshotProvider = Provider<AirspaceSnapshot>((ref) {
  final objectsAsync = ref.watch(airspaceObjectsProvider);
  final online = ref.watch(connectivityProvider);
  return objectsAsync.when(
    data: (list) => ref.read(airspaceServiceProvider).evaluate(list, online: online),
    loading: () => const AirspaceSnapshot(
      status: AirspaceOverallStatus.normal,
      dataLinkOnline: true,
      message: 'LOADING...',
    ),
    error: (_, __) => AirspaceSnapshot.offline(message: 'DATA LINK ERROR'),
  );
});

/// Simple connectivity flag (true = assume online until proven otherwise)
final connectivityProvider = StateProvider<bool>((ref) => true);

class AirspaceNotifier extends StateNotifier<AsyncValue<List<AirObject>>> {
  final Ref _ref;
  AirspaceNotifier(this._ref) : super(const AsyncValue.data([]));

  Future<void> refresh() async {
    final settings = _ref.read(settingsProvider);
    if (!settings.alertsEnabled ||
        settings.homeLat == null ||
        settings.homeLon == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _ref.read(airspaceServiceProvider).fetchNearby(
            centerLat: settings.homeLat!,
            centerLon: settings.homeLon!,
            radiusKm: settings.alertRadiusKm,
          );
      _ref.read(connectivityProvider.notifier).state = true;
      state = AsyncValue.data(list);
    } catch (e, st) {
      _ref.read(connectivityProvider.notifier).state = false;
      // Keep last good data if available, mark stale conceptually via snapshot
      if (state.hasValue && state.value!.isNotEmpty) {
        // leave previous data, only update connectivity
        state = AsyncValue.data(state.value!);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void clearHistory() {
    _ref.read(airspaceServiceProvider).clearHistory();
    state = const AsyncValue.data([]);
  }
}
