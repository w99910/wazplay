import 'dart:developer';
import 'dart:io';

import 'package:wazeloquent/wazeloquent.dart';
import 'package:wazplay/support/eloquents/song.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/models/artist.dart';
import 'package:wazplay/support/models/song.dart';

class SongController {
  final SongEloquent songEloquent = SongEloquent();

  Future<List<Song>> all({
    int? limit,
    String? orderBy,
    String? groupBy,
    bool? distinct,
    bool descending = false,
    int? offset,
  }) async {
    var el = songEloquent
        .orderBy(orderBy, sort: descending ? Sort.descending : Sort.ascending)
        .skip(offset)
        .take(limit);
    if (distinct != null && distinct) {
      el = el.distinct([]);
    }
    var data = await el.get();
    return fromDB(data);
  }

  Future<List<Song>> fromDB(List<Map<String, Object?>> rows) async {
    List<Song> songs = [];
    for (var song in rows) {
      songs.add(Song.fromDB(song));
    }
    return songs;
  }

  Future<List<Song>> search({
    String? keyword,
    int? offset,
    int limit = 10,
  }) async {
    if (keyword == null) return all(limit: limit, offset: offset);
    var data = await songEloquent.search(
      keyword,
      searchableColumns: ['title', 'author'],
    );
    return fromDB(data);
  }

  Future updateItem({
    required String id,
    required Map<String, Object?> update,
  }) async {
    return songEloquent.where('id', id.toString()).update(update);
  }

  Future<List<Artist>> getArtists({String? keyword}) async {
    List<Artist> artists = [];
    List<String> titles = [];
    var response =
        keyword != null
            ? await songEloquent.search(keyword, searchableColumns: ['title'])
            : await songEloquent.select(['title', 'author']).get();

    int count = 0;
    for (var row in response!) {
      List<String> split = row['title'].toString().split('-');
      String artist = Artist.extractArtistName(split[0]);
      if (artists.where((val) => val.name == artist).isEmpty) {
        String? thumbnail, bio;
        Map<String, dynamic>? details = await Artist.getDetails(artist);
        if (details != null) {
          thumbnail = details['strArtistThumb'];
          bio = details['strBiographyEN'];
        } else {
          artist = row['author'].toString();
        }
        if (count < 5) {
          artists.add(Artist(name: artist, thumbnail: thumbnail, bio: bio));
        }
        if (keyword == null) {
          count += 1;
        }
      }
    }
    return artists;
    // var distinctArtists = songEloquent.
  }

  Future<List<Song>> getSongsByArtist(Artist artist) async {
    List<Song> songs = [];
    var response = await songEloquent.search(
      artist.name,
      searchableColumns: ['title'],
    );
    for (var row in response) {
      songs.add(Song.fromDB(row));
    }
    return songs;
  }

  Future deleteSong(Playable playable) async {
    //delete audio
    File audio = File(playable.getAudioPath());
    if (await audio.exists()) {
      await audio.delete();
    }
    // Delete thumbnail if exists
    String? thumbnail = playable.getThumbnailPath();
    if (thumbnail != null) {
      File thumbnailPath = File(thumbnail);
      if (await thumbnailPath.exists()) {
        await thumbnailPath.delete();
      }
    }
    return await songEloquent.deleteBy(playable.getId());
  }
}
