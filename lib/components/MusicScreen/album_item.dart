import 'package:finamp/components/MusicScreen/album_item_list_tile.dart';
import 'package:finamp/services/downloads_helper.dart';
import 'package:finamp/services/finamp_settings_helper.dart';
import 'package:flutter/material.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import '../../models/jellyfin_models.dart';
import '../../services/audio_service_helper.dart';
import '../../services/jellyfin_api_helper.dart';
import '../../screens/artist_screen.dart';
import '../../screens/album_screen.dart';
import '../error_snackbar.dart';
import 'album_item_card.dart';

enum _AlbumListTileMenuItems {
  addToQueue,
  playNext,
  addFavourite,
  removeFavourite,
  addToMixList,
  removeFromMixList,
}

/// This widget is kind of a shell around AlbumItemCard and AlbumItemListTile.
/// Depending on the values given, a list tile or a card will be returned. This
/// widget exists to handle the dropdown stuff and other stuff shared between
/// the two widgets.
class AlbumItem extends StatefulWidget {
  const AlbumItem({
    Key? key,
    required this.album,
    this.parentType,
    this.onTap,
    this.isGrid = false,
    this.gridAddSettingsListener = false,
  }) : super(key: key);

  /// The album (or item, I just used to call items albums before Finamp
  /// supported other types) to show in the widget.
  final BaseItemDto album;

  /// The parent type of the item. Used to change onTap functionality for stuff
  /// like artists.
  final String? parentType;

  /// A custom onTap can be provided to override the default value, which is to
  /// open the item's album/artist screen.
  final void Function()? onTap;

  /// If specified, use cards instead of list tiles. Use this if you want to use
  /// this widget in a grid view.
  final bool isGrid;

  /// If true, the grid item will use a ValueListenableBuilder to check whether
  /// or not to show the text. You'll want to set this to false if the
  /// [AlbumItem] would be rebuilt by FinampSettings anyway.
  final bool gridAddSettingsListener;

  @override
  State<AlbumItem> createState() => _AlbumItemState();
}

class _AlbumItemState extends State<AlbumItem> {
  final _audioServiceHelper = GetIt.instance<AudioServiceHelper>();

  late BaseItemDto mutableAlbum;

  late Function() onTap;

  @override
  void initState() {
    super.initState();
    mutableAlbum = widget.album;

    // this is jank lol
    onTap = widget.onTap ??
        () {
          if (mutableAlbum.type == "MusicArtist" ||
              mutableAlbum.type == "MusicGenre") {
            Navigator.of(context)
                .pushNamed(ArtistScreen.routeName, arguments: mutableAlbum);
          } else {
            Navigator.of(context)
                .pushNamed(AlbumScreen.routeName, arguments: mutableAlbum);
          }
        };
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: widget.isGrid
          ? Theme.of(context).cardTheme.margin ?? const EdgeInsets.all(4.0)
          : EdgeInsets.zero,
      child: GestureDetector(
        onLongPressStart: (details) async {
          Feedback.forLongPress(context);

          final isOffline = FinampSettingsHelper.finampSettings.isOffline;

          final jellyfinApiHelper = GetIt.instance<JellyfinApiHelper>();

          final selection = await showMenu<_AlbumListTileMenuItems>(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              screenSize.width - details.globalPosition.dx,
              screenSize.height - details.globalPosition.dy,
            ),
            items: [
              if (_audioServiceHelper.hasQueueItems()) ...[
                PopupMenuItem<_AlbumListTileMenuItems>(
                  value: _AlbumListTileMenuItems.addToQueue,
                  child: ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(AppLocalizations.of(context)!.addToQueue),
                  ),
                ),
                PopupMenuItem<_AlbumListTileMenuItems>(
                  value: _AlbumListTileMenuItems.playNext,
                  child: ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(AppLocalizations.of(context)!.playNext),
                  ),
                ),
              ],
              mutableAlbum.userData!.isFavorite
                  ? PopupMenuItem<_AlbumListTileMenuItems>(
                      enabled: !isOffline,
                      value: _AlbumListTileMenuItems.removeFavourite,
                      child: ListTile(
                        enabled: !isOffline,
                        leading: const Icon(Icons.favorite_border),
                        title:
                            Text(AppLocalizations.of(context)!.removeFavourite),
                      ),
                    )
                  : PopupMenuItem<_AlbumListTileMenuItems>(
                      enabled: !isOffline,
                      value: _AlbumListTileMenuItems.addFavourite,
                      child: ListTile(
                        enabled: !isOffline,
                        leading: const Icon(Icons.favorite),
                        title: Text(AppLocalizations.of(context)!.addFavourite),
                      ),
                    ),
              jellyfinApiHelper.selectedMixAlbumIds.contains(mutableAlbum.id)
                  ? PopupMenuItem<_AlbumListTileMenuItems>(
                      enabled: !isOffline,
                      value: _AlbumListTileMenuItems.removeFromMixList,
                      child: ListTile(
                        enabled: !isOffline,
                        leading: const Icon(Icons.explore_off),
                        title:
                            Text(AppLocalizations.of(context)!.removeFromMix),
                      ),
                    )
                  : PopupMenuItem<_AlbumListTileMenuItems>(
                      enabled: !isOffline,
                      value: _AlbumListTileMenuItems.addToMixList,
                      child: ListTile(
                        enabled: !isOffline,
                        leading: const Icon(Icons.explore),
                        title: Text(AppLocalizations.of(context)!.addToMix),
                      ),
                    ),
            ],
          );

          if (!mounted) return;

          switch (selection) {
            case _AlbumListTileMenuItems.addToQueue:
              List<BaseItemDto>? children;

              if (isOffline) {
                final downloadsHelper = GetIt.instance<DownloadsHelper>();

                // The downloadedParent won't be null here if we've already
                // navigated to it in offline mode
                final downloadedParent =
                    downloadsHelper.getDownloadedParent(widget.album.id)!;

                children = downloadedParent.downloadedChildren.values.toList();
              } else {
                children = await jellyfinApiHelper.getItems(
                  parentItem: widget.album,
                  sortBy: "ParentIndexNumber,IndexNumber,SortName",
                  includeItemTypes: "Audio",
                  isGenres: false,
                );
              }

              if (children != null) {
                await _audioServiceHelper.addQueueItems(children);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.addedToQueue),
                ));
              }

              break;

            case _AlbumListTileMenuItems.playNext:
              List<BaseItemDto>? children;
              if (isOffline) {
                final downloadsHelper = GetIt.instance<DownloadsHelper>();

                // The downloadedParent won't be null here if we've already
                // navigated to it in offline mode
                final downloadedParent =
                    downloadsHelper.getDownloadedParent(widget.album.id)!;

                children = downloadedParent.downloadedChildren.values.toList();
              } else {
                children = await jellyfinApiHelper.getItems(
                  parentItem: widget.album,
                  sortBy: "ParentIndexNumber,IndexNumber,SortName",
                  includeItemTypes: "Audio",
                  isGenres: false,
                );
              }

              if (children != null) {
                await _audioServiceHelper.insertQueueItemsNext(children);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.insertedIntoQueue),
                ));
              }

              break;

            case _AlbumListTileMenuItems.addFavourite:
              try {
                final newUserData =
                    await jellyfinApiHelper.addFavourite(mutableAlbum.id);

                if (!mounted) return;

                setState(() {
                  mutableAlbum.userData = newUserData;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Favourite added.")));
              } catch (e) {
                errorSnackbar(e, context);
              }
              break;
            case _AlbumListTileMenuItems.removeFavourite:
              try {
                final newUserData =
                    await jellyfinApiHelper.removeFavourite(mutableAlbum.id);

                if (!mounted) return;

                setState(() {
                  mutableAlbum.userData = newUserData;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Favourite removed.")));
              } catch (e) {
                errorSnackbar(e, context);
              }
              break;
            case _AlbumListTileMenuItems.addToMixList:
              try {
                jellyfinApiHelper.addAlbumToMixBuilderList(mutableAlbum);
                setState(() {});
              } catch (e) {
                errorSnackbar(e, context);
              }
              break;
            case _AlbumListTileMenuItems.removeFromMixList:
              try {
                jellyfinApiHelper.removeAlbumFromBuilderList(mutableAlbum);
                setState(() {});
              } catch (e) {
                errorSnackbar(e, context);
              }
              break;
            case null:
              break;
          }
        },
        child: widget.isGrid
            ? AlbumItemCard(
                item: mutableAlbum,
                onTap: onTap,
                parentType: widget.parentType,
                addSettingsListener: widget.gridAddSettingsListener,
              )
            : AlbumItemListTile(
                item: mutableAlbum,
                onTap: onTap,
                parentType: widget.parentType,
              ),
      ),
    );
  }
}
