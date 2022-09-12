import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'FavoritePage.dart';
import 'SongPage.dart';
import 'database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const MyAudioList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyAudioList extends StatefulWidget {
  const MyAudioList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyAudioList(); //create state
  }
}

class _MyAudioList extends State<MyAudioList> {
  final _audioQuery = OnAudioQuery();
  final _audioPlayer = AudioPlayer();
  int currentIndex = 0;
  List<CustomSongModel> songs = [];
  List<Map<String, dynamic>> dbSongs = [];

  final GlobalKey<SongPageState> key = GlobalKey<SongPageState>();
  final dbHelper = DatabaseHelper.instance;

  static const musicChannel = MethodChannel("com.tp8/music");

  void getSongs() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final localSongs = await _audioQuery.querySongs();
    for (SongModel s in localSongs) {
      CustomSongModel c = CustomSongModel(s);
      songs.add(c);
      List<Map<String, dynamic>> favouriteSongs =
          await dbHelper.getSongs(c.songModel.uri!);
      if (favouriteSongs.isNotEmpty) {
        setState(() {
          c.isFavorite = true;
        });
      }
    }
    setState(() {
      songs = songs;
    });
  }

  @override
  void initState() {
    super.initState();
    getSongs();
  }

  @override
  void dispose() {
    dbHelper.close();
    super.dispose();
  }

  void changeTrack(bool next) {
    if (next) {
      if (currentIndex != songs.length - 1) {
        currentIndex += 1;
      } else {
        currentIndex = 0;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex -= 1;
      } else {
        currentIndex = songs.length - 1;
      }
    }
    key.currentState?.playSong(songs[currentIndex].songModel);
  }

  void addToFavorite(Map<String, dynamic> row, index) async {
    if (songs[index].isFavorite) {
      dbHelper.delete(songs[index].songModel.uri!);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Deleted from my favourites",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black12,
      ));
      setState(() {
        songs[index].isFavorite = false;
      });
    } else {
      dbHelper.insert(row);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Added to my favourites",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black12,
      ));
      setState(() {
        songs[index].isFavorite = true;
      });
    }
  }

  void startMusicService(uri) async{
    final message = await musicChannel.invokeMethod("startMusicService", {"uri": uri});
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  child: const Icon(Icons.more_vert),
                  onTap: () {
                    showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(30, 0, 0, 0),
                        items: [
                          const PopupMenuItem(
                            child: Text("Favorites"),
                            value: 1,
                          )
                        ]).then<void>((value) => {
                          if (value != null)
                            {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FavoritePage(
                                            audioPlayer: _audioPlayer,
                                          )))
                            }
                        });
                  },
                ),
              )
            ],
            title: const Text("Music Player"),
            backgroundColor: Colors.redAccent),
        body: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.music_note),
                trailing: IconButton(
                  onPressed: () {
                    addToFavorite({
                      "name": songs[index].songModel.displayNameWOExt,
                      "artist": songs[index].songModel.artist.toString(),
                      "uri": songs[index].songModel.uri,
                      "isFavorite": 1
                    }, index);
                  },
                  icon: songs[index].isFavorite
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        )
                      : const Icon(Icons.favorite),
                ),
                title: Text(songs[index].songModel.displayNameWOExt),
                subtitle: Text("${songs[index].songModel.artist}"),
                onTap: () {
                  startMusicService(songs[index].songModel.uri);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SongPage(
                              songModel: songs[index].songModel,
                              audioPlayer: _audioPlayer,
                              changeTrack: changeTrack,
                              key: key,
                              index: index)));
                },
              );
            }));
  }
}

class CustomSongModel {
  bool isFavorite = false;
  SongModel songModel;
  CustomSongModel(this.songModel);
}
