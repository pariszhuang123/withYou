import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/platform_contracts.dart';
import '../models/playable_audio_source.dart';

typedef AssetAvailabilityChecker = Future<bool> Function(String assetPath);

class AudioPlaybackService implements AudioPlaybackContract {
  AudioPlaybackService({
    required KinlyLoggerContract logger,
    PlaybackHandle? ringtoneHandle,
    PlaybackHandle? clipHandle,
    AssetAvailabilityChecker? assetAvailabilityChecker,
  }) : _logger = logger,
       _ringtoneHandle = ringtoneHandle ?? JustAudioPlaybackHandle(),
       _clipHandle = clipHandle ?? JustAudioPlaybackHandle(),
       _assetAvailabilityChecker =
           assetAvailabilityChecker ?? _defaultAssetAvailabilityChecker;

  final KinlyLoggerContract _logger;
  final PlaybackHandle _ringtoneHandle;
  final PlaybackHandle _clipHandle;
  final AssetAvailabilityChecker _assetAvailabilityChecker;

  @override
  Future<void> playRingtoneLoop({required PlayableAudioSource source}) async {
    try {
      await _clipHandle.stop();
      await _ringtoneHandle.stop();
      await _loadSource(_ringtoneHandle, source);
      await _ringtoneHandle.setLoopMode(PlaybackLoopMode.one);
      unawaited(_ringtoneHandle.play());
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to start ringtone playback',
        category: 'audio',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> playScenarioClip({
    required Scenario scenario,
    required int stage,
    required PlayableAudioSource source,
  }) async {
    try {
      await _ringtoneHandle.stop();
      await _clipHandle.stop();
      await _loadSource(_clipHandle, source);
      await _clipHandle.setLoopMode(PlaybackLoopMode.off);
      await _clipHandle.play();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to play scenario clip for ${scenario.name} stage $stage',
        category: 'audio',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _ringtoneHandle.stop();
      await _clipHandle.stop();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to stop audio playback',
        category: 'audio',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadSource(
    PlaybackHandle handle,
    PlayableAudioSource source,
  ) async {
    switch (source) {
      case BundledAudioSource(:final assetPath):
        if (!await _assetAvailabilityChecker(assetPath)) {
          throw StateError('Bundled audio asset is unavailable: $assetPath');
        }
        await handle.setAsset(assetPath);
      case FileAudioSource(:final filePath):
        await handle.setFilePath(filePath);
    }
  }

  static Future<bool> _defaultAssetAvailabilityChecker(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
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
    return _player.setLoopMode(switch (mode) {
      PlaybackLoopMode.off => LoopMode.off,
      PlaybackLoopMode.one => LoopMode.one,
    });
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
