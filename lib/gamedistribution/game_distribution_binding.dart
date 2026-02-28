import 'package:get/get.dart';

import 'game_distribution_logic.dart';

class GameDistributionBinding extends Bindings {
  String? interstitialAdId;
  String? bannerAdId;
  GameDistributionBinding({this.bannerAdId,this.interstitialAdId});
  @override
  void dependencies() {
    Get.lazyPut(() => GameDistributionLogic(
      interstitialAdId: interstitialAdId,
      bannerAdId: bannerAdId
    ));
  }
}
