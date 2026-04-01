sealed class PlayableAudioSource {
  const PlayableAudioSource();
}

class BundledAudioSource extends PlayableAudioSource {
  const BundledAudioSource({required this.assetPath});

  final String assetPath;
}

class FileAudioSource extends PlayableAudioSource {
  const FileAudioSource({required this.filePath});

  final String filePath;
}

class ResolvedPlayableAudio {
  const ResolvedPlayableAudio({
    required this.localeTag,
    required this.source,
  });

  final String localeTag;
  final PlayableAudioSource source;
}
