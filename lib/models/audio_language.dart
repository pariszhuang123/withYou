class AudioLanguage {
  const AudioLanguage({
    required this.localeTag,
    required this.displayName,
    required this.isBundled,
  });

  final String localeTag;
  final String displayName;
  final bool isBundled;
}

enum AudioLanguagePackStatus {
  notDownloaded,
  downloading,
  downloaded,
  failed,
  updateAvailable,
}

class AudioLanguagePackRecord {
  const AudioLanguagePackRecord({
    required this.localeTag,
    required this.status,
    this.version,
    this.checksum,
    this.localRootPath,
    this.downloadedAtUtc,
  });

  final String localeTag;
  final AudioLanguagePackStatus status;
  final String? version;
  final String? checksum;
  final String? localRootPath;
  final DateTime? downloadedAtUtc;

  bool get isReadyOffline => status == AudioLanguagePackStatus.downloaded;

  AudioLanguagePackRecord copyWith({
    AudioLanguagePackStatus? status,
    String? version,
    String? checksum,
    String? localRootPath,
    DateTime? downloadedAtUtc,
  }) {
    return AudioLanguagePackRecord(
      localeTag: localeTag,
      status: status ?? this.status,
      version: version ?? this.version,
      checksum: checksum ?? this.checksum,
      localRootPath: localRootPath ?? this.localRootPath,
      downloadedAtUtc: downloadedAtUtc ?? this.downloadedAtUtc,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'localeTag': localeTag,
      'status': status.name,
      'version': version,
      'checksum': checksum,
      'localRootPath': localRootPath,
      'downloadedAtUtc': downloadedAtUtc?.toUtc().toIso8601String(),
    };
  }

  factory AudioLanguagePackRecord.fromJson(Map<String, Object?> json) {
    return AudioLanguagePackRecord(
      localeTag: json['localeTag']! as String,
      status: AudioLanguagePackStatus.values.byName(json['status']! as String),
      version: json['version'] as String?,
      checksum: json['checksum'] as String?,
      localRootPath: json['localRootPath'] as String?,
      downloadedAtUtc: switch (json['downloadedAtUtc']) {
        final String value => DateTime.parse(value).toUtc(),
        _ => null,
      },
    );
  }
}

class AudioLanguageAvailability {
  const AudioLanguageAvailability({
    required this.language,
    required this.status,
    required this.isSelected,
  });

  final AudioLanguage language;
  final AudioLanguagePackStatus status;
  final bool isSelected;

  bool get isReadyOffline =>
      language.isBundled || status == AudioLanguagePackStatus.downloaded;
}
