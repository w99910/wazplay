import 'package:flutter/material.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/widgets/preview_song.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
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
                      return PreviewSong(
                          previewAble: Song.dummyData[index],
                          width: size.width * 0.45,
                          showSubtitle: false,
                          height: size.height * 0.3);
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
                height: size.height * 0.1 * Song.dummyData.length +
                    (20 * (Song.dummyData.length - 1)),
                child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext buildcontext, int index) {
                      return PreviewSong(
                          axis: Axis.horizontal,
                          previewAble: Song.dummyData.reversed.toList()[index],
                          width: size.width,
                          height: size.height * 0.1);
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                          height: 20,
                        ),
                    itemCount: Song.dummyData.length),
              ),
            ],
          ),
        ));
  }
}
