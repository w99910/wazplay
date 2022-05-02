import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<VideoDownloadStream> videoDownloadStreams = [];
  late TextEditingController _textEditingController;

  @override
  void initState() {
    // Song.onCreate(db, version);
    songEloquent = SongEloquent();
    _textEditingController = TextEditingController();
    // inspect(songEloquent.all());
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
                onSubmitted: (url) async {
                  try {
                    var song = Song.temp(await VideoDownload.getDetail(url));
                    setState(() {
                      songs.add(song);
                    });
                  } catch (e) {
                    Future.delayed(const Duration(milliseconds: 300), () async {
                      await showCupertinoDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            content: Text(
                              e.toString(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          );
                        },
                      );
                    });
                  }
                },
                decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: const Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                        borderRadius: BorderRadius.circular(12)),
                    hintText: 'Enter youtube url'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: songs.isEmpty
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
                        return Preview(
                          previewAble: songs[index],
                          width: size.width,
                          axis: Axis.horizontal,
                          height: size.height * 0.1,
                          actions: videoDownloadStreams
                                  .asMap()
                                  .containsKey(index)
                              ? StreamBuilder(
                                  stream: videoDownloadStreams[index]
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
                                              videoDownloadStreams[index].path;
                                        });
                                        songs[index].save();
                                        // Add Your Code here.
                                      });

                                      return IconButton(
                                          icon: const Icon(Icons.play_arrow),
                                          onPressed: () {});
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
                                    VideoDownloadStream videoDownloadStream =
                                        await VideoDownload
                                            .getVideoDownloadStream(
                                                songs[index].path);
                                    videoDownloadStream.download();
                                    setState(() {
                                      videoDownloadStreams
                                          .add(videoDownloadStream);
                                    });
                                  },
                                  icon: const Icon(Icons.download)),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 12);
                      },
                      itemCount: songs.length),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
