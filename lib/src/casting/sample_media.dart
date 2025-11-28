// =============================================================================
// SAMPLE MEDIA - Demo content for workshop
// =============================================================================
// Publicly available media for testing cast functionality.
// These URLs are CORS-enabled and work with Chromecast receivers.
// =============================================================================

import 'casting_api.g.dart';

/// Sample media content for the workshop demo.
///
/// These are publicly available, CORS-enabled media files that work
/// reliably with both Chromecast and AirPlay.
///
/// Uses `abstract final class` (Dart 3.0+) to prevent instantiation
/// and extension - this is a namespace for static constants only.
abstract final class SampleMedia {
  // ---------------------------------------------------------------------------
  // VIDEO SAMPLES
  // ---------------------------------------------------------------------------

  /// Big Buck Bunny - Blender Foundation (CC-BY)
  /// A classic test video used by Google in their Cast samples.
  static final MediaInfo bigBuckBunny = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    title: 'Big Buck Bunny',
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/800px-Big_buck_bunny_poster_big.jpg',
    contentType: 'video/mp4',
    duration: 596000, // 9:56
  );

  /// Sintel - Blender Foundation (CC-BY)
  static final MediaInfo sintel = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    title: 'Sintel',
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Sintel_movie_poster.jpg/800px-Sintel_movie_poster.jpg',
    contentType: 'video/mp4',
    duration: 888000, // 14:48
  );

  /// Tears of Steel - Blender Foundation (CC-BY)
  static final MediaInfo tearsOfSteel = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    title: 'Tears of Steel',
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Tears_of_Steel_Cover.jpg/800px-Tears_of_Steel_Cover.jpg',
    contentType: 'video/mp4',
    duration: 734000, // 12:14
  );

  /// Elephant's Dream - Blender Foundation (CC-BY)
  static final MediaInfo elephantsDream = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    title: "Elephant's Dream",
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Elephants_Dream_cover.jpg/800px-Elephants_Dream_cover.jpg',
    contentType: 'video/mp4',
    duration: 653000, // 10:53
  );

  // ---------------------------------------------------------------------------
  // AUDIO SAMPLES
  // ---------------------------------------------------------------------------

  /// Sample audio track 1
  static final MediaInfo audioSample1 = MediaInfo(
    contentUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    title: 'SoundHelix Song 1',
    subtitle: 'SoundHelix',
    mediaType: MediaType.audio,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Mona_Lisa.jpg/800px-Mona_Lisa.jpg',
    contentType: 'audio/mpeg',
    duration: 373000, // 6:13
  );

  /// Sample audio track 2
  static final MediaInfo audioSample2 = MediaInfo(
    contentUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    title: 'SoundHelix Song 2',
    subtitle: 'SoundHelix',
    mediaType: MediaType.audio,
    contentType: 'audio/mpeg',
    duration: 325000, // 5:25
  );

  // ---------------------------------------------------------------------------
  // SAMPLE LISTS
  // ---------------------------------------------------------------------------

  /// All video samples.
  static final List<MediaInfo> allVideos = [
    bigBuckBunny,
    sintel,
    tearsOfSteel,
    elephantsDream,
  ];

  /// All audio samples.
  static final List<MediaInfo> allAudio = [audioSample1, audioSample2];

  /// All samples (video + audio).
  static final List<MediaInfo> all = [...allVideos, ...allAudio];
}
