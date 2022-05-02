import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart'
    show MediaItem;
import 'package:wazplay/support/eloquents/song.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/interfaces/previewable.dart';

class Song implements PreviewAble, Playable {
  int id;
  String title, author, path;
  String? description, thumbnail;
  DateTime? createdAt, updatedAt;
  Duration? currentDuration;
  Song({
    required this.id,
    required this.title,
    required this.author,
    required this.path,
    this.description,
    this.thumbnail,
    this.createdAt,
    this.updatedAt,
    Duration currentDuration = Duration.zero,
  });

  Map<String, Object?> toJson() {
    return {
      SongFields.id: id,
      SongFields.title: title,
      SongFields.author: author,
      SongFields.path: path,
      SongFields.description: description,
      SongFields.thumbnail: thumbnail,
      SongFields.createdAt:
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      SongFields.updatedAt:
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      SongFields.currentDuration: getInitialDuration().inMilliseconds.toString()
    };
  }

  // static Map<String,String>

  factory Song.temp(Map<String, String> data) {
    return Song(
        id: 1,
        title: data['title']!,
        author: data['author']!,
        description: data['description'],
        thumbnail: data['thumbnail'],
        path: data['path'] ?? '');
  }

  factory Song.fromDB(Map<String, dynamic> data) {
    return Song(
        id: data[SongFields.id],
        title: data[SongFields.title],
        author: data[SongFields.author],
        path: data[SongFields.path],
        thumbnail: data[SongFields.thumbnail],
        description: data[SongFields.description],
        createdAt: DateTime.parse(data[SongFields.createdAt]),
        updatedAt: DateTime.parse(data[SongFields.updatedAt]),
        currentDuration: Duration(
            milliseconds: int.parse(data[SongFields.currentDuration])));
  }

  static List<Song> dummyData = [
    Song(
        id: 0,
        title: 'Mantra',
        author: 'Bring Me The Horizon',
        path: 'Path',
        thumbnail:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTz-uN2qM2DH70_IdrOqnRDW3yR5vn_LlpGRnU8Oevso0rrtGTfI5rzxSwiLfB72HRy52w&usqp=CAU'),
    Song(
        id: 1,
        title: 'Die4U',
        author: 'Bring Me The Horizon',
        path: 'Path',
        thumbnail: 'https://i.ytimg.com/vi/IPUUbVhvqrE/maxresdefault.jpg')
  ];

  @override
  String getDescription() {
    return description ?? '';
  }

  @override
  String? getImagePlaceholder() {
    return thumbnail;
  }

  @override
  String getSubtitle() {
    return author;
  }

  @override
  String getTitle() {
    return title;
  }

  @override
  void onClick(PreviewAble item) {
    // return () => {};
  }

  save() async {
    var songEloquent = SongEloquent();
    songEloquent
        .createIfNotExists(check: {SongFields.title: title}, create: toJson());
  }

  @override
  String getAudioPath() {
    return path;
  }

  @override
  AudioSource getAudioSource() {
    var reg = RegExp(r'^(https|http):\/\/', caseSensitive: false);
    bool isOnline = reg.hasMatch(path);
    Uri _uri = isOnline ? Uri.parse(path) : Uri.file(path);
    MediaItem mediaItem = MediaItem(
        id: id.toString(),
        title: title,
        extras: {
          "description": description,
          'url': path,
          'thumbnailUrl': thumbnail,
          'createdAt': createdAt?.toIso8601String(),
          'updatedAt': updatedAt?.toIso8601String(),
          'lastListenedTime': updatedAt?.toIso8601String(),
          'currentDuration': getInitialDuration()
        },
        album: 'URights - Podcast');
    return isOnline
        ? LockCachingAudioSource(_uri, tag: mediaItem)
        : AudioSource.uri(_uri);
  }

  @override
  Duration getInitialDuration() {
    return currentDuration ?? Duration.zero;
  }

  @override
  String? getThumbnailPath() {
    return thumbnail;
  }

  @override
  String getAuthor() {
    return author;
  }
}

class SongFields {
  static const id = 'id';
  static const title = 'title';
  static const author = 'author';
  static const path = 'path';
  static const description = 'description';
  static const thumbnail = 'thumbnail';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const currentDuration = 'currentDuration';
}
