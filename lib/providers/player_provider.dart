import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel_model.dart';

/// A Riverpod provider to manage the currently selected channel for playback.
final selectedChannelProvider = StateProvider<ChannelModel?>((ref) => null);
