import 'package:get/get.dart';

import 'game_distribution_logic.dart';

class GameDistributionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GameDistributionLogic());
  }
}
