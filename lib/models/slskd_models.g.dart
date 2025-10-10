// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slskd_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlskdDownload _$SlskdDownloadFromJson(Map<String, dynamic> json) =>
    SlskdDownload(
      username: json['username'] as String,
      token: json['token'] as String,
      filename: json['filename'] as String,
      size: json['size'] as int,
      bytesTransferred: json['bytesTransferred'] as int,
      percentComplete: (json['percentComplete'] as num).toDouble(),
      averageSpeed: json['averageSpeed'] as int,
      state: json['state'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      direction: json['direction'] as String,
    );

Map<String, dynamic> _$SlskdDownloadToJson(SlskdDownload instance) =>
    <String, dynamic>{
      'username': instance.username,
      'token': instance.token,
      'filename': instance.filename,
      'size': instance.size,
      'bytesTransferred': instance.bytesTransferred,
      'percentComplete': instance.percentComplete,
      'averageSpeed': instance.averageSpeed,
      'state': instance.state,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'direction': instance.direction,
    };

SlskdDirectoryDownload _$SlskdDirectoryDownloadFromJson(
        Map<String, dynamic> json) =>
    SlskdDirectoryDownload(
      username: json['username'] as String,
      directoryName: json['directoryName'] as String,
      files: (json['files'] as List<dynamic>)
          .map((e) => SlskdDownload.fromJson(e as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      state: json['state'] as String,
      totalSize: json['totalSize'] as int,
      totalBytesTransferred: json['totalBytesTransferred'] as int,
      overallProgress: (json['overallProgress'] as num).toDouble(),
    );

Map<String, dynamic> _$SlskdDirectoryDownloadToJson(
        SlskdDirectoryDownload instance) =>
    <String, dynamic>{
      'username': instance.username,
      'directoryName': instance.directoryName,
      'files': instance.files.map((e) => e.toJson()).toList(),
      'startedAt': instance.startedAt.toIso8601String(),
      'state': instance.state,
      'totalSize': instance.totalSize,
      'totalBytesTransferred': instance.totalBytesTransferred,
      'overallProgress': instance.overallProgress,
    };

SlskdSearch _$SlskdSearchFromJson(Map<String, dynamic> json) => SlskdSearch(
      id: json['id'] as int,
      query: json['query'] as String,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
      state: json['state'] as String,
      resultCount: json['resultCount'] as int,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => SlskdSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SlskdSearchToJson(SlskdSearch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'query': instance.query,
      'searchedAt': instance.searchedAt.toIso8601String(),
      'state': instance.state,
      'resultCount': instance.resultCount,
      'results': instance.results?.map((e) => e.toJson()).toList(),
    };

SlskdSearchResult _$SlskdSearchResultFromJson(Map<String, dynamic> json) =>
    SlskdSearchResult(
      username: json['username'] as String,
      filename: json['filename'] as String,
      size: json['size'] as int,
      bitrate: json['bitrate'] as int,
      sampleRate: json['sampleRate'] as int,
      length: json['length'] as int,
      hasFreeUploadSlot: json['hasFreeUploadSlot'] as bool,
    );

Map<String, dynamic> _$SlskdSearchResultToJson(SlskdSearchResult instance) =>
    <String, dynamic>{
      'username': instance.username,
      'filename': instance.filename,
      'size': instance.size,
      'bitrate': instance.bitrate,
      'sampleRate': instance.sampleRate,
      'length': instance.length,
      'hasFreeUploadSlot': instance.hasFreeUploadSlot,
    };