import 'package:gamedistribution/GameModel.dart';

class GameDistributionState {
  final List<Game> games;
  final int page;
  final int nbPages;

  GameDistributionState({
    required this.games,
    required this.page,
    required this.nbPages,
  });

  bool get hasMore => page < nbPages - 1;

  GameDistributionState copyWith({
    List<Game>? games,
    int? page,
    int? nbPages,
  }) {
    return GameDistributionState(
      games: games ?? this.games,
      page: page ?? this.page,
      nbPages: nbPages ?? this.nbPages,
    );
  }
}
