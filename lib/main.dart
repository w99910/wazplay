import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wazplay/support/path.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter VideoDownload Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Insert the video id or url',
            ),
            TextField(controller: textController),
            ElevatedButton(
                child: const Text('Download'),
                onPressed: () async {
                  // Here you should validate the given input or else an error
                  // will be thrown.
                  var yt = YoutubeExplode();
                  var id = VideoId(textController.text.trim());
                  var video = await yt.videos.get(id);

                  inspect(video);

                  // Display info about this video.
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Title: ${video.title}, Duration: ${video.duration}'),
                      );
                    },
                  );

                  // Request permission to write in an external directory.
                  // (In this case downloads)
                  // await Permission.storage.request();

                  // // Get the streams manifest and the audio track.
                  // var manifest = await yt.videos.streamsClient.getManifest(id);
                  // var audio = manifest.audioOnly.last;

                  // // Build the directory.
                  // var path = await PathProvider.getPath();
                  // var filePath = '$path/${video.id}.${audio.container.name}';

                  // // Open the file to write.
                  // var file = File(filePath);
                  // var fileStream = file.openWrite();

                  // // Pipe all the content of the stream into our file.
                  // await yt.videos.streamsClient.get(audio).pipe(fileStream);
                  // /*
                  // If you want to show a % of download, you should listen
                  // to the stream instead of using `pipe` and compare
                  // the current downloaded streams to the totalBytes,
                  // see an example ii example/video_download.dart
                  //  */

                  // // Close the file.
                  // await fileStream.flush();
                  // await fileStream.close();

                  // // Show that the file was downloaded.
                  // await showDialog(
                  //   context: context,
                  //   builder: (context) {
                  //     return AlertDialog(
                  //       content: Text(
                  //           'Download completed and saved to: ${filePath}'),
                  //     );
                  //   },
                  // );
                }),
          ],
        ),
      ),
    );
  }
}