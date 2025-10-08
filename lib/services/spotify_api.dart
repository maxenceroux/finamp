import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:chopper/chopper.dart';

import '../models/spotify_models.dart';

class SpotifyApi {
  final _logger = Logger("SpotifyApi");
  final ChopperClient _client;

  SpotifyApi() : _client = ChopperClient(
    baseUrl: Uri.parse("https://api.spotify.com"),
    converter: JsonConverter(),
  );

  Future<SpotifySearchResponse?> searchAlbums(
    String query,
    String type,
    int limit,
    int offset,
  ) async {
    try {
      final token = await _getSpotifyToken();
      
      final response = await _client.get(
        "/v1/search",
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        parameters: {
          "q": query,
          "type": type,
          "limit": limit.toString(),
          "offset": offset.toString(),
        },
      );

      if (response.isSuccessful && response.body != null) {
        return SpotifySearchResponse.fromJson(response.body);
      } else {
        _logger.warning("Failed to search Spotify: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      _logger.severe("Error searching Spotify: $e");
      return null;
    }
  }

  Future<String> _getSpotifyToken() async {
    try {
      final tokenClient = ChopperClient(
        baseUrl: Uri.parse("http://100.98.104.55:3001"),
        converter: JsonConverter(),
      );

      final response = await tokenClient.get("/api/spotify-token");
      
      if (response.isSuccessful && response.body != null) {
        final tokenResponse = SpotifyTokenResponse.fromJson(response.body);
        return tokenResponse.access_token;
      } else {
        throw Exception("Failed to fetch Spotify token: ${response.statusCode}");
      }
    } catch (e) {
      _logger.severe("Error fetching Spotify token: $e");
      rethrow;
    }
  }

  static SpotifyApi create() {
    return SpotifyApi();
  }
}