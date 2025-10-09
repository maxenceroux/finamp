import 'package:logging/logging.dart';
import '../models/spotify_models.dart';
import '../models/jellyfin_models.dart';
import 'spotify_api.dart';

class SpotifyApiHelper {
  final spotifyApi = SpotifyApi.create();
  final _logger = Logger("SpotifyApiHelper");

  /// Search for albums on Spotify
  Future<List<BaseItemDto>?> searchAlbums({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final searchResult = await spotifyApi.searchAlbums(
        query.trim(),
        "album",
        limit,
        offset,
      );

      if (searchResult != null) {
        final spotifyAlbums = searchResult.albums.items;

        // Convert Spotify albums to BaseItemDto for compatibility with existing UI
        return spotifyAlbums
            .map((spotifyAlbum) => _convertSpotifyAlbumToBaseItem(spotifyAlbum))
            .toList();
      } else {
        _logger.warning("Failed to search Spotify albums");
        return [];
      }
    } catch (e) {
      _logger.severe("Error searching Spotify albums: $e");
      return [];
    }
  }

  /// Convert a Spotify album to BaseItemDto for compatibility with existing UI
  BaseItemDto _convertSpotifyAlbumToBaseItem(SpotifyAlbum spotifyAlbum) {
    // Get the best image (preferably medium size)
    String? imageUrl;
    if (spotifyAlbum.images.isNotEmpty) {
      // Try to find an image around 300x300, or use the first one
      SpotifyImage? mediumImage;
      for (final img in spotifyAlbum.images) {
        if (img.height != null && img.height! >= 200 && img.height! <= 400) {
          mediumImage = img;
          break;
        }
      }

      imageUrl = mediumImage?.url ?? spotifyAlbum.images.first.url;
    }

    // Get primary artist name
    final artistName = spotifyAlbum.artists.isNotEmpty
        ? spotifyAlbum.artists.first.name
        : "Unknown Artist";

    // Create artist list for albumArtists field
    final albumArtists = spotifyAlbum.artists
        .map((artist) => NameIdPair(
              name: artist.name,
              id: artist.id,
            ))
        .toList();

    return BaseItemDto(
      name: spotifyAlbum.name,
      id: "spotify:${spotifyAlbum.id}", // Prefix with spotify: to indicate source
      type: "MusicAlbum",
      albumArtist: artistName,
      albumArtists: albumArtists,
      productionYear: _parseReleaseYear(spotifyAlbum.release_date),
      premiereDate:
          _parseReleaseDate(spotifyAlbum.release_date)?.toIso8601String(),
      childCount: spotifyAlbum.total_tracks,
      serverId: "spotify", // Use spotify as server ID to indicate source
      // Custom fields to store Spotify-specific data
      externalUrls: [
        ExternalUrl(
          name: "spotify",
          url: spotifyAlbum.external_urls.spotify,
        ),
      ],
      // Use the image URL as the primary image
      imageTags: imageUrl != null ? {"Primary": imageUrl} : null,
    );
  }

  /// Parse release year from Spotify release date
  int? _parseReleaseYear(String releaseDate) {
    try {
      if (releaseDate.length >= 4) {
        return int.parse(releaseDate.substring(0, 4));
      }
    } catch (e) {
      _logger.warning("Failed to parse release year from: $releaseDate");
    }
    return null;
  }

  /// Parse release date from Spotify release date
  DateTime? _parseReleaseDate(String releaseDate) {
    try {
      return DateTime.parse(releaseDate);
    } catch (e) {
      _logger.warning("Failed to parse release date from: $releaseDate");
      return null;
    }
  }
}
