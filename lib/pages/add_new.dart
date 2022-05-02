import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/support/eloquents/song.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/support/utils/video_download.dart';
import 'package:wazplay/widgets/preview.dart';

class AddNewSong extends StatefulWidget {
  const AddNewSong({Key? key}) : super(key: key);

  @override
  State<AddNewSong> createState() => _AddNewSongState();
}

class _AddNewSongState extends State<AddNewSong>
    with AutomaticKeepAliveClientMixin {
  List<Song> songs = [];
  late SongEloquent songEloquent;
  late MusicController _musicController;
  int loadingSongIndex = 0;
  int totalCurrentSongs = 0;
  Map<int, VideoDownloadStream> videoDownloadStreams = {};
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _musicController = Get.find<MusicController>();
    songEloquent = SongEloquent();
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        // constraints: const BoxConstraints.expand(),
        height: size.height,
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Song',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: size.width * 0.75,
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
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Enter youtube url'),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.black,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: InkWell(
                      onTap: () async {
                        try {
                          FocusScope.of(context).unfocus();
                          int currentTotal = songs.length;
                          setState(() {
                            totalCurrentSongs = currentTotal + 1;
                          });
                          var song = Song.temp(await VideoDownload.getDetail(
                              _textEditingController.text.trim()));
                          setState(() {
                            songs.add(song);
                          });
                        } catch (e) {
                          Future.delayed(const Duration(milliseconds: 300),
                              () async {
                            setState(() {
                              totalCurrentSongs -= 1;
                            });
                            await showCupertinoDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  content: Text(
                                    e.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                );
                              },
                            );
                          });
                        }
                        _textEditingController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: totalCurrentSongs == 0
                  ? Center(
                      child: SizedBox(
                        width: size.width * 0.5,
                        height: size.height * 0.5,
                        child: SvgPicture.asset('assets/icons/search.svg',
                            // color: Colors.red,
                            semanticsLabel: 'Search'),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return totalCurrentSongs > songs.length &&
                                index > songs.length - 1
                            ? Preview(
                                previewAble: null,
                                width: size.width,
                                axis: Axis.horizontal,
                                height: size.height * 0.1,
                              )
                            : Preview(
                                previewAble: songs[index],
                                width: size.width,
                                axis: Axis.horizontal,
                                height: size.height * 0.1,
                                actions: Row(children: [
                                  videoDownloadStreams[index] != null
                                      ? StreamBuilder(
                                          stream: videoDownloadStreams[index]!
                                              .controller
                                              .stream,
                                          builder: (BuildContext buildcontext,
                                              AsyncSnapshot asyncSnapshot) {
                                            if (!asyncSnapshot.hasData) {
                                              return const CircularProgressIndicator
                                                  .adaptive();
                                            }
                                            if (asyncSnapshot.connectionState ==
                                                ConnectionState.done) {
                                              WidgetsBinding.instance
                                                  ?.addPostFrameCallback((_) {
                                                setState(() {
                                                  songs[index].path =
                                                      videoDownloadStreams[
                                                              index]!
                                                          .path;
                                                });
                                                songs[index].save();
                                              });

                                              return IconButton(
                                                  icon: const Icon(
                                                      Icons.play_arrow),
                                                  onPressed: () {
                                                    _musicController.songs
                                                        .value = [songs[index]];
                                                    _musicController
                                                        .currentTrack
                                                        .value = songs[index];
                                                    if (_musicController
                                                            .isPlaying.value ==
                                                        -1) {
                                                      _musicController
                                                          .isPlaying.value = 1;
                                                    }
                                                  });
                                            }
                                            return Transform.scale(
                                              scale: 0.5,
                                              child: CircularProgressIndicator(
                                                  valueColor:
                                                      const AlwaysStoppedAnimation<
                                                          Color>(Colors.black),
                                                  value: asyncSnapshot.data),
                                            );
                                          })
                                      : IconButton(
                                          onPressed: () async {
                                            VideoDownloadStream
                                                videoDownloadStream =
                                                await VideoDownload
                                                    .getVideoDownloadStream(
                                                        songs[index].path);
                                            videoDownloadStream.download();
                                            setState(() {
                                              videoDownloadStreams[index] =
                                                  videoDownloadStream;
                                            });
                                          },
                                          icon: const Icon(Icons.download)),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          songs.removeAt(index);
                                          totalCurrentSongs -= 1;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ))
                                ]),
                              );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 12);
                      },
                      itemCount: totalCurrentSongs),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
