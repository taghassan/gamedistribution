import 'package:dio/dio.dart';
import 'package:gamedistribution/GameModel.dart';

class GameService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://gd-website-api.gamedistribution.com/graphql",
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );


  Future<Map<String, dynamic>> fetchGames(int page) async {
    final response = await _dio.post(
      "",
      data: {
        "query": """
        query GetGamesSearched(\$perPage: Int!, \$page: Int!) {
          gamesSearched(
            input: {hitsPerPage: \$perPage, page: \$page}
          ) {
            hits {
              objectID
              title
              company
              mobileMode
              category
              slugs { name }
              assets { name }
            }
            nbPages
            page
          }
        }
        """,
        "variables": {
          "perPage": 30,
          "page": page,
        }
      },
    );

    return response.data['data']['gamesSearched'];
  }
}