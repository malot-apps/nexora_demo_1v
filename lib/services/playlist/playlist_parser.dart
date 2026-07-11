import '../../models/category_model.dart';
import '../../models/channel_model.dart';

/// Clean Architecture Parser module for handling M3U playlists.
/// Reads raw lines, parses tags (#EXTM3U, #EXTINF, tvg-logo, group-title),
/// and outputs list records of categories and channels.
class PlaylistParser {
  
  /// Parses M3U playlist file content.
  /// Categorizes stream endpoints and registers active video sources.
  Future<Map<String, dynamic>> parseM3u(String rawM3uText) async {
    final List<ChannelModel> channels = [];
    final Set<String> categoryNames = {};
    
    final List<String> lines = rawM3uText.split('\n');
    
    // Check if the file is a valid M3U stream file
    if (lines.isEmpty || !lines[0].trim().startsWith('#EXTM3U')) {
      throw Exception('Invalid M3U file format. First line must start with #EXTM3U');
    }

    String currentTvgLogo = '';
    String currentGroupName = 'Default';
    String currentChannelName = '';
    String currentEpgId = '';

    for (int i = 1; i < lines.length; i++) {
      final String line = lines[i].trim();
      
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF:')) {
        // Parse metadata tags from #EXTINF line
        currentChannelName = _parseChannelName(line);
        currentGroupName = _parseAttribute(line, 'group-title') ?? 'Default';
        currentTvgLogo = _parseAttribute(line, 'tvg-logo') ?? '';
        currentEpgId = _parseAttribute(line, 'tvg-id') ?? '';
        
        categoryNames.add(currentGroupName);
      } else if (!line.startsWith('#')) {
        // This is the stream URL line
        final String streamUrl = line;
        final String uniqueId = streamUrl.hashCode.toString();

        channels.add(
          ChannelModel(
            id: uniqueId,
            name: currentChannelName.isEmpty ? 'Channel $uniqueId' : currentChannelName,
            streamUrl: streamUrl,
            logoUrl: currentTvgLogo.isEmpty ? null : currentTvgLogo,
            categoryId: currentGroupName.toLowerCase().replaceAll(' ', '_'),
            epgId: currentEpgId.isEmpty ? null : currentEpgId,
          ),
        );

        // Reset channel metadata for next iteration
        currentChannelName = '';
        currentTvgLogo = '';
        currentEpgId = '';
      }
    }

    // Convert parsed categories to models
    final List<CategoryModel> categories = categoryNames.map((name) {
      final String id = name.toLowerCase().replaceAll(' ', '_');
      final int count = channels.where((c) => c.categoryId == id).length;
      return CategoryModel(id: id, name: name, channelCount: count);
    }).toList();

    return {
      'channels': channels,
      'categories': categories,
    };
  }

  /// Helper to extract attribute values like group-title="Sports"
  String? _parseAttribute(String line, String attributeName) {
    final RegExp regExp = RegExp('$attributeName="([^"]*)"', caseSensitive: false);
    final Match? match = regExp.firstMatch(line);
    return match?.group(1);
  }

  /// Helper to extract channel names which are placed at the end of the #EXTINF line
  String _parseChannelName(String line) {
    final int lastCommaIndex = line.lastIndexOf(',');
    if (lastCommaIndex != -1 && lastCommaIndex < line.length - 1) {
      return line.substring(lastCommaIndex + 1).trim();
    }
    return '';
  }
}
