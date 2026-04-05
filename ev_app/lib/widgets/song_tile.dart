import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final Song song;

  const SongTile({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note, color: Colors.white),

      title: Text(
        song.title,
        style: const TextStyle(color: Colors.white),
      ),

      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.grey),
      ),

      trailing: const Icon(Icons.more_vert, color: Colors.white),
    );
  }
}