import 'dart:convert';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:finamp/services/http_aggregate_logging_interceptor.dart';
import 'package:logging/logging.dart';

import '../models/slskd_models.dart';

part 'slskd_api.chopper.dart';

@ChopperApi()
abstract class SlskdApi extends ChopperService {
  static const String baseUrl = 'http://localhost:5030'; // Default slskd URL
  
  @FactoryConverter(
    request: JsonConverter.requestFactory,
    response: JsonConverter.responseFactory,
  )
  @Get(path: '/api/v0/transfers/downloads')
  Future<Response<List<Map<String, dynamic>>>> getDownloads({
    @Query('includeRemoved') bool includeRemoved = false,
  });

  @FactoryConverter(
    request: JsonConverter.requestFactory,
    response: JsonConverter.responseFactory,
  )
  @Get(path: '/api/v0/searches')
  Future<Response<List<Map<String, dynamic>>>> getSearches({
    @Query('limit') int? limit,
  });

  @FactoryConverter(
    request: JsonConverter.requestFactory,
    response: JsonConverter.responseFactory,
  )
  @Get(path: '/api/v0/searches/{id}')
  Future<Response<Map<String, dynamic>>> getSearch({
    @Path('id') required int id,
  });

  static SlskdApi create({String? baseUrl}) {
    final client = ChopperClient(
      baseUrl: Uri.parse(baseUrl ?? SlskdApi.baseUrl),
      services: [_$SlskdApi()],
      interceptors: [
        HttpAggregateLoggingInterceptor(),
        HttpLoggingInterceptor(),
      ],
      converter: const JsonConverter(),
    );

    return _$SlskdApi(client);
  }
}

/// Helper class to manage slskd API integration
class SlskdApiHelper {
  final SlskdApi _api;
  final _logger = Logger('SlskdApiHelper');

  SlskdApiHelper({String? baseUrl}) : _api = SlskdApi.create(baseUrl: baseUrl);

  /// Get list of downloads, grouped by directory
  Future<List<SlskdDirectoryDownload>> getDirectoryDownloads() async {
    try {
      final response = await _api.getDownloads();
      
      if (response.isSuccessful && response.body != null) {
        final downloads = response.body!
            .map((json) => SlskdDownload.fromJson(json))
            .toList();

        // Group downloads by directory
        final Map<String, List<SlskdDownload>> groupedDownloads = {};
        
        for (final download in downloads) {
          // Extract directory from filename
          final directory = _extractDirectory(download.filename);
          
          if (!groupedDownloads.containsKey(directory)) {
            groupedDownloads[directory] = [];
          }
          groupedDownloads[directory]!.add(download);
        }

        // Convert to SlskdDirectoryDownload objects
        final directoryDownloads = groupedDownloads.entries.map((entry) {
          final files = entry.value;
          final totalSize = files.fold<int>(0, (sum, file) => sum + file.size);
          final totalBytesTransferred = files.fold<int>(0, (sum, file) => sum + file.bytesTransferred);
          final overallProgress = totalSize > 0 ? (totalBytesTransferred / totalSize) * 100 : 0.0;
          
          // Determine overall state
          String state = 'Completed';
          if (files.any((f) => f.state == 'InProgress')) {
            state = 'InProgress';
          } else if (files.any((f) => f.state == 'Queued')) {
            state = 'Queued';
          }

          return SlskdDirectoryDownload(
            username: files.first.username,
            directoryName: entry.key,
            files: files,
            startedAt: files.map((f) => f.startedAt).reduce((a, b) => a.isBefore(b) ? a : b),
            state: state,
            totalSize: totalSize,
            totalBytesTransferred: totalBytesTransferred,
            overallProgress: overallProgress,
          );
        }).toList();

        // Sort by start date descending
        directoryDownloads.sort((a, b) => b.startedAt.compareTo(a.startedAt));

        return directoryDownloads;
      }

      _logger.warning('Failed to get downloads: ${response.statusCode}');
      return [];
    } catch (e) {
      _logger.severe('Error getting downloads: $e');
      return [];
    }
  }

  /// Get list of recent searches
  Future<List<SlskdSearch>> getSearches({int? limit}) async {
    try {
      final response = await _api.getSearches(limit: limit ?? 50);
      
      if (response.isSuccessful && response.body != null) {
        final searches = response.body!
            .map((json) => SlskdSearch.fromJson(json))
            .toList();

        // Sort by search time descending
        searches.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));

        return searches;
      }

      _logger.warning('Failed to get searches: ${response.statusCode}');
      return [];
    } catch (e) {
      _logger.severe('Error getting searches: $e');
      return [];
    }
  }

  /// Get details of a specific search
  Future<SlskdSearch?> getSearch(int id) async {
    try {
      final response = await _api.getSearch(id: id);
      
      if (response.isSuccessful && response.body != null) {
        return SlskdSearch.fromJson(response.body!);
      }

      _logger.warning('Failed to get search $id: ${response.statusCode}');
      return null;
    } catch (e) {
      _logger.severe('Error getting search $id: $e');
      return null;
    }
  }

  /// Extract directory name from a file path
  String _extractDirectory(String filename) {
    final parts = filename.split(Platform.pathSeparator);
    if (parts.length > 1) {
      return parts.sublist(0, parts.length - 1).join(Platform.pathSeparator);
    }
    return filename;
  }
}