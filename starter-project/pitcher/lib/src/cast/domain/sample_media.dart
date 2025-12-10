import 'package:pitcher/src/cast/cast_service.dart';

/// Sample media for demo purposes.
/// In production, metadata would come from your API.
abstract final class SampleMedia {
  static final video = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    title: 'Big Buck Bunny',
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/800px-Big_buck_bunny_poster_big.jpg',
    contentType: 'video/mp4',
    duration: 596000,
  );

  static final audio = MediaInfo(
    contentUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    title: 'SoundHelix Song 1',
    subtitle: 'SoundHelix',
    mediaType: MediaType.audio,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Mona_Lisa.jpg/800px-Mona_Lisa.jpg',
    contentType: 'audio/mpeg',
    duration: 373000,
  );
}
