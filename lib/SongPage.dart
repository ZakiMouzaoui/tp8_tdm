import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongPage extends StatefulWidget {
  SongPage(
      {required this.songModel,
      required this.audioPlayer,
      required this.changeTrack,
      required this.key, required this.index})
      : super(key: key);
  SongModel songModel;
  final AudioPlayer audioPlayer;
  final Function changeTrack;
  final GlobalKey<SongPageState> key;
  final int index;

  @override
  State<SongPage> createState() => SongPageState();
}

class SongPageState extends State<SongPage> {
  bool playing = false;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  playSong(SongModel songModel) async {
    widget.songModel = songModel;
    await widget.audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(songModel.uri!)),
        preload: true);
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  void changeStatus() {
    setState(() {
      playing = !playing;

      if (playing) {
        widget.audioPlayer.play();
      } else {
        widget.audioPlayer.pause();
      }
    });
  }



  @override
  void initState() {
    playSong(widget.songModel);
    changeStatus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const CircleAvatar(
                backgroundColor: Colors.redAccent,
                radius: 100,
                child: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child:
                        Icon(Icons.music_note, size: 50, color: Colors.black)),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.songModel.displayNameWOExt,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.songModel.artist.toString() == "<unknown>"
                    ? "Unknown Artist"
                    : widget.songModel.artist.toString(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(_position.toString().split(".")[0]),
                  Expanded(
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          Duration duration = Duration(seconds: value.toInt());
                          widget.audioPlayer.seek(duration);
                          value = value;
                        });
                      },
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.white,
                    ),
                  ),
                  Text(_duration.toString().split(".")[0])
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        widget.changeTrack(false);
                      });
                    },
                    icon: const Icon(Icons.skip_previous,
                        size: 40, color: Colors.redAccent),
                  ),
                  IconButton(
                    onPressed: () {
                      changeStatus();
                    },
                    icon: !playing
                        ? const Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.pause,
                            size: 40,
                            color: Colors.red,
                          ),
                  ),
                  IconButton(
                      onPressed: () {
                        widget.changeTrack(true);
                      },
                      icon: const Icon(Icons.skip_next,
                          size: 40, color: Colors.redAccent))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
