import 'package:wazplay/support/interfaces/previewable.dart';

class Song implements PreviewAble {
  String title, author, path;
  String? description, imagePlaceholder;
  DateTime? createdAt, updatedAt;
  Duration? currentDuration;
  Song({
    required this.title,
    required this.author,
    required this.path,
    this.description,
    this.imagePlaceholder,
    this.createdAt,
    this.updatedAt,
    Duration currentDuration = Duration.zero,
  });

  static List<Song> dummyData = [
    Song(
        title: 'Mantra',
        author: 'Bring Me The Horizon',
        path: 'Path',
        imagePlaceholder:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTz-uN2qM2DH70_IdrOqnRDW3yR5vn_LlpGRnU8Oevso0rrtGTfI5rzxSwiLfB72HRy52w&usqp=CAU'),
    Song(
        title: 'Die4U',
        author: 'Bring Me The Horizon',
        path: 'Path',
        imagePlaceholder:
            'https://i.ytimg.com/vi/IPUUbVhvqrE/maxresdefault.jpg')
  ];

  @override
  String getDescription() {
    return description ?? '';
  }

  @override
  String? getImagePlaceholder() {
    return imagePlaceholder;
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
  Function? onClick(PreviewAble item) {
    // return ;
  }
}
