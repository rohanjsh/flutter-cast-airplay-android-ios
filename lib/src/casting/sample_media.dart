import 'casting_api.g.dart';

abstract final class SampleMedia {
  static final MediaInfo bigBuckBunny = MediaInfo(
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

  static final MediaInfo sintel = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    title: 'Sintel',
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Sintel_movie_poster.jpg/800px-Sintel_movie_poster.jpg',
    contentType: 'video/mp4',
    duration: 888000,
  );

  static final MediaInfo tearsOfSteel = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    title: 'Tears of Steel',
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Tears_of_Steel_Cover.jpg/800px-Tears_of_Steel_Cover.jpg',
    contentType: 'video/mp4',
    duration: 734000,
  );

  static final MediaInfo elephantsDream = MediaInfo(
    contentUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    title: "Elephant's Dream",
    subtitle: 'Blender Foundation',
    mediaType: MediaType.video,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Elephants_Dream_cover.jpg/800px-Elephants_Dream_cover.jpg',
    contentType: 'video/mp4',
    duration: 653000,
  );

  static final MediaInfo audioSample1 = MediaInfo(
    contentUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    title: 'SoundHelix Song 1',
    subtitle: 'SoundHelix',
    mediaType: MediaType.audio,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Mona_Lisa.jpg/800px-Mona_Lisa.jpg',
    contentType: 'audio/mpeg',
    duration: 373000,
  );

  static final MediaInfo audioSample2 = MediaInfo(
    contentUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    title: 'SoundHelix Song 2',
    subtitle: 'SoundHelix',
    mediaType: MediaType.audio,
    contentType: 'audio/mpeg',
    duration: 325000,
  );

  static final List<MediaInfo> allVideos = [
    bigBuckBunny,
    sintel,
    tearsOfSteel,
    elephantsDream,
  ];

  static final List<MediaInfo> allAudio = [audioSample1, audioSample2];

  static final List<MediaInfo> all = [...allVideos, ...allAudio];
}
