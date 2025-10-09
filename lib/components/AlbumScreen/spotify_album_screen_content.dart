import 'package:flutter/material.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../../models/jellyfin_models.dart';
import '../favourite_button.dart';
import 'spotify_album_screen_content_flexible_space_bar.dart';
import 'song_list_tile.dart';

typedef BaseItemDtoCallback = void Function(BaseItemDto item);

class SpotifyAlbumScreenContent extends StatefulWidget {
  const SpotifyAlbumScreenContent({
    Key? key,
    required this.parent,
    required this.children,
  }) : super(key: key);

  final BaseItemDto parent;
  final List<BaseItemDto> children;

  @override
  State<SpotifyAlbumScreenContent> createState() => _SpotifyAlbumScreenContentState();
}

class _SpotifyAlbumScreenContentState extends State<SpotifyAlbumScreenContent> {
  @override
  Widget build(BuildContext context) {
    List<List<BaseItemDto>> childrenPerDisc = [];
    // try splitting up tracks by disc numbers
    // if first track has a disc number, let's assume the rest has it too
    if (widget.children.isNotEmpty && widget.children[0].parentIndexNumber != null) {
      int? lastDiscNumber;
      for (var child in widget.children) {
        if (child.parentIndexNumber != null &&
            child.parentIndexNumber != lastDiscNumber) {
          lastDiscNumber = child.parentIndexNumber;
          childrenPerDisc.add([]);
        }
        childrenPerDisc.last.add(child);
      }
    }

    return Scrollbar(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(widget.parent.name ??
                AppLocalizations.of(context)!.unknownName),
            // 125 + 64 is the total height of the widget we use as a
            // FlexibleSpaceBar. We add the toolbar height since the widget
            // should appear below the appbar.
            // TODO: This height is affected by platform density.
            expandedHeight: kToolbarHeight + 125 + 64,
            pinned: true,
            flexibleSpace: SpotifyAlbumScreenContentFlexibleSpaceBar(
              album: widget.parent,
              items: widget.children,
            ),
            actions: [
              // Remove favorite button and download button for Spotify albums
              // Could add "Open in Spotify" button here if needed
            ],
          ),
          if (widget.children.length > 1 &&
              childrenPerDisc.length >
                  1) // show headers only for multi disc albums
            for (var childrenOfThisDisc in childrenPerDisc)
              SliverStickyHeader(
                header: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Text(
                    AppLocalizations.of(context)!.disc(
                        childrenOfThisDisc.first.parentIndexNumber ?? 1),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return SongListTile(
                        item: childrenOfThisDisc[index],
                        isInPlaylist: false,
                        actualParent: widget.parent,
                        isInAlbum: true,
                        // Disable most actions for Spotify tracks
                        onTap: () {
                          // Show info dialog or open preview in Spotify
                          _showTrackInfo(context, childrenOfThisDisc[index]);
                        },
                      );
                    },
                    childCount: childrenOfThisDisc.length,
                  ),
                ),
              )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return SongListTile(
                    item: widget.children[index],
                    isInPlaylist: false,
                    actualParent: widget.parent,
                    isInAlbum: true,
                    // Disable most actions for Spotify tracks
                    onTap: () {
                      // Show info dialog or open preview in Spotify
                      _showTrackInfo(context, widget.children[index]);
                    },
                  );
                },
                childCount: widget.children.length,
              ),
            ),
        ],
      ),
    );
  }

  void _showTrackInfo(BuildContext context, BaseItemDto track) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(track.name ?? "Track"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (track.artists?.isNotEmpty == true)
                Text("Artist: ${track.artists!.join(', ')}"),
              if (track.runTimeTicks != null)
                Text("Duration: ${_formatDuration(track.runTimeTicks! ~/ 10000)}"),
              if (track.indexNumber != null)
                Text("Track: ${track.indexNumber!}"),
              const SizedBox(height: 16),
              const Text("This is a Spotify track. Full playback is not available in this app."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
            if (track.externalUrls?.isNotEmpty == true)
              TextButton(
                onPressed: () {
                  // TODO: Open Spotify URL
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Opening in Spotify...")),
                  );
                },
                child: const Text("Open in Spotify"),
              ),
          ],
        );
      },
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}