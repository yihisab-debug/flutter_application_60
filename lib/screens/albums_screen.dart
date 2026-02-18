import 'package:flutter/material.dart';
import '../models/album.dart';
import '../services/api_service.dart';
import 'photos_screen.dart';

class AlbumsScreen extends StatelessWidget {
  final int userId;

  const AlbumsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Альбомы'),
      ),
      body: FutureBuilder<List<Album>>(
        future: ApiService.fetchAlbumsByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка: ${snapshot.error}'),
            );
          }

          final albums = snapshot.data!;
          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(

                  leading: const Icon(Icons.photo_album),

                  title: Text(album.title),

                  subtitle: Text('Album ID: ${album.id}'),

                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PhotosScreen(albumId: album.id),
                    ),
                  ),
                ),
                
              );
            },
          );
        },
      ),
    );
  }
}