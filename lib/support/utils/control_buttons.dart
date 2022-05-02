import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ControlButton {
  static const double defaultIconSize = 60;
  static StreamBuilder<SequenceState?> buildNextButton(
      {Function? onPressed,
      required AudioPlayer audioPlayer,
      double? iconSize}) {
    return StreamBuilder<SequenceState?>(
        stream: audioPlayer.sequenceStateStream,
        builder: (context, snapshot) {
          return IconButton(
              onPressed: () => onPressed != null
                  ? onPressed()
                  : audioPlayer.hasNext
                      ? audioPlayer.seekToNext()
                      : null,
              iconSize: iconSize ?? defaultIconSize,
              icon: Icon(
                Icons.skip_next,
                color: audioPlayer.hasNext ? null : Colors.grey,
              ));
        });
  }

  static StreamBuilder<SequenceState?> buildPreviousButton(
      {Function? onPressed,
      required AudioPlayer audioPlayer,
      double? iconSize}) {
    return StreamBuilder<SequenceState?>(
        stream: audioPlayer.sequenceStateStream,
        builder: (context, snapshot) {
          return IconButton(
              onPressed: () => onPressed != null
                  ? onPressed()
                  : audioPlayer.hasPrevious
                      ? audioPlayer.seekToPrevious()
                      : null,
              iconSize: iconSize ?? defaultIconSize,
              icon: Icon(
                Icons.skip_previous,
                color: audioPlayer.hasPrevious ? null : Colors.grey,
              ));
        });
  }

  static StreamBuilder<bool> buildShuffleButton(AudioPlayer audioPlayer,
      {double? iconSize}) {
    return StreamBuilder<bool>(
      stream: audioPlayer.shuffleModeEnabledStream,
      builder: (context, snapshot) {
        final shuffleModeEnabled = snapshot.data ?? false;
        return IconButton(
          icon: shuffleModeEnabled
              ? const Icon(Icons.shuffle, color: Colors.orange)
              : const Icon(Icons.shuffle, color: Colors.grey),
          onPressed: () async {
            final enable = !shuffleModeEnabled;
            if (enable) {
              await audioPlayer.shuffle();
            }
            await audioPlayer.setShuffleModeEnabled(enable);
          },
        );
      },
    );
  }

  static IconButton buildSequenceListButton(
      {required AudioPlayer audioPlayer,
      required BuildContext context,
      double? iconSize}) {
    return IconButton(
      onPressed: () {
        Scaffold.of(context).openEndDrawer();
      },
      icon: const Icon(Icons.list),
      iconSize: 30,
    );
  }

  static StreamBuilder<LoopMode> buildLoopButton(AudioPlayer audioPlayer,
      {double? iconSize}) {
    return StreamBuilder<LoopMode>(
      stream: audioPlayer.loopModeStream,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        const icons = [
          Icon(Icons.repeat, color: Colors.grey),
          Icon(Icons.repeat, color: Colors.orange),
          Icon(Icons.repeat_one, color: Colors.orange),
        ];
        const cycleModes = [
          LoopMode.off,
          LoopMode.all,
          LoopMode.one,
        ];
        final index = cycleModes.indexOf(loopMode);
        return IconButton(
          icon: icons[index],
          onPressed: () {
            audioPlayer.setLoopMode(cycleModes[
                (cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
          },
        );
      },
    );
  }

  static StreamBuilder<double> buildVolumeSlider(
      {required AudioPlayer audioPlayer, required BuildContext context}) {
    return StreamBuilder<double>(
        stream: audioPlayer.volumeStream,
        builder: (context, snapshot) => Container(
              height: 100.0,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.volume_down),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(trackHeight: 2.0),
                      child: Slider(
                        divisions: 20,
                        min: 0.0,
                        max: 1.0,
                        value: snapshot.data ?? audioPlayer.volume,
                        onChanged: audioPlayer.setVolume,
                      ),
                    ),
                  ),
                  const Icon(Icons.volume_up),
                ],
              ),
            ));
  }

  static StreamBuilder<PlayerState> buildPlayButton(AudioPlayer audioPlayer,
      {double? iconSize}) {
    return StreamBuilder<PlayerState>(
        stream: audioPlayer.playerStateStream,
        builder: ((context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final isPlaying = playerState?.playing;
          if (processingState == null ||
              processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            if (processingState == null && audioPlayer.audioSource != null) {
              audioPlayer.load();
            }
            return const SizedBox(
                height: 26.0, width: 26.0, child: CircularProgressIndicator());
          }
          if (isPlaying != true) {
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: iconSize ?? defaultIconSize,
              onPressed: audioPlayer.play,
            );
          }

          if (processingState != ProcessingState.completed) {
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: iconSize ?? defaultIconSize,
              onPressed: () {
                audioPlayer.pause();
              },
            );
          } else {
            return IconButton(
                iconSize: iconSize ?? defaultIconSize,
                onPressed: () => audioPlayer.seek(Duration.zero),
                icon: const Icon(Icons.replay));
          }
        }));
  }
}
