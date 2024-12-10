import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final String apiKey = "AIzaSyDk2qpDz-V0tRx57QOwmkNT87VuTCMNJkk";
  final YoutubeExplode yt = YoutubeExplode();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? currentVideoId;

  Future<void> searchAndPlayAudio(String query) async {
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=$query&key=AIzaSyDk2qpDz-V0tRx57QOwmkNT7Vu6TCGNJhk',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(response.body);
        if (jsonData['items'].isNotEmpty) {
          final videoId = jsonData['items'][0]['id']['videoId'];
          await playAudioFromYouTube(videoId);
        } else {
          print("No videos found.");
        }
      } else {
        print("Error ${response.statusCode}: ${response.body}");
        throw Exception('Failed to load video data');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }


  Future<void> playAudioFromYouTube(String videoId) async {
    try {
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioStream = manifest.audioOnly.first;

      await audioPlayer.setUrl(audioStream.url.toString());
      audioPlayer.play();
      setState(() => isPlaying = true);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    yt.close();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YouTube Music Player')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onSubmitted: searchAndPlayAudio,
              decoration: InputDecoration(
                labelText: 'Search for a song',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (currentVideoId != null)
              Text('Playing Video ID: $currentVideoId'),
            SizedBox(height: 20),
            if (isPlaying)
              ElevatedButton(
                onPressed: () => audioPlayer.pause(),
                child: Text('Pause'),
              )
            else
              ElevatedButton(
                onPressed: () => audioPlayer.play(),
                child: Text('Play'),
              ),
          ],
        ),
      ),
    );
  }
}