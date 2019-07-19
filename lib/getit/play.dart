import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

abstract class PlayModel {
  void success();

  void error();
}

class PlayModelImpl extends PlayModel {
//  AudioPlayer _audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  final AudioCache _audioCache = AudioCache(
      prefix: "audios/",
      fixedPlayer: AudioPlayer(mode: PlayerMode.LOW_LATENCY));

  void success() async {
    await _audioCache.play("success.mp3");
  }

  void error() async {
//    AudioPlayer.logEnabled = true;
    await _audioCache.play("error.mp3");
  }
}
