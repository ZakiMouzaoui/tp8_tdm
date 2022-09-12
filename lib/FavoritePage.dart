import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'SongPage.dart';
import 'database_helper.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key, required this.audioPlayer}) : super(key: key);
  @override
  State<FavoritePage> createState() => _FavoritePageState();

  final AudioPlayer audioPlayer;
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favorites = [];
  final dbHelper = DatabaseHelper.instance;
  final GlobalKey<SongPageState> key = GlobalKey<SongPageState>();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getFavorites();
  }

  void getFavorites() async {
    favorites = await dbHelper.queryAllRows();
    setState(() {
      favorites = favorites;
    });
  }

  void changeTrack(bool next) {
    if (next) {
      if (currentIndex != favorites.length - 1) {
        currentIndex += 1;
      } else {
        currentIndex = 0;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex -= 1;
      } else {
        currentIndex = favorites.length - 1;
      }
    }
    //key.currentState?.playSong(favorites[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(" My Favorites"),
          backgroundColor: Colors.redAccent,
        ),
        body: favorites.isEmpty
            ? const Center(
                child: Text("No favorite songs"),
              )
            : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text("${favorites[index]["name"]}"),
                      subtitle: Text("${favorites[index]["artist"]}"),
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SongPage(
                                    songModel: SongModel(
                                      {
                                        "_display_name_wo_ext" : favorites[index]["name"],
                                        "artist" : favorites[index]["artist"],
                                        "_uri" : favorites[index]["uri"]
                                      }
                                    ),
                                    audioPlayer: widget.audioPlayer,
                                    changeTrack: changeTrack,
                                    key: key,
                                    index: index)));
                        await widget.audioPlayer.setAudioSource(
                            AudioSource.uri(Uri.parse(favorites[index]["uri"])),
                            preload: true);
                        widget.audioPlayer.play();
                      });
                },
              ));
  }
}
