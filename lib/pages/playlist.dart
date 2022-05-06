import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/playlist_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/widgets/music_player.dart';
import 'package:wazplay/widgets/preview.dart';

class PlaylistWidget extends StatefulWidget {
  final Playlist playlist;
  const PlaylistWidget({Key? key, required this.playlist}) : super(key: key);

  @override
  State<PlaylistWidget> createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  late Playlist playlist;
  late PlaylistController playlistController;
  late SongController songController;
  late MusicController musicController;
  List<Song> songs = [];
  bool loading = true;
  bool editing = false;
  List<Song> selectedSongs = [];
  @override
  void initState() {
    playlistController = PlaylistController();
    songController = SongController();
    musicController = Get.find<MusicController>();
    playlist = widget.playlist;
    super.initState();
    load();
    musicController.shouldReloadSongs.listen((p0) {
      load();
    });
  }

  load() async {
    songs = [];
    songs.addAll(await playlistController.getSongs(playlist: playlist));
    setState(() {
      songs = songs;
      loading = false;
    });
  }

  Future<int?> delete() async {
    try {
      var index = await playlistController.deletePlaylist(playlist);
      return index;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int?> deleteSongs() async {
    try {
      return await playlistController.deleteSongs(
          songs: selectedSongs, playlist: playlist);
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (editing)
            Row(
              children: [
                TextButton(
                    onPressed: () async {
                      if (selectedSongs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: const Color(0xFFffd166),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Empty Selected Songs',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ));
                        return;
                      }
                      var status = await deleteSongs();
                      setState(() {
                        editing = false;
                      });
                      if (status != null) {
                        musicController.reload();
                      }
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red[400]),
                    )),
                const SizedBox(
                  width: 8,
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        selectedSongs = [];
                        editing = false;
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ))
              ],
            ),
          PopupMenuButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            itemBuilder: (BuildContext context) => <PopupMenuItem>[
              PopupMenuItem(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  onTap: () async {
                    setState(() {
                      editing = true;
                    });
                  },
                  child: Column(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.edit),
                        dense: true,
                        title: Text('Edit'),
                      ),
                      Divider()
                    ],
                  )),
              PopupMenuItem(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  onTap: () async {
                    Future.delayed(const Duration(milliseconds: 50), () async {
                      bool confirm = false;
                      await showDialog(
                          context: context,
                          builder: (builder) {
                            return CupertinoAlertDialog(
                              title: const Text(
                                  'Are you sure to delete the playlist?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      confirm = true;
                                    },
                                    child: Text('Yes',
                                        style:
                                            TextStyle(color: Colors.red[400]))),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No',
                                        style:
                                            TextStyle(color: Colors.red[400]))),
                              ],
                            );
                          });
                      if (confirm) {
                        int? isSuccess = await delete();
                        if (isSuccess != null) {
                          musicController.reload();
                          Navigator.pop(context);
                        }
                      }
                    });
                  },
                  child: const ListTile(
                    leading: Icon(Icons.delete),
                    dense: true,
                    title: Text('Delete'),
                  )),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.description,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              SizedBox(
                height: 80,
                width: size.width,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerRight,
                  children: [
                    Divider(
                      color: Theme.of(context).primaryColor,
                    ),
                    Positioned(
                      right: 8,
                      child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            showBottomSheetToAddSongs(context,
                                currentSongs: songs.map((e) => e.id).toList());
                          },
                          icon: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: const Color(0xFFffd166),
                              ),
                              child: const Icon(Icons.add))),
                    ),
                    Positioned(
                      right: 70,
                      child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            musicController.songs.value = songs;
                            if (musicController.isPlaying.value == -1) {
                              musicController.isPlaying.value = 1;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => MusicPlayer(
                                          playables: songs,
                                          currentTrack: songs.first,
                                          // shouldUpdateAudioSource: true,
                                        )));
                          },
                          icon: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  // color: Color.fromARGB(255, 167, 111, 246)),
                                  color: const Color(0xFFef476f)),
                              child: const Icon(
                                Icons.play_arrow,
                              ))),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive())
                      : songs.isEmpty
                          ? const Center(
                              child: Text('There is no song in the playlist.'),
                            )
                          : ListView.separated(
                              itemBuilder: (context, int index) {
                                return Row(
                                  children: [
                                    if (editing)
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.05,
                                            child: Checkbox(
                                                value: selectedSongs
                                                    .where((element) =>
                                                        element.id ==
                                                        songs[index].id)
                                                    .isNotEmpty,
                                                onChanged: (val) => {
                                                      if (val!)
                                                        {
                                                          setState(() {
                                                            selectedSongs.add(
                                                                songs[index]);
                                                          })
                                                        }
                                                      else
                                                        {
                                                          setState(() {
                                                            selectedSongs
                                                                .remove(songs[
                                                                    index]);
                                                          })
                                                        }
                                                    }),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                    SizedBox(
                                      width: size.width * 0.75,
                                      child: GestureDetector(
                                        onTap: () {
                                          List<Song> currentSongs = [];
                                          currentSongs.addAll(songs);
                                          currentSongs.insert(
                                              0, currentSongs.removeAt(index));
                                          musicController.songs.value =
                                              currentSongs;
                                          if (musicController.isPlaying.value ==
                                              -1) {
                                            musicController.isPlaying.value = 1;
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      MusicPlayer(
                                                        playables: songs,
                                                        currentTrack:
                                                            songs[index],
                                                        // shouldUpdateAudioSource: true,
                                                      )));
                                        },
                                        child: Preview(
                                            axis: Axis.horizontal,
                                            previewAble: songs[index],
                                            width: size.width,
                                            height: size.height * 0.1),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (_, __) {
                                return const SizedBox(height: 20);
                              },
                              itemCount: songs.length))
            ],
          ),
        ),
      ),
    );
  }

  showBottomSheetToAddSongs(BuildContext context,
      {required List<int> currentSongs}) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bcontext) {
          Size size = MediaQuery.of(context).size;
          Map<int, bool?> addedIndexes = {};
          Timer? timer;
          String? keyword;
          List<Song> loadedSongs = [];
          return StatefulBuilder(builder: (context, customSetState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: Theme.of(context).cardColor,
              height: size.height * 0.8,
              width: size.width,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontWeight: FontWeight.normal),
                      onChanged: (value) {
                        if (timer != null) {
                          timer!.cancel();
                        }
                        timer = Timer(const Duration(milliseconds: 300), () {
                          customSetState(() {
                            keyword = value;
                          });
                        });
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Search Songs',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.normal),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Song>>(
                        future: getSongs(keyword: keyword),
                        builder: (_, AsyncSnapshot<List<Song>> snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator.adaptive();
                          }
                          loadedSongs = snapshot.data!
                              .where((element) =>
                                  !currentSongs.contains(element.id))
                              .toList();
                          for (var song in loadedSongs) {
                            if (!addedIndexes.containsKey(song.id)) {
                              addedIndexes[song.id] = false;
                            }
                          }
                          return SizedBox(
                            height: size.height * 0.55,
                            child: ListView.separated(
                                itemBuilder: (_, int index) {
                                  var songId = loadedSongs[index].id;
                                  return ListTile(
                                    minLeadingWidth: 40,
                                    onTap: () {
                                      customSetState(() {
                                        addedIndexes[songId] =
                                            !addedIndexes[songId]!;
                                      });
                                    },
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: Checkbox(
                                        value: addedIndexes[songId],
                                        onChanged: (value) => {
                                              customSetState(() {
                                                addedIndexes[songId] = value;
                                              })
                                            }),
                                    title: Preview(
                                      axis: Axis.horizontal,
                                      width: size.width * 0.5,
                                      height: 40,
                                      previewAble: loadedSongs[index],
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) {
                                  return const SizedBox(height: 10);
                                },
                                itemCount: loadedSongs.length),
                          );
                        }),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(size.width, 56),
                          primary: const Color(0xFFffd166),
                        ),
                        onPressed: () async {
                          List<Song> selectedSongs = loadedSongs
                              .where((element) => addedIndexes[element.id]!)
                              .toList();
                          inspect(selectedSongs);
                          await showDialog(
                              context: context,
                              builder: (showContext) {
                                return FutureBuilder(
                                    future: playlistController.updateSongs(
                                        songs: selectedSongs
                                            .map((e) => e.id)
                                            .toList(),
                                        playlist: playlist),
                                    builder: (futureContext,
                                        AsyncSnapshot snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CupertinoAlertDialog(
                                          title: Text('Adding'),
                                          content: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator
                                                .adaptive(),
                                          ),
                                        );
                                      }
                                      WidgetsBinding.instance
                                          ?.addPostFrameCallback((timeStamp) {
                                        musicController.reload();
                                        Future.delayed(
                                            const Duration(milliseconds: 1500),
                                            () {
                                          Navigator.pop(showContext);
                                          Navigator.pop(context);
                                        });
                                      });

                                      return const CupertinoAlertDialog(
                                        title: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 28, horizontal: 12),
                                          child: Text('Successfully added.'),
                                        ),
                                      );
                                    });
                              });
                        },
                        child: const Text('Add All'))
                  ],
                ),
              ),
            );
          });
        });
  }

  Future<List<Song>> getSongs({String? keyword, Playlist? playlist1}) async {
    if (playlist1 != null) {
      return await playlistController.getSongs(playlist: playlist1);
    }
    return await songController.search(keyword: keyword);
  }
}
