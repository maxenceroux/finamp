import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/jellyfin_models.dart';
import 'downloads_helper.dart';
import 'finamp_settings_helper.dart';
import 'jellyfin_api_helper.dart';

/// A class that handles returning ImageProviders for Jellyfin items. This class
/// only has one static function to handle this, and has no constructors. It's a
/// bit of a jank way to do this, so if you know a better way, please let me
/// know :)
class AlbumImageProvider {
  static Future<ImageProvider?> init(
    BaseItemDto item, {
    int? maxWidth,
    int? maxHeight,
    List<BaseItemDto>? itemsToPrecache,
    BuildContext? context,
  }) async {
    assert(itemsToPrecache == null ? true : context != null);
    
    // Handle Spotify albums specially
    if (item.id?.startsWith("spotify:") == true) {
      final spotifyImageUrl = item.imageTags?["Primary"];
      if (spotifyImageUrl != null) {
        return NetworkImage(spotifyImageUrl);
      }
      return null;
    }
    
    if (item.imageId == null) {
      return null;
    }

    if (itemsToPrecache != null) {
      for (final itemToPrecache in itemsToPrecache) {
        init(itemToPrecache, maxWidth: maxWidth, maxHeight: maxHeight)
            .then((value) {
          if (value != null) {
            precacheImage(value, context!);
          }
        });
      }
    }

    final jellyfinApiHelper = GetIt.instance<JellyfinApiHelper>();
    final downloadsHelper = GetIt.instance<DownloadsHelper>();

    final downloadedImage = downloadsHelper.getDownloadedImage(item);

    if (downloadedImage == null) {
      if (FinampSettingsHelper.finampSettings.isOffline) {
        return null;
      }

      Uri? imageUrl = jellyfinApiHelper.getImageUrl(
        item: item,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (imageUrl == null) {
        return null;
      }

      return NetworkImage(imageUrl.toString());
    }

    if (await downloadsHelper.verifyDownloadedImage(downloadedImage)) {
      return FileImage(downloadedImage.file);
    }

    // If we've got this far, the download image has failed to verify.
    // We recurse, which will either return a NetworkImage or an error depending
    // on if the app is offline.
    return init(item, maxWidth: maxWidth, maxHeight: maxHeight);
  }
}
