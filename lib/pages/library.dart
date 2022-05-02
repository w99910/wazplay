import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/widgets/preview.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  late TextEditingController _textEditingController;
  late SongController songController;
  late MusicController musicController;
  List<Song> songs = [];

  @override
  void initState() {
    _textEditingController = TextEditingController();
    songController = Get.find<SongController>();
    musicController = Get.find<MusicController>();
    super.initState();
    init();
  }

  init() async {
    songs.addAll(await songController.all());
    // recentlyAdded.addAll(songs);
    // recentlyPlayed.addAll(songs);
    setState(() {
      songs = songs;
      // recentlyAdded.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      // recentlyPlayed.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
      // loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Library',
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(41, 184, 184, 184),
                          blurRadius: 4.0,
                          offset: Offset(0, 6),
                          spreadRadius: 0.4)
                    ]),
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                      isDense: true,
                      suffixIcon: const Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!),
                          borderRadius: BorderRadius.circular(12)),
                      hintText: 'Search Artist or Track'),
                ),
              ),
              const SizedBox(height: 12),
              Text('Artists',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width,
                height: size.height * 0.22,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext buildcontext, int index) {
                      return GestureDetector(
                        onTap: () {
                          List<Song> currentSongs = [];
                          currentSongs.addAll(songs);
                          currentSongs.insert(0, currentSongs.removeAt(index));
                          musicController.songs.value = currentSongs;
                          if (musicController.isPlaying.value == -1) {
                            musicController.isPlaying.value = 1;
                          }
                        },
                        child: Preview(
                            previewAble: Song.dummyData[index],
                            width: size.width * 0.45,
                            showSubtitle: false,
                            height: size.height * 0.3),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                          width: 20,
                        ),
                    itemCount: Song.dummyData.length),
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text('Songs',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width,
                height: songs.isNotEmpty
                    ? size.height * 0.1 * songs.length +
                        (20 * (songs.length - 1))
                    : 40,
                child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext buildcontext, int index) {
                      return GestureDetector(
                        onTap: () {
                          List<Song> currentSongs = [];
                          currentSongs.addAll(songs);
                          currentSongs.insert(0, currentSongs.removeAt(index));
                          musicController.songs.value = currentSongs;
                          if (musicController.isPlaying.value == -1) {
                            musicController.isPlaying.value = 1;
                          }
                        },
                        child: Preview(
                            axis: Axis.horizontal,
                            previewAble: songs[index],
                            width: size.width,
                            height: size.height * 0.1),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                          height: 20,
                        ),
                    itemCount: songs.length),
              ),
            ],
          ),
        ));
  }
}
