import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/playlist_controller.dart';
import 'package:wazplay/pages/playlist.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/widgets/info_box.dart';

class AddPlaylist extends StatelessWidget {
  final double? width;
  final double? height;
  final Alignment? alignment;
  final MusicController musicController;
  final PlaylistController playlistController;
  const AddPlaylist({
    Key? key,
    required this.musicController,
    required this.playlistController,
    this.width,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Align(
      alignment: alignment ?? Alignment.center,
      child: InfoBox(
        onPressed: () async {
          String? description;
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Create new playlist.'),
                content: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 8),
                    child: TextField(
                      onChanged: (value) => description = value,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Name your playlist',
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Create',
                      style: TextStyle(color: Colors.green[400]),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      description = null;
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ),
                ],
              );
            },
          );
          if (description != null) {
            Playlist? playlist = await playlistController.create(
              description: description!,
            );
            if (playlist != null) {
              musicController.reload();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistWidget(playlist: playlist),
                ),
              );
            }
          }
        },
        width: width ?? size.width * 0.9,
        height: height ?? size.height * 0.22,
        bgColor: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(8),
        textAlign: TextAlign.center,
        message: 'Create New Playlist +',
      ),
    );
  }
}
