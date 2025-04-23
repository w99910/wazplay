import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class ControlButton {
  static const double defaultIconSize = 60;
  static StreamBuilder<SequenceState?> buildNextButton({
    Function? onPressed,
    required AudioPlayer audioPlayer,
    bool? disable,
    double? iconSize,
  }) {
    return StreamBuilder<SequenceState?>(
      stream: audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        return IconButton(
          onPressed:
              onPressed != null && disable != null
                  ? onPressed()
                  : disable != null && disable
                  ? null
                  : audioPlayer.hasNext
                  ? audioPlayer.seekToNext
                  : null,
          iconSize: iconSize ?? defaultIconSize,
          icon: Icon(
            Icons.skip_next,
            color:
                (disable != null && disable) || !audioPlayer.hasNext
                    ? Colors.grey
                    : null,
          ),
        );
      },
    );
  }

  static StreamBuilder<SequenceState?> buildPreviousButton({
    Function? onPressed,
    bool? disable,
    required AudioPlayer audioPlayer,
    double? iconSize,
  }) {
    return StreamBuilder<SequenceState?>(
      stream: audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        return IconButton(
          onPressed:
              onPressed != null && disable != null
                  ? onPressed()
                  : disable != null && disable
                  ? null
                  : audioPlayer.hasNext
                  ? audioPlayer.seekToPrevious
                  : null,
          iconSize: iconSize ?? defaultIconSize,
          icon: Icon(
            Icons.skip_previous,
            color: audioPlayer.hasPrevious ? null : Colors.grey,
          ),
        );
      },
    );
  }

  static StreamBuilder<bool> buildShuffleButton(
    AudioPlayer audioPlayer, {
    double? iconSize,
    Color? enableColor,
    Color? disableColor,
    Function(bool)? onClick,
  }) {
    return StreamBuilder<bool>(
      stream: audioPlayer.shuffleModeEnabledStream,
      builder: (context, snapshot) {
        final shuffleModeEnabled = snapshot.data ?? false;
        if (onClick != null) {
          onClick(shuffleModeEnabled);
        }
        return IconButton(
          icon:
              shuffleModeEnabled
                  ? Icon(Icons.shuffle, color: enableColor ?? Colors.blue)
                  : Icon(Icons.shuffle, color: disableColor ?? Colors.grey),
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

  static IconButton buildSequenceListButton({
    required AudioPlayer audioPlayer,
    required BuildContext context,
    double? iconSize,
  }) {
    return IconButton(
      onPressed: () {
        Scaffold.of(context).openEndDrawer();
      },
      icon: const Icon(Icons.list),
      iconSize: 30,
    );
  }

  static StreamBuilder<LoopMode> buildLoopButton(
    AudioPlayer audioPlayer, {
    double? iconSize,
    Color? enableColor,
    Color? disableColor,
    Function(LoopMode)? onClick,
  }) {
    return StreamBuilder<LoopMode>(
      stream: audioPlayer.loopModeStream,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        var icons = [
          Icon(Icons.repeat, color: disableColor ?? Colors.grey),
          Icon(Icons.repeat, color: enableColor ?? Colors.blue),
          Icon(Icons.repeat_one, color: enableColor ?? Colors.blue),
        ];
        const cycleModes = [LoopMode.off, LoopMode.all, LoopMode.one];
        final index = cycleModes.indexOf(loopMode);
        if (onClick != null) {
          onClick(loopMode);
        }
        return IconButton(
          icon: icons[index],
          onPressed: () {
            audioPlayer.setLoopMode(
              cycleModes[(cycleModes.indexOf(loopMode) + 1) %
                  cycleModes.length],
            );
          },
        );
      },
    );
  }

  static StreamBuilder<double> buildVolumeSlider({
    required AudioPlayer audioPlayer,
    required BuildContext context,
  }) {
    return StreamBuilder<double>(
      stream: audioPlayer.volumeStream,
      builder:
          (context, snapshot) => Container(
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
          ),
    );
  }

  static StreamBuilder<PlayerState> buildPlayButton(
    AudioPlayer audioPlayer, {
    double? iconSize,
    bool? disable,
  }) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: ((context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final isPlaying = playerState?.playing;
        if (processingState == null ||
            processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return SizedBox(
            height: 26.0,
            width: 26.0,
            child: Transform.scale(
              scale: 0.5,
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (isPlaying != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: iconSize ?? defaultIconSize,
            onPressed: disable != null && disable ? null : audioPlayer.play,
          );
        }

        if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause),
            iconSize: iconSize ?? defaultIconSize,
            onPressed: disable != null && disable ? null : audioPlayer.pause,
          );
        } else {
          return IconButton(
            iconSize: iconSize ?? defaultIconSize,
            onPressed: () => audioPlayer.seek(Duration.zero),
            icon: const Icon(Icons.replay),
          );
        }
      }),
    );
  }

  static buildSeekBar(AudioPlayer _audioPlayer) {
    return StreamBuilder<PositionData>(
      stream: Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      ),
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return SeekBar(
          duration: positionData?.duration ?? Duration.zero,
          position: positionData?.position ?? Duration.zero,
          bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
          onChangeEnd: (newPosition) {
            _audioPlayer.seek(newPosition);
          },
        );
      },
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
    Key? key,
  }) : super(key: key);

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(trackHeight: 2.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.8),
            inactiveTrackColor: const Color.fromARGB(255, 110, 149, 255),
            valueIndicatorTextStyle: Theme.of(context).textTheme.bodySmall,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              // activeColor: Colors.white,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(
                widget.bufferedPosition.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble(),
              ),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd!(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.transparent,
            thumbColor: Theme.of(context).primaryColor,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(
              _dragValue ?? widget.position.inMilliseconds.toDouble(),
              widget.duration.inMilliseconds.toDouble(),
            ),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
            RegExp(
                  r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$',
                ).firstMatch("$_remaining")?.group(1) ??
                '$_remaining',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
