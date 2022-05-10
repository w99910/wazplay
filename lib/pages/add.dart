import 'dart:developer';
import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/support/eloquents/song.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/support/singletons/app.dart';
import 'package:wazplay/support/utils/dialog.dart';
import 'package:wazplay/support/utils/download.dart';
import 'package:wazplay/support/utils/toast.dart';
import 'package:wazplay/support/utils/video_download.dart';
import 'package:wazplay/widgets/custom_text_field.dart';
import 'package:wazplay/widgets/preview.dart';
import 'package:wazplay/support/extensions/string.dart';

const String howTo =
    "How To: \n 1: Open youtube app. \n 2: Play something that you want. \n 3: Click 'Share' button and a bottom action box will show up. \n 4: Click 'Copy link'. \n 5: Paste the url in the above text box and hit the 'search' button at the right side. Wait for a few seconds to load and then you can download and play it.";

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
  List<int> totalCurrentSongs = [];
  List<int> downloadedSongs = [];
  Map<int, VideoDownloadStream?> videoDownloadStreams = {};
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _musicController = Get.find<MusicController>();
    songEloquent = SongEloquent();
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  save(int index) async {
    WidgetsBinding.instance?.addPostFrameCallback((duration) async {
      if (App.instance.configuration.autoDownloadThumb) {
        var imageUrl = songs[index].thumbnail;
        if (imageUrl != null && songs[index].thumbnail!.isUrl()) {
          var splits = songs[index].thumbnail!.split('/');
          String? imagePath = await Download.image(songs[index].thumbnail!,
              fileName: splits[splits.length - 2]);
          if (imagePath != null) {
            songs[index].thumbnail = imagePath;
          }
        }
      }
      songs[index].path = videoDownloadStreams[index]!.path;
      await songs[index].save();
      await songs[index].reload();
      setState(() {
        songs[index] = songs[index];
      });
      _musicController.reload();
      setState(() {
        downloadedSongs.add(index);
        videoDownloadStreams[index] = null;
      });
    });
    // Future.delayed(const Duration(milliseconds: 200), () {

    // });
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
                  child: CustomTextField(
                    textEditingController: _textEditingController,
                    hintText: 'Enter youtube url',
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: InkWell(
                      onTap: () async {
                        int newIndex = totalCurrentSongs.isEmpty
                            ? 0
                            : totalCurrentSongs.last + 1;
                        try {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            totalCurrentSongs.add(newIndex);
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
                              totalCurrentSongs.remove(newIndex);
                            });
                            await CustomDialog.showSimpleDialog(context,
                                text: e.toString(),
                                textStyle:
                                    Theme.of(context).textTheme.bodyText1);
                          });
                        }
                        _textEditingController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: totalCurrentSongs.isEmpty
                  ? const HowToSection()
                  : ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        int currentIndex = totalCurrentSongs[index];
                        return totalCurrentSongs.length > songs.length &&
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
                                  videoDownloadStreams[currentIndex] != null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 14),
                                          child: StreamBuilder<double>(
                                              stream: videoDownloadStreams[
                                                      currentIndex]!
                                                  .stream,
                                              builder: (BuildContext
                                                      buildcontext,
                                                  AsyncSnapshot asyncSnapshot) {
                                                if (!asyncSnapshot.hasData) {
                                                  if (Platform.isAndroid) {
                                                    return Transform.scale(
                                                      scale: 0.5,
                                                      child:
                                                          const CircularProgressIndicator(),
                                                    );
                                                  }
                                                  return const CircularProgressIndicator
                                                      .adaptive();
                                                }
                                                if (asyncSnapshot.hasError) {
                                                  // inspect(asyncSnapshot.error);
                                                }
                                                if (asyncSnapshot
                                                        .connectionState ==
                                                    ConnectionState.done) {
                                                  save(index);
                                                }
                                                return Transform.scale(
                                                  scale: 0.5,
                                                  child:
                                                      CircularProgressIndicator(
                                                          value: asyncSnapshot
                                                              .data),
                                                );
                                              }),
                                        )
                                      : downloadedSongs.contains(index)
                                          ? IconButton(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                              icon:
                                                  const Icon(Icons.play_arrow),
                                              onPressed: () async {
                                                if (!File(songs[index]
                                                        .getAudioPath())
                                                    .existsSync()) {
                                                  await CustomDialog
                                                      .showSimpleDialog(context,
                                                          text:
                                                              'File not found',
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyText1!
                                                              .copyWith(
                                                                  color: Colors
                                                                          .red[
                                                                      400]));
                                                  return;
                                                }
                                                _musicController.songs.value = [
                                                  songs[index]
                                                ];
                                                _musicController.currentTrack
                                                    .value = songs[index];
                                                if (_musicController
                                                        .isPlaying.value ==
                                                    -1) {
                                                  _musicController
                                                      .isPlaying.value = 1;
                                                }
                                              })
                                          : IconButton(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                              onPressed: () async {
                                                VideoDownloadStream
                                                    videoDownloadStream =
                                                    await VideoDownload
                                                        .getVideoDownloadStream(
                                                            songs[index].path);
                                                if (File(videoDownloadStream
                                                        .path)
                                                    .existsSync()) {
                                                  File(videoDownloadStream.path)
                                                      .deleteSync();
                                                  Toast.showWarningToast(
                                                      context,
                                                      'Song is already downloaded');
                                                  return;
                                                }
                                                videoDownloadStream.download();
                                                setState(() {
                                                  videoDownloadStreams[
                                                          currentIndex] =
                                                      videoDownloadStream;
                                                });
                                              },
                                              icon: const Icon(Icons.download)),
                                  // IconButton(
                                  //     onPressed: () {
                                  //       setState(() {
                                  //         songs.removeAt(index);
                                  //         videoDownloadStreams
                                  //             .remove(currentIndex);
                                  //         totalCurrentSongs
                                  //             .remove(currentIndex);
                                  //         downloadedSongs.remove(index);
                                  //       });
                                  //     },
                                  //     icon: const Icon(
                                  //       Icons.close,
                                  //       color: Colors.red,
                                  //     ))
                                ]),
                              );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 12);
                      },
                      itemCount: totalCurrentSongs.length),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class HowToSection extends StatelessWidget {
  const HowToSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    howTo,
                    style: TextStyle(height: 1.8, letterSpacing: 1.1),
                  ),
                )
              ],
            ),
            SizedBox(
              width: size.width * 0.5,
              height: size.height * 0.25,
              child: SvgPicture.asset('assets/icons/search.svg',
                  // color: Colors.red,
                  semanticsLabel: 'Search'),
            ),
          ],
        ),
      ),
    );
  }
}
