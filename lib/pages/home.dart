import 'package:flutter/material.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/widgets/info_box.dart';
import 'package:wazplay/widgets/preview_song.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                'Hi Zaw,',
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),
              Text('Recently Played',
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
                      return PreviewSong(
                          previewAble: Song.dummyData[index],
                          width: size.width * 0.45,
                          height: size.height * 0.3);
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                          width: 20,
                        ),
                    itemCount: Song.dummyData.length),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text('Recently Added',
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
                      return PreviewSong(
                          previewAble: Song.dummyData.reversed.toList()[index],
                          width: size.width * 0.45,
                          height: size.height * 0.3);
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                          width: 20,
                        ),
                    itemCount: Song.dummyData.length),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text('Playlists',
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
                      return InfoBox(
                        height: size.height * 0.15,
                        width: size.width * 0.45,
                        bgColor: Colors.black,
                        message: 'Create Playlist',
                        messageTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                          width: 20,
                        ),
                    itemCount: 4),
              )
            ],
          ),
        ));
  }
}
