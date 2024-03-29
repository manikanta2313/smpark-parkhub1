import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smartparkin1/HomePage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Barrier extends StatefulWidget {
  const Barrier({super.key});

  @override
  BarrierState createState() => BarrierState();
}

class BarrierState extends State<Barrier> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the video ID
    _controller = YoutubePlayerController(
      initialVideoId: 'FPzJOkyUTP4', // Use only the video ID here
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    // Ensure to dispose of the YoutubePlayerController to free up resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      // Return true to allow back navigation, return false to prevent it
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          icon: const Icon(Ionicons.chevron_back_outline, color: Colors.white),
        ),
        leadingWidth: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade900, Colors.blue.shade500],
            ),
          ),
        ),
        title: const Text(
          "Barrier",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 250),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              // Perform any actions when the player is ready
            },
          ),
          // Add elevated play/pause buttons below the video
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: Icon(
                _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 40, // Adjust the icon size as needed
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
