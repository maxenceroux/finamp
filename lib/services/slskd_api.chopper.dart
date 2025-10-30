// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slskd_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SlskdApi extends SlskdApi {
  _$SlskdApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SlskdApi;

  @override
  Future<Response<Map<String, dynamic>>> authenticate(
      {required Map<String, String> credentials}) {
    final Uri $url = Uri.parse('/api/v0/session');
    final $body = credentials;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>(
      $request,
      requestConverter: JsonConverter.requestFactory,
      responseConverter: JsonConverter.responseFactory,
    );
  }

  @override
  Future<Response<List<dynamic>>> getDownloads({bool includeRemoved = false}) {
    final Uri $url = Uri.parse('/api/v0/transfers/downloads');
    final Map<String, dynamic> $params = <String, dynamic>{
      'includeRemoved': includeRemoved
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<dynamic>, List<dynamic>>(
      $request,
      requestConverter: JsonConverter.requestFactory,
      responseConverter: JsonConverter.responseFactory,
    );
  }

  @override
  Future<Response<List<dynamic>>> getSearches({int? limit}) {
    final Uri $url = Uri.parse('/api/v0/searches');
    final Map<String, dynamic> $params = <String, dynamic>{'limit': limit};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<dynamic>, List<dynamic>>(
      $request,
      requestConverter: JsonConverter.requestFactory,
      responseConverter: JsonConverter.responseFactory,
    );
  }

  @override
  Future<Response<Map<String, dynamic>>> getSearch({required int id}) {
    final Uri $url = Uri.parse('/api/v0/searches/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>(
      $request,
      requestConverter: JsonConverter.requestFactory,
      responseConverter: JsonConverter.responseFactory,
    );
  }
}
