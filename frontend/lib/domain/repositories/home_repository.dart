import 'package:frontend/data/models/home_models.dart';

abstract interface class HomeRepository {
  /// GET /api/home
  Future<HomeResult> getHomeData();
}