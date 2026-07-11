import '../../models/channel_model.dart';
import '../../models/category_model.dart';

/// A production-ready M3U playlist parser for the Nexora IPTV application.
/// Extracts high-fidelity metadata (TVG ID, Logo URL, Category name, Stream URL)
/// and safely handles malformed lines, alternative attributes, and group-title tags.
class M3uParser {
  // Prevent instantiation
  const M3uParser._();

  /// Returns a high-fidelity mock M3U playlist string for demonstration purposes based on the source URL.
  static String getMockContent(String url) {
    final urlLower = url.toLowerCase();
    if (urlLower.contains('fifa2026') || urlLower.contains('live_feeds')) {
      return '''#EXTM3U
#EXTINF:-1 tvg-id="wc_usa_eng" tvg-name="USA vs England" tvg-logo="https://upload.wikimedia.org/wikipedia/commons/a/a4/Flag_of_the_United_States.svg" group-title="World Cup UHD",USA vs England (4K UHD)
https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8
#EXTINF:-1 tvg-id="wc_arg_fra" tvg-name="Argentina vs France" tvg-logo="https://upload.wikimedia.org/wikipedia/commons/1/1a/Flag_of_Argentina.svg" group-title="World Cup UHD",Argentina vs France (4K UHD)
https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8
#EXTINF:-1 tvg-id="wc_ger_esp" tvg-name="Germany vs Spain" tvg-logo="https://upload.wikimedia.org/wikipedia/commons/b/ba/Flag_of_Germany.svg" group-title="World Cup UHD",Germany vs Spain (4K UHD)
http://sample.vodobox.com/planete_m3u8/planete.m3u8
#EXTINF:-1 tvg-id="wc_bra_ita" tvg-name="Brazil vs Italy" tvg-logo="https://upload.wikimedia.org/wikipedia/commons/0/05/Flag_of_Brazil.svg" group-title="World Cup UHD",Brazil vs Italy (4K UHD)
https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8''';
    } else if (urlLower.contains('eurofooty') || urlLower.contains('premium_channels')) {
      return '''#EXTM3U
#EXTINF:-1 tvg-id="mancity_arsenal" tvg-name="Man City vs Arsenal" tvg-logo="https://upload.wikimedia.org/wikipedia/en/e/eb/Manchester_City_FC_badge.svg" group-title="Premier League",Man City vs Arsenal (HD)
https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8
#EXTINF:-1 tvg-id="real_barca" tvg-name="Real Madrid vs Barcelona" tvg-logo="https://upload.wikimedia.org/wikipedia/en/5/56/Real_Madrid_CF.svg" group-title="La Liga",Real Madrid vs Barcelona (HD)
http://sample.vodobox.com/planete_m3u8/planete.m3u8
#EXTINF:-1 tvg-id="juve_milan" tvg-name="Juventus vs AC Milan" tvg-logo="https://upload.wikimedia.org/wikipedia/commons/b/bc/Juventus_FC_2017_icon_%28black%29.svg" group-title="Serie A",Juventus vs AC Milan (HD)
https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8
#EXTINF:-1 tvg-id="bayern_dortmund" tvg-name="Bayern Munich vs Dortmund" tvg-logo="https://upload.wikimedia.org/wikipedia/commons/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282017%29.svg" group-title="Bundesliga",Bayern Munich vs Dortmund (HD)
https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8''';
    } else if (urlLower.contains('vip') || urlLower.contains('xtream')) {
      // Return Xtream Codes mock channels as M3U for parsing
      return '''#EXTM3U
#EXTINF:-1 tvg-id="xtream_sky_prem" tvg-name="Sky Sports PL" group-title="Sports VIP",Sky Sports PL (UHD)
https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8
#EXTINF:-1 tvg-id="xtream_bein1" tvg-name="beIN Sports 1" group-title="Sports VIP",beIN Sports 1 (HD)
https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8
#EXTINF:-1 tvg-id="xtream_espn" tvg-name="ESPN USA" group-title="Sports VIP",ESPN USA (HD)
http://sample.vodobox.com/planete_m3u8/planete.m3u8''';
    } else {
      // Default fallback mock M3U content for any other imported URLs
      return '''#EXTM3U
#EXTINF:-1 tvg-id="fallback_ch1" tvg-name="Custom Channel 1" group-title="Custom",Custom Channel 1 (HD)
https://demo.unified-streaming.com/k8s/live/stable/sintel.smil/.m3u8
#EXTINF:-1 tvg-id="fallback_ch2" tvg-name="Custom Channel 2" group-title="Custom",Custom Channel 2 (HD)
https://playertest.longtailvideo.com/adaptive/bipbop/bipbop.m3u8''';
    }
  }

  /// Parses raw M3U string content into a List of [ChannelModel].
  /// Ignores invalid or comment lines safely.
  static List<ChannelModel> parse(String content) {
    final List<ChannelModel> channels = [];
    if (content.isEmpty) return channels;

    final lines = content.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return channels;

    String? currentExtInf;
    Map<String, String> currentAttributes = {};
    String? currentChannelName;
    String? currentGroup;

    int generatedIdCounter = 1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Handle #EXTINF: line which contains metadata attributes and channel name
      if (line.startsWith('#EXTINF:')) {
        currentExtInf = line;
        currentAttributes = _parseAttributes(line);
        currentChannelName = _parseChannelName(line);
        currentGroup = null; // Reset group for this channel block
      }
      // Handle #EXTGRP: line which is a fallback mechanism for grouping
      else if (line.startsWith('#EXTGRP:')) {
        currentGroup = line.substring(8).trim();
      }
      // Skip other comment/header lines
      else if (line.startsWith('#')) {
        continue;
      }
      // This is a stream URL line
      else {
        if (currentExtInf != null) {
          final streamUrl = line;

          final tvgId = currentAttributes['tvg-id'];
          final tvgName = currentAttributes['tvg-name'];
          final tvgLogo = currentAttributes['tvg-logo'];
          
          // Use #EXTGRP group, group-title attribute, or fallback to 'Other'
          final groupTitle = currentGroup ?? currentAttributes['group-title'] ?? 'Other';

          // Establish clean, unique ID for database and favorites referencing
          final id = tvgId != null && tvgId.trim().isNotEmpty
              ? tvgId.trim()
              : 'ch_${generatedIdCounter++}_${_generateHash(streamUrl)}';

          channels.add(ChannelModel(
            id: id,
            name: currentChannelName ?? tvgName ?? 'Channel $generatedIdCounter',
            streamUrl: streamUrl,
            logoUrl: tvgLogo,
            categoryId: _normalizeCategoryName(groupTitle),
            epgId: tvgId,
            isFavorite: false,
          ));

          // Reset the parser state for the next stream block
          currentExtInf = null;
          currentAttributes = {};
          currentChannelName = null;
          currentGroup = null;
        }
      }
    }

    return channels;
  }

  /// Parses key="value" attributes out of an #EXTINF line.
  /// Handles both standard quoted values and optional unquoted parameters.
  static Map<String, String> _parseAttributes(String line) {
    final Map<String, String> attributes = {};

    // Pattern to match attributes: key="value"
    final quotedRegex = RegExp(r'([\w-]+)="([^"]*)"');
    final quotedMatches = quotedRegex.allMatches(line);

    for (final match in quotedMatches) {
      final key = match.group(1)?.toLowerCase();
      final value = match.group(2);
      if (key != null && value != null) {
        attributes[key] = value;
      }
    }

    // Pattern fallback for unquoted attributes: key=value
    final unquotedRegex = RegExp(r'([\w-]+)=([^\s",]+)');
    final unquotedMatches = unquotedRegex.allMatches(line);

    for (final match in unquotedMatches) {
      final key = match.group(1)?.toLowerCase();
      final value = match.group(2);
      if (key != null && value != null && !attributes.containsKey(key)) {
        attributes[key] = value;
      }
    }

    return attributes;
  }

  /// Extracts the channel display name following the final comma on the #EXTINF line.
  static String? _parseChannelName(String line) {
    final commaIndex = line.lastIndexOf(',');
    if (commaIndex == -1 || commaIndex == line.length - 1) {
      return null;
    }
    return line.substring(commaIndex + 1).trim();
  }

  /// Cleans and normalizes group/category titles to prevent duplicate structural tabs.
  static String _normalizeCategoryName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Other';
    return trimmed;
  }

  /// Utility hash to generate distinct reproducible string keys based on stream URLs.
  static String _generateHash(String input) {
    return input.hashCode.toRadixString(16);
  }

  /// Groups the list of parsed channels by their respective category ID.
  static Map<String, List<ChannelModel>> groupByCategory(List<ChannelModel> channels) {
    final Map<String, List<ChannelModel>> groups = {};

    for (final channel in channels) {
      final category = channel.categoryId;
      groups.putIfAbsent(category, () => []).add(channel);
    }

    return groups;
  }

  /// Extracts category metadata, counting channel distributions across groups.
  static List<CategoryModel> extractCategories(List<ChannelModel> channels) {
    final Map<String, int> counts = {};

    for (final channel in channels) {
      final catId = channel.categoryId;
      counts[catId] = (counts[catId] ?? 0) + 1;
    }

    return counts.entries.map((entry) {
      return CategoryModel(
        id: entry.key,
        name: entry.key,
        channelCount: entry.value,
        type: _detectCategoryType(entry.key),
      );
    }).toList();
  }

  /// Contextually identifies the class type of a category (Sports, News, Movies, etc.)
  /// based on standard IPTV keyword matching.
  static String _detectCategoryType(String categoryName) {
    final nameLower = categoryName.toLowerCase();
    if (nameLower.contains('sport') || nameLower.contains('live') || nameLower.contains('tv')) {
      return 'live';
    }
    if (nameLower.contains('movie') || nameLower.contains('cinema') || nameLower.contains('film')) {
      return 'movie';
    }
    if (nameLower.contains('series') || nameLower.contains('show') || nameLower.contains('season')) {
      return 'series';
    }
    return 'general';
  }
}
