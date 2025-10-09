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

  /// Get album tracks from Spotify
  Future<List<BaseItemDto>?> getAlbumTracks({
    required String albumId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Remove spotify: prefix if present
      final cleanAlbumId =
          albumId.startsWith('spotify:') ? albumId.substring(8) : albumId;

      final tracksResult = await spotifyApi.getAlbumTracks(
        cleanAlbumId,
        limit,
        offset,
      );

      if (tracksResult != null) {
        final spotifyTracks = tracksResult.items;

        // Convert Spotify tracks to BaseItemDto for compatibility with existing UI
        return spotifyTracks
            .asMap()
            .entries
            .map((entry) => _convertSpotifyTrackToBaseItem(
                entry.value, entry.key + 1, cleanAlbumId))
            .toList();
      } else {
        _logger.warning("Failed to get Spotify album tracks");
        return [];
      }
    } catch (e) {
      _logger.severe("Error getting Spotify album tracks: $e");
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

  /// Convert a Spotify track to BaseItemDto for compatibility with existing UI
  BaseItemDto _convertSpotifyTrackToBaseItem(
      SpotifyTrack spotifyTrack, int trackNumber, String albumId) {
    // Get primary artist name
    final artistName = spotifyTrack.artists.isNotEmpty
        ? spotifyTrack.artists.first.name
        : "Unknown Artist";

    // Create artist list for artists field
    final artists = spotifyTrack.artists.map((artist) => artist.name).toList();

    // Convert duration from milliseconds to ticks (1 tick = 100 nanoseconds, 1 ms = 10,000 ticks)
    final runTimeTicks = spotifyTrack.duration_ms * 10000;

    return BaseItemDto(
      name: spotifyTrack.name,
      id: "spotify:track:${spotifyTrack.id}", // Prefix with spotify:track: to indicate source
      type: "Audio",
      indexNumber: trackNumber,
      parentIndexNumber: spotifyTrack.disc_number,
      albumId: "spotify:$albumId",
      albumArtist: artistName,
      artists: artists,
      runTimeTicks: runTimeTicks,
      serverId: "spotify", // Use spotify as server ID to indicate source
      // Custom fields to store Spotify-specific data
      externalUrls: [
        ExternalUrl(
          name: "spotify",
          url: spotifyTrack.external_urls.spotify,
        ),
      ],
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
