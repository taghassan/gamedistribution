import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gamedistribution/gamedistribution/GameWebViewScreen.dart';
import 'package:gamedistribution/widgets/GridSkeletonLoader.dart';
import 'package:gamedistribution/widgets/ShimmerImage.dart';

import 'game_distribution_logic.dart';
import 'game_distribution_state.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'game_distribution_logic.dart';

class GameDistributionPage
    extends GetView<GameDistributionLogic> {
  const GameDistributionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Games")),
      bottomNavigationBar: controller.loadBannerWidget(),
      body: controller.obx(
            (state) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                controller.loadMore();
              }
              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount:
              state!.games.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.games.length) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final game = state.games[index];

                return GestureDetector(
                  onTap: () {
                    Get.to(() => GameWebViewScreen(
                      gameId: game.objectID,
                      mobileMode: game.mobileMode ?? 'Portrait',
                    ));
                  },
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child: ShimmerImage(
                            imageUrl:
                            "https://img.gamedistribution.com/${game.assets.isNotEmpty ? game.assets.first : ""}",
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        game.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        onLoading: const GridSkeletonLoader(),
        onError: (error) =>
            Center(child: Text("Error: $error")),
        onEmpty:
        const Center(child: Text("No games found")),
      ),
    );
  }
}