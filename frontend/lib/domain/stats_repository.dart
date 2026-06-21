import 'package:frontend/data/models/stats_models.dart';

abstract interface class StatsRepository {
  Future<StatsResult> getStats();
}
