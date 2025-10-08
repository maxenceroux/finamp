import 'package:flutter/material.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

import '../components/DownloadsErrorScreen/download_error_list.dart';
import '../services/downloads_helper.dart';

class DownloadsErrorScreen extends StatelessWidget {
  const DownloadsErrorScreen({Key? key}) : super(key: key);

  static const routeName = "/downloads/errors";

  @override
  Widget build(BuildContext context) {
    final downloadsHelper = GetIt.instance<DownloadsHelper>();

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.downloadErrorsTitle),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final appLocalizations = AppLocalizations.of(context);

                  final redownloaded = await downloadsHelper.redownloadFailed();

                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                          appLocalizations!.redownloadedItems(redownloaded)),
                    ),
                  );
                })
          ]),
      body: const DownloadErrorList(),
    );
  }
}
