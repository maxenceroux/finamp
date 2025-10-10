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

  factory SlskdDownload.fromJson(Map<String, dynamic> json) =>
      _$SlskdDownloadFromJson(json);

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
    return files.map((f) => f.averageSpeed).reduce((a, b) => a + b) / files.length;
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

  factory SlskdSearch.fromJson(Map<String, dynamic> json) =>
      _$SlskdSearchFromJson(json);

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