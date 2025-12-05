import 'dart:async';
import 'dart:typed_data';

/// Playback mode for an [AudioPlayer].
enum LoopMode {
  /// No looping
  off,

  /// Repeat the current track
  one,

  /// Repeat the entire playlist
  all,
}

/// Abstract representation of an audio source.
abstract final class AudioSource {
  /// Accepts a visitor to handle the audio source based on its type.
  T accept<T>(AudioSourceVisitor<T> visitor);
}

/// Visitor interface used to handle each specific type of [AudioSource].
///
/// This interface follows the visitor design pattern,
/// allowing operations to be performed on different [AudioSource] subtypes
/// without knowing their concrete implementation.
abstract class AudioSourceVisitor<T> {
  /// Called when visiting an [AssetAudioSource].
  T visitAssetSource(AssetAudioSource source);

  /// Called when visiting a [FilepathAudioSource].
  T visitFilepathSource(FilepathAudioSource source);

  /// Called when visiting a [NetworkAudioSource].
  T visitNetworkSource(NetworkAudioSource source);

  /// Called when visiting a [PlaylistSource].
  T visitPlaylistSource(PlaylistSource source);

  /// Called when visiting a [FutureBytesAudioSource].
  T visitBytesSource(FutureBytesAudioSource bytesAudioSource);
}

/// Audio source from an asset included in the project.
final class AssetAudioSource implements AudioSource {
  const AssetAudioSource(this.path);

  /// Path to the asset.
  final String path;

  @override
  T accept<T>(AudioSourceVisitor<T> visitor) {
    return visitor.visitAssetSource(this);
  }
}

/// Audio source from a local file path.
final class FilepathAudioSource implements AudioSource {
  const FilepathAudioSource(this.path);

  /// Path to the local file.
  final String path;

  @override
  T accept<T>(AudioSourceVisitor<T> visitor) {
    return visitor.visitFilepathSource(this);
  }
}

/// Audio source from a network URL.
final class NetworkAudioSource implements AudioSource {
  const NetworkAudioSource(this.url);

  /// URL of the audio file.
  final String url;

  @override
  T accept<T>(AudioSourceVisitor<T> visitor) {
    return visitor.visitNetworkSource(this);
  }
}

/// Playlist composed of multiple [AudioSource]s.
final class PlaylistSource implements AudioSource {
  const PlaylistSource(this.list);

  /// List of audio sources in the playlist.
  final List<AudioSource> list;

  @override
  T accept<T>(AudioSourceVisitor<T> visitor) {
    return visitor.visitPlaylistSource(this);
  }
}

/// Audio source from bytes provided asynchronously.
final class FutureBytesAudioSource implements AudioSource {
  const FutureBytesAudioSource(this.bytesFuture);

  /// Future returning the audio bytes.
  final Future<Uint8List> bytesFuture;

  @override
  T accept<T>(AudioSourceVisitor<T> visitor) {
    return visitor.visitBytesSource(this);
  }
}

/// Central controller for all audio and visual effects players.
abstract class Maestro {
  MusicPlayer get musicPlayer;

  AudioPlayer get voicePlayer;

  VfxPlayer get vfxPlayer;

  /// Resume all the players.
  Future<void> resume();

  /// Pause all the players.
  Future<void> pause();

  /// Dispose resources.
  Future<void> dispose();
}

/// Player for visual/audio effects.
abstract class VfxPlayer {
  /// Play an asset.
  Future<void> playAsset(String path);

  /// Dispose resources.
  Future<void> dispose();
}

/// Music player handling playlists or individual tracks.
abstract class MusicPlayer {
  /// Stream of the current track index.
  Stream<int?>? get currentIndexStream;

  /// Push a new asset to the player.
  Future<void> pushAsset(String path);

  /// Replace current track with a new asset.
  Future<void> replaceAsset(String path);

  /// Push an [AudioSource].
  Future<void> pushAudioSource(AudioSource source);

  /// Replace current track with an [AudioSource].
  Future<void> replaceAudioSource(AudioSource source);

  /// Pop the last pushed track.
  Future<void> pop();

  /// Pause playback.
  Future<void> pause();

  /// Dispose resources.
  Future<void> dispose();

  /// Start playback.
  Future<void> play();

  /// Restart the current music
  Future<void> restart();

  /// Returns the duration of current music
  /// from a specific track in the playlist.
  ///
  /// If the playlist contains only one track, this method returns its duration,
  /// ignoring the [index] parameter.
  /// Otherwise, it returns the duration of the track at the given [index].
  Duration getTrackDuration(int index);
}

/// Player for single audio tracks, like voice or effects.
abstract class AudioPlayer {
  /// Stream notifying when playback is completed.
  Stream<void> get completedStream;

  /// Stream of the current track index.
  Stream<int?> get currentIndexStream;

  /// Stream of playing state.
  Stream<bool> get playingStream;

  /// Total duration of the current track.
  Duration? get duration;

  /// Current playback position.
  Duration? get position;

  /// Whether the player is currently playing.
  bool get playing;

  /// Future completed when the resource is set.
  Future<void>? get resourceSetFuture;

  /// Stop playback.
  Future<void> stop();

  /// Dispose resources. Do not call stop() immediately before dispose().
  Future<void> dispose();

  /// Set the asset to play.
  Future<Duration?> setAsset(String path);

  /// Set a local file path to play.
  Future<Duration?> setFilepath(String path);

  /// Set an [AudioSource] to play.
  Future<Duration?> setAudioSource(AudioSource source);

  /// Start playback.
  Future<void> play();

  /// Pause playback.
  Future<void> pause();

  /// Seek to a specific position.
  Future<void> seek(Duration? duration, {int? index});

  /// Move by a relative duration.
  Future<void> move(Duration duration);

  /// Set playback volume (0.0 to 1.0).
  Future<void> setVolume(double volume);

  /// Set loop mode.
  Future<void> setLoopMode(LoopMode mode);

  /// Returns the duration of a specific track in the playlist.
  ///
  /// If the playlist contains only one track, this method returns its duration,
  /// ignoring the [index] parameter.
  /// Otherwise, it returns the duration of the track at the given [index].
  Duration getTrackDuration(int index);
}
