import 'package:json_annotation/json_annotation.dart';

part 'slskd_models.g.dart';

/// Model for slskd transfer/download data
@JsonSerializable()
class SlskdDownload {
  final String username;
  final String token;
  final String filename;
  final int size;
  final int bytesTransferred;
  final double percentComplete;
  final int averageSpeed;
  final String state;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String direction;

  SlskdDownload({
    required this.username,
    required this.token,
    required this.filename,
    required this.size,
    required this.bytesTransferred,
    required this.percentComplete,
    required this.averageSpeed,
    required this.state,
    required this.startedAt,
    this.endedAt,
    required this.direction,
  });

  factory SlskdDownload.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return null;
    }

    return SlskdDownload(
      username: json['username']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      filename: json['filename']?.toString() ?? '',
      size: parseInt(json['size']),
      bytesTransferred: parseInt(json['bytesTransferred']),
      percentComplete: parseDouble(json['percentComplete']),
      averageSpeed: parseInt(json['averageSpeed']),
      state: json['state']?.toString() ?? '',
      startedAt: parseDate(json['requestedAt']) ?? DateTime.now(),
      endedAt: parseDate(json['endedAt']),
      direction: json['direction']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$SlskdDownloadToJson(this);
}

/// Model for slskd directory transfer containing multiple files
@JsonSerializable()
class SlskdDirectoryDownload {
  final String username;
  final String directoryName;
  final List<SlskdDownload> files;
  final DateTime startedAt;
  final String state;
  final int totalSize;
  final int totalBytesTransferred;
  final double overallProgress;

  SlskdDirectoryDownload({
    required this.username,
    required this.directoryName,
    required this.files,
    required this.startedAt,
    required this.state,
    required this.totalSize,
    required this.totalBytesTransferred,
    required this.overallProgress,
  });

  factory SlskdDirectoryDownload.fromJson(Map<String, dynamic> json) =>
      _$SlskdDirectoryDownloadFromJson(json);

  Map<String, dynamic> toJson() => _$SlskdDirectoryDownloadToJson(this);

  /// Get the album name from the directory name
  String get albumName {
    // Extract album name from directory path
    final parts = directoryName.split('/');
    return parts.isNotEmpty ? parts.last : directoryName;
  }

  /// Get the average speed across all files
  double get averageSpeed {
    if (files.isEmpty) return 0.0;
    return files.map((f) => f.averageSpeed).reduce((a, b) => a + b) /
        files.length;
  }
}

/// Model for slskd search data
@JsonSerializable()
class SlskdSearch {
  final int id;
  final String query;
  final DateTime searchedAt;
  final String state;
  final int resultCount;
  final List<SlskdSearchResult>? results;

  SlskdSearch({
    required this.id,
    required this.query,
    required this.searchedAt,
    required this.state,
    required this.resultCount,
    this.results,
  });

  factory SlskdSearch.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return null;
    }

    // Map new API fields to model fields
    return SlskdSearch(
      id: json['id']?.toString().isNotEmpty == true ? parseInt(json['id']) : 0,
      query: json['searchText']?.toString() ?? json['query']?.toString() ?? '',
      searchedAt: parseDate(json['startedAt']) ?? DateTime.now(),
      state: json['state']?.toString() ?? '',
      resultCount: parseInt(json['responseCount'] ?? json['resultCount']),
      results: (json['responses'] as List<dynamic>?)
          ?.map((e) => SlskdSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$SlskdSearchToJson(this);
}

/// Model for slskd search result
@JsonSerializable()
class SlskdSearchResult {
  final String username;
  final String filename;
  final int size;
  final int bitrate;
  final int sampleRate;
  final int length;
  final bool hasFreeUploadSlot;

  SlskdSearchResult({
    required this.username,
    required this.filename,
    required this.size,
    required this.bitrate,
    required this.sampleRate,
    required this.length,
    required this.hasFreeUploadSlot,
  });

  factory SlskdSearchResult.fromJson(Map<String, dynamic> json) =>
      _$SlskdSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$SlskdSearchResultToJson(this);
}
