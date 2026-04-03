import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../models/playable_audio_source.dart';

class AudioPlaybackService implements AudioPlaybackContract {
  AudioPlaybackService({
    PlaybackHandle? ringtoneHandle,
    PlaybackHandle? clipHandle,
  }) : _ringtoneHandle = ringtoneHandle ?? JustAudioPlaybackHandle(),
       _clipHandle = clipHandle ?? JustAudioPlaybackHandle();

  final PlaybackHandle _ringtoneHandle;
  final PlaybackHandle _clipHandle;

  @override
  Future<void> playRingtoneLoop({
    required PlayableAudioSource source,
  }) async {
    await _clipHandle.stop();
    await _ringtoneHandle.stop();
    await _loadSource(_ringtoneHandle, source);
    await _ringtoneHandle.setLoopMode(PlaybackLoopMode.one);
    unawaited(_ringtoneHandle.play());
  }

  @override
  Future<void> playScenarioClip({
    required Scenario scenario,
    required int stage,
    required PlayableAudioSource source,
  }) async {
    await _ringtoneHandle.stop();
    await _clipHandle.stop();
    await _loadSource(_clipHandle, source);
    await _clipHandle.setLoopMode(PlaybackLoopMode.off);
    await _clipHandle.play();
  }

  @override
  Future<void> stop() async {
    await _ringtoneHandle.stop();
    await _clipHandle.stop();
  }

  Future<void> _loadSource(
    PlaybackHandle handle,
    PlayableAudioSource source,
  ) {
    return switch (source) {
      BundledAudioSource(:final assetPath) => handle.setAsset(assetPath),
      FileAudioSource(:final filePath) => handle.setFilePath(filePath),
    };
  }
}

enum PlaybackLoopMode { off, one }

abstract class PlaybackHandle {
  Future<void> setAsset(String assetPath);

  Future<void> setFilePath(String filePath);

  Future<void> setLoopMode(PlaybackLoopMode mode);

  Future<void> play();

  Future<void> stop();
}

class JustAudioPlaybackHandle implements PlaybackHandle {
  JustAudioPlaybackHandle() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> setAsset(String assetPath) async {
    await _player.setAsset(assetPath);
  }

  @override
  Future<void> setFilePath(String filePath) async {
    await _player.setFilePath(filePath);
  }

  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) {
    return _player.setLoopMode(
      switch (mode) {
        PlaybackLoopMode.off => LoopMode.off,
        PlaybackLoopMode.one => LoopMode.one,
      },
    );
  }

  @override
  Future<void> play() {
    return _player.play();
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }
}
