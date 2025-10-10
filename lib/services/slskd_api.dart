import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:finamp/services/http_aggregate_logging_interceptor.dart';
import 'package:logging/logging.dart';

import '../models/slskd_models.dart';

part 'slskd_api.chopper.dart';

/// Configuration for slskd connection
class SlskdConfig {
  final String baseUrl;
  final String username;
  final String password;

  const SlskdConfig({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  static const SlskdConfig defaultConfig = SlskdConfig(
    baseUrl: 'http://100.98.104.55:5030',
    username: 'slskd',
    password: 'slskd',
  );
}

/// Authentication response model
class SlskdAuthResponse {
  final String token;
  final String username;

  SlskdAuthResponse({required this.token, required this.username});

  factory SlskdAuthResponse.fromJson(Map<String, dynamic> json) {
    return SlskdAuthResponse(
      token: json['token'] as String,
      username: json['username'] as String,
    );
  }
}

/// Authentication interceptor for slskd API
class SlskdAuthInterceptor implements RequestInterceptor, ResponseInterceptor {
  String? _token;
  final SlskdConfig config;
  final _logger = Logger('SlskdAuthInterceptor');
  bool _isAuthenticating = false;

  SlskdAuthInterceptor(this.config);

  @override
  FutureOr<Request> onRequest(Request request) async {
    // Skip authentication for login endpoint
    if (request.url.path.endsWith('/api/v0/session')) {
      return request;
    }

    // Get token if we don't have one
    if (_token == null && !_isAuthenticating) {
      await _authenticate();
    }

    // Add bearer token to request
    if (_token != null) {
      return request.copyWith(headers: {
        ...request.headers,
        'Authorization': 'Bearer $_token',
      });
    }

    return request;
  }

  @override
  FutureOr<Response> onResponse(Response response) async {
    // If we get a 401, clear token and retry once
    if (response.statusCode == 401 && _token != null) {
      _logger.info('Received 401, clearing token and will retry on next request');
      clearToken();
    }
    return response;
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    _isAuthenticating = true;
    try {
      final authClient = ChopperClient(
        baseUrl: Uri.parse(config.baseUrl),
        converter: const JsonConverter(),
      );

      final authRequest = Request(
        'POST',
        Uri.parse('/api/v0/session'),
        authClient.baseUrl,
        body: {
          'username': config.username,
          'password': config.password,
        },
      );

      final response = await authClient.send(authRequest);
      
      if (response.isSuccessful && response.body != null) {
        final authResponse = SlskdAuthResponse.fromJson(response.body);
        _token = authResponse.token;
        _logger.info('Successfully authenticated with slskd');
      } else {
        _logger.severe('Failed to authenticate with slskd: ${response.statusCode}');
      }

      authClient.dispose();
    } catch (e) {
      _logger.severe('Error during authentication: $e');
    } finally {
      _isAuthenticating = false;
    }
  }

  void clearToken() {
    _token = null;
  }
}

@ChopperApi()
abstract class SlskdApi extends ChopperService {
  @FactoryConverter(
    request: JsonConverter.requestFactory,
    response: JsonConverter.responseFactory,
  )
  @Post(path: '/api/v0/session')
  Future<Response<Map<String, dynamic>>> authenticate({
    @Body() required Map<String, String> credentials,
  });
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

  static SlskdApi create({SlskdConfig? config}) {
    final slskdConfig = config ?? SlskdConfig.defaultConfig;
    final authInterceptor = SlskdAuthInterceptor(slskdConfig);
    
    final client = ChopperClient(
      baseUrl: Uri.parse(slskdConfig.baseUrl),
      services: [_$SlskdApi()],
      interceptors: [
        authInterceptor,
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
  final SlskdConfig _config;
  final _logger = Logger('SlskdApiHelper');

  SlskdApiHelper({SlskdConfig? config}) 
      : _config = config ?? SlskdConfig.defaultConfig,
        _api = SlskdApi.create(config: config);

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

  /// Test authentication with slskd
  Future<bool> testAuthentication() async {
    try {
      final response = await _api.authenticate(credentials: {
        'username': _config.username,
        'password': _config.password,
      });
      
      return response.isSuccessful;
    } catch (e) {
      _logger.severe('Error testing authentication: $e');
      return false;
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