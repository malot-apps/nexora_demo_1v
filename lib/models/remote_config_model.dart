import 'dart:convert';

/// App Config Section
class AppConfig {
  final String version;
  final bool maintenanceMode;
  final String maintenanceMessage;

  AppConfig({
    required this.version,
    required this.maintenanceMode,
    required this.maintenanceMessage,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      version: json['version'] ?? '1.4.0-RC1',
      maintenanceMode: json['maintenance_mode'] ?? false,
      maintenanceMessage: json['maintenance_message'] ?? 'Nexora is currently undergoing scheduled maintenance.',
    );
  }

  factory AppConfig.fallback() {
    return AppConfig(
      version: '1.4.0-RC1',
      maintenanceMode: false,
      maintenanceMessage: 'Nexora is currently undergoing scheduled maintenance.',
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'maintenance_mode': maintenanceMode,
    'maintenance_message': maintenanceMessage,
  };
}

/// Home Banner Section (representing live match or special broadcast)
class HomeBannerConfig {
  final String statusTag;
  final String homeTeam;
  final String awayTeam;
  final String scoreText;
  final String matchTime;
  final String tournament;
  final String bannerImage;

  HomeBannerConfig({
    required this.statusTag,
    required this.homeTeam,
    required this.awayTeam,
    required this.scoreText,
    required this.matchTime,
    required this.tournament,
    required this.bannerImage,
  });

  factory HomeBannerConfig.fromJson(Map<String, dynamic> json) {
    return HomeBannerConfig(
      statusTag: json['status_tag'] ?? 'LIVE NOW',
      homeTeam: json['home_team'] ?? 'ARGENTINA',
      awayTeam: json['away_team'] ?? 'FRANCE',
      scoreText: json['score_text'] ?? '2 - 1',
      matchTime: json['match_time'] ?? '74\'',
      tournament: json['tournament'] ?? 'FIFA WORLD CUP 2026 • FINAL',
      bannerImage: json['banner_image'] ?? '',
    );
  }

  factory HomeBannerConfig.fallback() {
    return HomeBannerConfig(
      statusTag: 'LIVE NOW',
      homeTeam: 'ARGENTINA',
      awayTeam: 'FRANCE',
      scoreText: '2 - 1',
      matchTime: '74\'',
      tournament: 'FIFA WORLD CUP 2026 • FINAL',
      bannerImage: '',
    );
  }

  Map<String, dynamic> toJson() => {
    'status_tag': statusTag,
    'home_team': homeTeam,
    'away_team': awayTeam,
    'score_text': scoreText,
    'match_time': matchTime,
    'tournament': tournament,
    'banner_image': bannerImage,
  };
}

/// News Banner Section
class NewsBannerConfig {
  final String text;
  final List<String> newsAlerts;

  NewsBannerConfig({
    required this.text,
    required this.newsAlerts,
  });

  factory NewsBannerConfig.fromJson(Map<String, dynamic> json) {
    return NewsBannerConfig(
      text: json['text'] ?? 'Breaking: Nexora stable release is now live!',
      newsAlerts: List<String>.from(json['news_alerts'] ?? [
        'Breaking: Nexora stable release is now live!',
        'FIFA World Cup 2026 Live Feeds are active!',
        'Enjoy premium IPTV channels with ultra low-latency playback.',
      ]),
    );
  }

  factory NewsBannerConfig.fallback() {
    return NewsBannerConfig(
      text: 'Breaking: Nexora stable release is now live!',
      newsAlerts: [
        'Breaking: Nexora stable release is now live!',
        'FIFA World Cup 2026 Live Feeds are active!',
        'Enjoy premium IPTV channels with ultra low-latency playback.',
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'news_alerts': newsAlerts,
  };
}

/// Announcement Section
class AnnouncementConfig {
  final String title;
  final String message;
  final bool showAnnouncement;

  AnnouncementConfig({
    required this.title,
    required this.message,
    required this.showAnnouncement,
  });

  factory AnnouncementConfig.fromJson(Map<String, dynamic> json) {
    return AnnouncementConfig(
      title: json['title'] ?? 'Welcome to Nexora!',
      message: json['message'] ?? 'Enjoy premium IPTV streaming. Join our Telegram for updates.',
      showAnnouncement: json['show_announcement'] ?? true,
    );
  }

  factory AnnouncementConfig.fallback() {
    return AnnouncementConfig(
      title: 'Welcome to Nexora!',
      message: 'Enjoy premium IPTV streaming. Join our Telegram for updates.',
      showAnnouncement: true,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'show_announcement': showAnnouncement,
  };
}

/// Category Config representing Remote Categories support
class RemoteCategoryConfig {
  final String id;
  final String name;
  final String image;
  final int sortOrder;

  RemoteCategoryConfig({
    required this.id,
    required this.name,
    required this.image,
    required this.sortOrder,
  });

  factory RemoteCategoryConfig.fromJson(Map<String, dynamic> json) {
    return RemoteCategoryConfig(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'sort_order': sortOrder,
  };
}

/// Playlist Config representing Remote Playlists support
class RemotePlaylistConfig {
  final String id;
  final String name;
  final String url;
  final String type; // m3u or xtream
  final bool isActive;

  RemotePlaylistConfig({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.isActive,
  });

  factory RemotePlaylistConfig.fromJson(Map<String, dynamic> json) {
    return RemotePlaylistConfig(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'm3u',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'type': type,
    'is_active': isActive,
  };
}

/// EPG URL Config
class RemoteEpgConfig {
  final String url;
  final bool isEnabled;
  final bool isDefault;

  RemoteEpgConfig({
    required this.url,
    required this.isEnabled,
    required this.isDefault,
  });

  factory RemoteEpgConfig.fromJson(Map<String, dynamic> json) {
    return RemoteEpgConfig(
      url: json['url'] ?? '',
      isEnabled: json['is_enabled'] ?? true,
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'is_enabled': isEnabled,
    'is_default': isDefault,
  };
}

/// Root RemoteConfigModel class aggregating all sections
class RemoteConfigModel {
  final AppConfig appConfig;
  final HomeBannerConfig homeBanner;
  final NewsBannerConfig newsBanner;
  final AnnouncementConfig announcement;
  final List<RemoteCategoryConfig> categories;
  final List<RemotePlaylistConfig> playlists;
  final List<RemoteEpgConfig> epgUrls;
  final Map<String, String> channelLogos;
  final Map<String, String> posterImages;
  final List<String> featuredChannels;
  final List<String> hiddenChannels;

  RemoteConfigModel({
    required this.appConfig,
    required this.homeBanner,
    required this.newsBanner,
    required this.announcement,
    required this.categories,
    required this.playlists,
    required this.epgUrls,
    required this.channelLogos,
    required this.posterImages,
    required this.featuredChannels,
    required this.hiddenChannels,
  });

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) {
    var categoriesList = <RemoteCategoryConfig>[];
    if (json['categories'] != null) {
      categoriesList = (json['categories'] as List)
          .map((c) => RemoteCategoryConfig.fromJson(c))
          .toList();
    }

    var playlistsList = <RemotePlaylistConfig>[];
    if (json['playlist_list'] != null) {
      playlistsList = (json['playlist_list'] as List)
          .map((p) => RemotePlaylistConfig.fromJson(p))
          .toList();
    }

    var epgList = <RemoteEpgConfig>[];
    if (json['epg_urls'] != null) {
      epgList = (json['epg_urls'] as List)
          .map((e) => RemoteEpgConfig.fromJson(e))
          .toList();
    }

    return RemoteConfigModel(
      appConfig: AppConfig.fromJson(json['app_config'] ?? {}),
      homeBanner: HomeBannerConfig.fromJson(json['home_banner'] ?? {}),
      newsBanner: NewsBannerConfig.fromJson(json['news_banner'] ?? {}),
      announcement: AnnouncementConfig.fromJson(json['announcement'] ?? {}),
      categories: categoriesList,
      playlists: playlistsList,
      epgUrls: epgList,
      channelLogos: Map<String, String>.from(json['channel_logos'] ?? {}),
      posterImages: Map<String, String>.from(json['poster_images'] ?? {}),
      featuredChannels: List<String>.from(json['featured_channels'] ?? []),
      hiddenChannels: List<String>.from(json['hidden_channels'] ?? []),
    );
  }

  factory RemoteConfigModel.fallback() {
    return RemoteConfigModel(
      appConfig: AppConfig.fallback(),
      homeBanner: HomeBannerConfig.fallback(),
      newsBanner: NewsBannerConfig.fallback(),
      announcement: AnnouncementConfig.fallback(),
      categories: [
        RemoteCategoryConfig(
          id: 'sports',
          name: 'Sports Live',
          image: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2',
          sortOrder: 1,
        ),
        RemoteCategoryConfig(
          id: 'news',
          name: 'Global News',
          image: 'https://images.unsplash.com/photo-1495020689067-958852a6565d',
          sortOrder: 2,
        ),
        RemoteCategoryConfig(
          id: 'movies',
          name: 'Cinema & Movies',
          image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba',
          sortOrder: 3,
        ),
        RemoteCategoryConfig(
          id: 'entertainment',
          name: 'Entertainment',
          image: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
          sortOrder: 4,
        ),
        RemoteCategoryConfig(
          id: 'documentaries',
          name: 'Documentaries',
          image: 'https://images.unsplash.com/photo-1553481187-be93c21490a9',
          sortOrder: 5,
        ),
      ],
      playlists: [
        RemotePlaylistConfig(
          id: '1',
          name: 'FIFA World Cup 2026 Broadcasts (UHD)',
          url: 'https://cdn.nexora.sports/fifa2026/live_feeds.m3u8',
          type: 'm3u',
          isActive: true,
        ),
        RemotePlaylistConfig(
          id: '2',
          name: 'Europe Football Leagues HD Feed',
          url: 'https://streams.eurofooty.net/premium_channels.m3u',
          type: 'm3u',
          isActive: true,
        ),
      ],
      epgUrls: [
        RemoteEpgConfig(
          url: 'https://example.com/epg.xml',
          isEnabled: true,
          isDefault: true,
        ),
      ],
      channelLogos: {},
      posterImages: {},
      featuredChannels: ['sky_sports', 'bein_sports', 'espn_usa'],
      hiddenChannels: [],
    );
  }

  Map<String, dynamic> toJson() => {
    'app_config': appConfig.toJson(),
    'home_banner': homeBanner.toJson(),
    'news_banner': newsBanner.toJson(),
    'announcement': announcement.toJson(),
    'categories': categories.map((c) => c.toJson()).toList(),
    'playlist_list': playlists.map((p) => p.toJson()).toList(),
    'epg_urls': epgUrls.map((e) => e.toJson()).toList(),
    'channel_logos': channelLogos,
    'poster_images': posterImages,
    'featured_channels': featuredChannels,
    'hidden_channels': hiddenChannels,
  };
}
