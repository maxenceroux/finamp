import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/slskd_models.dart';
import '../../services/slskd_api.dart';
import '../error_snackbar.dart';
import 'slskd_search_item.dart';

class SlskdSearchesTabView extends StatefulWidget {
  const SlskdSearchesTabView({Key? key}) : super(key: key);

  @override
  State<SlskdSearchesTabView> createState() => _SlskdSearchesTabViewState();
}

class _SlskdSearchesTabViewState extends State<SlskdSearchesTabView> {
  List<SlskdSearch>? _searches;
  bool _isLoading = true;
  late SlskdApiHelper _slskdApi;

  @override
  void initState() {
    super.initState();
    _slskdApi = SlskdApiHelper();
    _loadSearches();
  }

  Future<void> _loadSearches() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final searches = await _slskdApi.getSearches(limit: 100);
      
      setState(() {
        _searches = searches;
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

    if (_searches == null || _searches!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No searches found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recent searches from slskd will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSearches,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _searches!.length,
        itemBuilder: (context, index) {
          final search = _searches![index];
          return SlskdSearchItem(
            search: search,
            onTap: () => _showSearchDetails(search),
          );
        },
      ),
    );
  }

  void _showSearchDetails(SlskdSearch search) async {
    // Load full search details if results aren't available
    SlskdSearch? fullSearch = search;
    if (search.results == null) {
      fullSearch = await _slskdApi.getSearch(search.id);
      if (fullSearch == null) {
        if (mounted) {
          errorSnackbar('Failed to load search details', context);
        }
        return;
      }
    }

    if (!mounted) return;

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
                child: Column(
                  children: [
                    Text(
                      fullSearch!.query,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${fullSearch.resultCount} results found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: fullSearch.results?.isEmpty != false
                    ? const Center(
                        child: Text('No results available'),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: fullSearch.results!.length,
                        itemBuilder: (context, index) {
                          final result = fullSearch!.results![index];
                          return ListTile(
                            title: Text(
                              result.filename.split('/').last,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              '${result.username} • ${(result.size / 1024 / 1024).toStringAsFixed(1)} MB • ${result.bitrate} kbps',
                            ),
                            trailing: result.hasFreeUploadSlot
                                ? const Icon(
                                    Icons.cloud_download,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.schedule,
                                    color: Colors.orange,
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