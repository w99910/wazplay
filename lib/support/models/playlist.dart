class Playlist {
  int id;
  String? description;
  List<int> songs;
  DateTime? createdAt;
  DateTime? updatedAt;
  Playlist(
      {required this.id,
      required this.songs,
      this.description = '',
      this.createdAt,
      this.updatedAt});

  factory Playlist.fromDB(Map<String, dynamic> data) {
    List<String> songs = data[PlaylistFields.songs].toString().split(',');
    return Playlist(
        songs: data[PlaylistFields.songs],
        id: data[PlaylistFields.id],
        description: data[PlaylistFields.description],
        createdAt: DateTime.tryParse(data[PlaylistFields.createdAt]),
        updatedAt: DateTime.tryParse(data[PlaylistFields.updatedAt]));
  }
}

class PlaylistFields {
  static const id = 'id';
  static const description = 'description';
  static const songs = 'songs';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
