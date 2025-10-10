import 'package:flutter/material.dart';
import '../../models/jellyfin_models.dart';
import '../print_duration.dart';
import '../album_image.dart';

class SpotifyTrackListTile extends StatelessWidget {
  const SpotifyTrackListTile({
    Key? key,
    required this.item,
    this.album,
    this.onTap,
  }) : super(key: key);

  final BaseItemDto item;
  final BaseItemDto? album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: album != null 
          ? AlbumImage(item: album!)
          : AlbumImage(item: item),
      title: Text(
        item.name ?? "Unknown Track",
        style: Theme.of(context).textTheme.titleMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          if (item.artists?.isNotEmpty == true)
            Expanded(
              child: Text(
                item.artists!.join(", "),
                style: TextStyle(color: Theme.of(context).disabledColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (item.runTimeTicks != null)
            Text(
              printDuration(Duration(milliseconds: item.runTimeTicks! ~/ 10000)),
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
        ],
      ),
      trailing: Icon(
        Icons.info_outline,
        color: Theme.of(context).disabledColor,
      ),
      onTap: onTap,
    );
  }
}