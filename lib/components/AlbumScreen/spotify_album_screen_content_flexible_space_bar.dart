import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:finamp/l10n/app_localizations.dart';

import '../../models/jellyfin_models.dart';
import '../album_image.dart';
import 'item_info.dart';

class SpotifyAlbumScreenContentFlexibleSpaceBar extends StatelessWidget {
  const SpotifyAlbumScreenContentFlexibleSpaceBar({
    Key? key,
    required this.album,
    required this.items,
  }) : super(key: key);

  final BaseItemDto album;
  final List<BaseItemDto> items;

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      background: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 125,
                      child: AlbumImage(item: album),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                    Expanded(
                      flex: 2,
                      child: ItemInfo(
                        item: album,
                        itemSongs: items.length,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDownloadDialog(context),
                        icon: const Icon(Icons.download),
                        label: Text(AppLocalizations.of(context)!.download),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openInSpotify(context),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Open in Spotify"),
                      ),
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Download Album"),
          content: const Text(
            "This feature would allow downloading the album for offline listening. "
            "Implementation depends on the app's download system integration with Spotify.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Download functionality to be implemented"),
                  ),
                );
              },
              child: const Text("Download"),
            ),
          ],
        );
      },
    );
  }

  void _openInSpotify(BuildContext context) {
    // TODO: Implement opening in Spotify app or web
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Opening in Spotify..."),
      ),
    );
  }
}