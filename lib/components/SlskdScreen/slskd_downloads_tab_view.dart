import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/slskd_models.dart';
import '../../services/slskd_api.dart';
import '../error_snackbar.dart';
import 'slskd_download_item.dart';

class SlskdDownloadsTabView extends StatefulWidget {
  const SlskdDownloadsTabView({Key? key}) : super(key: key);

  @override
  State<SlskdDownloadsTabView> createState() => _SlskdDownloadsTabViewState();
}

class _SlskdDownloadsTabViewState extends State<SlskdDownloadsTabView> {
  List<SlskdDirectoryDownload>? _downloads;
  bool _isLoading = true;
  late SlskdApiHelper _slskdApi;

  @override
  void initState() {
    super.initState();
    _slskdApi = SlskdApiHelper();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final downloads = await _slskdApi.getDirectoryDownloads();
      
      setState(() {
        _downloads = downloads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        errorSnackbar(e, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_downloads == null || _downloads!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No downloads found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Downloads from slskd will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDownloads,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _downloads!.length,
        itemBuilder: (context, index) {
          final download = _downloads![index];
          return SlskdDownloadItem(
            download: download,
            onTap: () => _showDownloadDetails(download),
          );
        },
      ),
    );
  }

  void _showDownloadDetails(SlskdDirectoryDownload download) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  download.albumName,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: download.files.length,
                  itemBuilder: (context, index) {
                    final file = download.files[index];
                    return ListTile(
                      title: Text(
                        file.filename.split('/').last,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        '${(file.size / 1024 / 1024).toStringAsFixed(1)} MB • ${file.state}',
                      ),
                      trailing: file.state == 'InProgress'
                          ? CircularProgressIndicator(
                              value: file.percentComplete / 100,
                              backgroundColor: Colors.grey[300],
                            )
                          : Icon(
                              file.state == 'Completed'
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              color: file.state == 'Completed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}