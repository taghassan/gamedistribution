import 'package:ads_manager/ads_service.dart';
import 'package:get/get.dart';
import 'package:gamedistribution/GameModel.dart';
import 'package:gamedistribution/gamedistribution/GameService.dart';

import 'game_distribution_state.dart';

class GameDistributionLogic extends GetxController
    with StateMixin<GameDistributionState>,InterstitialAdState,HasBannerAd {

  final GameService _service = GameService();

  @override
  void onInit() {
    super.onInit();
    loadInterstitialAdAd(interstitialAdId: 'ca-app-pub-8107574011529731/7525150969');
    Future.delayed(
      Duration.zero,
          () {
        loadBannerAd(forceUseId: 'ca-app-pub-8107574011529731/7844715163');
      },
    );
    // loadInitial();
  }

  Future<void> loadInitial() async {
    change(null, status: RxStatus.loading());

    try {
      final result = await _service.fetchGames(0);

      final games = (result['hits'] as List)
          .map((e) => Game.fromJson(e))
          .toList();

      change(
        GameDistributionState(
          games: games,
          page: result['page'],
          nbPages: result['nbPages'],
        ),
        status: RxStatus.success(),
      );
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current == null || !current.hasMore) return;

    final nextPage = current.page + 1;

    final result = await _service.fetchGames(nextPage);

    final newGames = (result['hits'] as List)
        .map((e) => Game.fromJson(e))
        .toList();

    change(
      current.copyWith(
        games: [...current.games, ...newGames],
        page: result['page'],
      ),
      status: RxStatus.success(),
    );
  }
}