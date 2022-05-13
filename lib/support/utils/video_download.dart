import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:wazplay/support/utils/path.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Initialize the YoutubeExplode instance.
final yt = YoutubeExplode();

class VideoDownload {
  static Future<VideoDownloadStream> getVideoDownloadStream(String id) async {
    if (!checkIfUrlIsYoutubeLink(id)) {
      throw Exception('Please check url is youtube link.');
    }

    if (await Permission.storage.status == PermissionStatus.denied) {
      var status = await Permission.storage.request();
      if (status == PermissionStatus.denied) {
        throw Exception('Storage permission is needed to download song.');
      }
    }
    // Get video metadata.
    var video = await yt.videos.get(id);

    // Get the video manifest.
    var manifest = await yt.videos.streamsClient.getManifest(id);
    // var audio = manifest.audioOnly.first;
    // var audioStream = yt.videos.streamsClient.get(audio);
    // var streams = manifest.audio;
    var streams = manifest.audio;
    var audio = streams.withHighestBitrate();
    var audioStream = yt.videos.streamsClient.get(audio);

    var dir = await PathProvider.getPath();
    // Compose the file name removing the unallowed characters in windows.
    var fileName = '${video.title}.${audio.container.name}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
    var filePath = dir + '/' + fileName;

    var file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    return VideoDownloadStream(
        path: filePath,
        audioStream: audioStream,
        totalSize: audio.size.totalBytes);
  }

  static Future<Map<String, String>> getDetail(String url) async {
    if (!checkIfUrlIsYoutubeLink(url)) {
      throw Exception('Please check url is youtube link.');
    }
    var video = await yt.videos.get(url);
    return {
      'title': video.title,
      'thumbnail': video.thumbnails.standardResUrl,
      'author': video.author,
      'path': url,
      'description': video.description,
    };
  }

  static bool checkIfUrlIsYoutubeLink(String url) {
    final reg = RegExp(r'^(https|http):\/\/youtu.be\/', caseSensitive: false);
    return reg.hasMatch(url);
  }
}

class VideoDownloadStream {
  String path;
  Stream<List<int>> audioStream;
  int totalSize;
  final StreamController<double> controller = StreamController<double>();

  Stream<double> get stream => controller.stream;

  VideoDownloadStream(
      {required this.path, required this.audioStream, required this.totalSize});

  Future download() async {
    var file = File(path);

    // // Delete the file if exists.
    if (file.existsSync()) {
      file.deleteSync();
    }
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);
    var size = totalSize;
    var count = 0;
    audioStream.listen((data) {
      count += data.length;
      // Calculate the current progress.
      output.add(data);
      var progress = ((count / size) * 100).ceil();
      controller.sink.add(progress / 100);
    }, onDone: () async {
      await controller.sink.close();
      await controller.close();

      output.close();
    }, onError: (obj, trace) async {
      controller.sink.addError(obj);
      await controller.sink.close();
      await controller.close();
    }, cancelOnError: true);
  }
}

class DownloadItem {}
