import 'dart:async';
import 'dart:developer';
import 'dart:io' show File, Platform;
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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

class _TaskInfo {
  final int index;
  final String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  final StreamController<double> _controller = StreamController();

  Stream<double> get stream => _controller.stream;

  updateProgress(double progress) {
    progress = progress;
    print('updated progress - $progress');
    _controller.sink.add(progress);
  }

  cancelStream() async {
    await _controller.sink.close();
    await _controller.close();
  }

  error() async {
    _controller.sink.addError('Error in downloading');
  }

  _TaskInfo({required this.index, required this.taskId});
}

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
  List<_TaskInfo?> _taskInfos = [];
  late TextEditingController _textEditingController;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    _musicController = Get.find<MusicController>();
    songEloquent = SongEloquent();
    _textEditingController = TextEditingController();
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);
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
      //TODO: debug
      // songs[index].path = videoDownloadStreams[index]!.path;
      await songs[index].save();
      await songs[index].reload();
      setState(() {
        songs[index] = songs[index];
      });
      _musicController.reload();
      setState(() {
        downloadedSongs.add(index);
        // videoDownloadStreams[index] = null;
      });
    });
  }

  void _bindBackgroundIsolate() async {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];
      _TaskInfo? _taskInfo =
          _taskInfos.where((element) => element!.taskId == id).first;
      if (_taskInfo != null) {
        if (progress != null) {
          _taskInfo.updateProgress(progress / 100);
        }

        if (_taskInfo.status != status) {
          setState(() {
            _taskInfos.firstWhere((element) => element!.taskId == id)!.status =
                status;
          });
          print(_taskInfos
              .firstWhere((element) => element!.taskId == id)!
              .status);
        }

        if (status == DownloadTaskStatus.complete) {
          await _taskInfo.cancelStream();
          print('status complete');
          final tasks = await FlutterDownloader.loadTasksWithRawQuery(
              query: 'Select * from task');
          if (tasks != null) {
            for (var task in tasks) {
              print(task.filename);
              print(task.savedDir);
              File file = File(task.savedDir + '/' + task.filename!);
              print(file.path);
              print(file.existsSync());
              print('song - path - ' + songs[_taskInfo.index].path);
            }
          }
          await songs[_taskInfo.index].save();
          // _musicController.songs.value = [songs[_taskInfo.index]];
          // _musicController.currentTrack.value = songs[_taskInfo.index];
          // if (_musicController.isPlaying.value == -1) {
          //   _musicController.isPlaying.value = 1;
          // }
        }

        if (status == DownloadTaskStatus.failed) {
          _taskInfo.error();
          await _taskInfo.cancelStream();
        }
      }

      // if (_tasks != null && _tasks!.isNotEmpty) {
      //   final task = _tasks!.firstWhere((task) => task.taskId == id);
      //   setState(() {
      //     task.status = status;
      //     task.progress = progress;
      //   });
      // }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) async {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                buildSearchButton()
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: totalCurrentSongs.isEmpty
                  ? const HowToSection()
                  : ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        // int currentIndex = totalCurrentSongs[index];
                        _TaskInfo? _taskInfo;
                        Iterable<_TaskInfo?> tasks = _taskInfos
                            .where((element) => element?.index == index);
                        if (tasks.isNotEmpty) {
                          _taskInfo = tasks.first;
                        }
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
                                  _taskInfo != null
                                      ? _taskInfo.status ==
                                              DownloadTaskStatus.running
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 14),
                                              child:
                                                  buildDownloadingProgressIndicator(
                                                      _taskInfo),
                                            )
                                          : buildPlayButton(index)
                                      : buildDownloadButton(index),
                                  buildCloseButton(index),
                                ]),
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

  buildSearchButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).primaryColor,
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: InkWell(
          onTap: () async {
            int newIndex =
                totalCurrentSongs.isEmpty ? 0 : totalCurrentSongs.last + 1;
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
              Future.delayed(const Duration(milliseconds: 300), () async {
                setState(() {
                  totalCurrentSongs.remove(newIndex);
                });
                await CustomDialog.showSimpleDialog(context,
                    text: e.toString(),
                    textStyle: Theme.of(context).textTheme.bodyText1);
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
    );
  }

  buildDownloadButton(int index) {
    return IconButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        onPressed: () async {
          VideoDownloadStream videoDownloadStream =
              await VideoDownload.getVideoDownloadStream(songs[index].path);
          if (File(videoDownloadStream.path).existsSync()) {
            // File(videoDownloadStream.path)
            //     .deleteSync();
            Toast.showWarningToast(context, 'Song is already downloaded');
            return;
          }
          final taskId = await FlutterDownloader.enqueue(
            url: videoDownloadStream.baseUrl,
            fileName: videoDownloadStream.filename,
            savedDir: videoDownloadStream.dir,
            showNotification:
                true, // show download progress in status bar (for Android)
            openFileFromNotification:
                false, // click on notification to open downloaded file (for Android)
          );

          _TaskInfo _taskInfo = _TaskInfo(index: index, taskId: taskId);

          print('downloading -' + videoDownloadStream.path);

          setState(() {
            _taskInfos.add(_taskInfo);
            songs[index].path = videoDownloadStream.path;
          });
        },
        icon: const Icon(Icons.download));
  }

  buildDownloadingProgressIndicator(_TaskInfo _taskInfo) {
    return StreamBuilder<double>(
        stream: _taskInfo.stream,
        builder:
            (BuildContext buildcontext, AsyncSnapshot<double> asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            if (Platform.isAndroid) {
              return Transform.scale(
                scale: 0.5,
                child: const CircularProgressIndicator(),
              );
            }
            return const CircularProgressIndicator.adaptive();
          }
          if (asyncSnapshot.hasError) {
            // setState(() {
            //   videoDownloadStreams[
            //       currentIndex] = null;
            // });
            inspect(asyncSnapshot.error);
          }
          if (asyncSnapshot.connectionState == ConnectionState.done) {
            save(_taskInfo.index);
          }
          return Transform.scale(
            scale: 0.5,
            child: CircularProgressIndicator(value: asyncSnapshot.data),
          );
        });
  }

  buildPlayButton(int index) {
    return IconButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        icon: const Icon(Icons.play_arrow),
        onPressed: () async {
          if (!File(songs[index].getAudioPath()).existsSync()) {
            await CustomDialog.showSimpleDialog(context,
                text: 'File not found',
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.red[400]));
            return;
          }
          _musicController.songs.value = [songs[index]];
          _musicController.currentTrack.value = songs[index];
          if (_musicController.isPlaying.value == -1) {
            _musicController.isPlaying.value = 1;
          }
        });
  }

  buildCloseButton(int index) {
    return IconButton(
        onPressed: () {
          setState(() {
            songs.removeAt(index);
            _taskInfos.removeWhere((element) => element?.index == index);
            totalCurrentSongs.remove(index);
            downloadedSongs.remove(index);
          });
        },
        icon: const Icon(
          Icons.close,
          color: Colors.red,
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
