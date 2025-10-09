class SpotifyTokenResponse {
  final String access_token;

  SpotifyTokenResponse({required this.access_token});

  factory SpotifyTokenResponse.fromJson(Map<String, dynamic> json) {
    return SpotifyTokenResponse(access_token: json['access_token'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': access_token,
    };
  }
}

class SpotifySearchResponse {
  final SpotifyAlbumsSearchResult albums;

  SpotifySearchResponse({
    required this.albums,
  });

  factory SpotifySearchResponse.fromJson(Map<String, dynamic> json) {
    return SpotifySearchResponse(
      albums: SpotifyAlbumsSearchResult.fromJson(
          json['albums'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albums': albums.toJson(),
    };
  }
}

class SpotifyAlbumsSearchResult {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<SpotifyAlbum> items;

  SpotifyAlbumsSearchResult({
    required this.href,
    required this.limit,
    this.next,
    required this.offset,
    this.previous,
    required this.total,
    required this.items,
  });

  factory SpotifyAlbumsSearchResult.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbumsSearchResult(
      href: json['href'] as String,
      limit: json['limit'] as int,
      next: json['next'] as String?,
      offset: json['offset'] as int,
      previous: json['previous'] as String?,
      total: json['total'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => SpotifyAlbum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'href': href,
      'limit': limit,
      'next': next,
      'offset': offset,
      'previous': previous,
      'total': total,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SpotifyAlbum {
  final String album_type;
  final int total_tracks;
  final List<String> available_markets;
  final SpotifyExternalUrls external_urls;
  final String href;
  final String id;
  final List<SpotifyImage> images;
  final String name;
  final String release_date;
  final String release_date_precision;
  final String type;
  final String uri;
  final List<SpotifyArtist> artists;

  SpotifyAlbum({
    required this.album_type,
    required this.total_tracks,
    required this.available_markets,
    required this.external_urls,
    required this.href,
    required this.id,
    required this.images,
    required this.name,
    required this.release_date,
    required this.release_date_precision,
    required this.type,
    required this.uri,
    required this.artists,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbum(
      album_type: json['album_type'] as String,
      total_tracks: json['total_tracks'] as int,
      available_markets: (json['available_markets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      external_urls: SpotifyExternalUrls.fromJson(
          json['external_urls'] as Map<String, dynamic>),
      href: json['href'] as String,
      id: json['id'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      release_date: json['release_date'] as String,
      release_date_precision: json['release_date_precision'] as String,
      type: json['type'] as String,
      uri: json['uri'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => SpotifyArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_type': album_type,
      'total_tracks': total_tracks,
      'available_markets': available_markets,
      'external_urls': external_urls.toJson(),
      'href': href,
      'id': id,
      'images': images.map((e) => e.toJson()).toList(),
      'name': name,
      'release_date': release_date,
      'release_date_precision': release_date_precision,
      'type': type,
      'uri': uri,
      'artists': artists.map((e) => e.toJson()).toList(),
    };
  }
}

class SpotifyArtist {
  final SpotifyExternalUrls external_urls;
  final String href;
  final String id;
  final String name;
  final String type;
  final String uri;

  SpotifyArtist({
    required this.external_urls,
    required this.href,
    required this.id,
    required this.name,
    required this.type,
    required this.uri,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    return SpotifyArtist(
      external_urls: SpotifyExternalUrls.fromJson(
          json['external_urls'] as Map<String, dynamic>),
      href: json['href'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      uri: json['uri'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'external_urls': external_urls.toJson(),
      'href': href,
      'id': id,
      'name': name,
      'type': type,
      'uri': uri,
    };
  }
}

class SpotifyImage {
  final String url;
  final int? height;
  final int? width;

  SpotifyImage({
    required this.url,
    this.height,
    this.width,
  });

  factory SpotifyImage.fromJson(Map<String, dynamic> json) {
    return SpotifyImage(
      url: json['url'] as String,
      height: json['height'] as int?,
      width: json['width'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'height': height,
      'width': width,
    };
  }
}

class SpotifyExternalUrls {
  final String spotify;

  SpotifyExternalUrls({
    required this.spotify,
  });

  factory SpotifyExternalUrls.fromJson(Map<String, dynamic> json) {
    return SpotifyExternalUrls(
      spotify: json['spotify'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotify': spotify,
    };
  }
}
