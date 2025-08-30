import 'dart:developer';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:mdia_player/core/utils/models/song_model.dart';
import 'package:path/path.dart' as path;

class MusicServices {
  static final MusicServices instance = MusicServices();
  // static MusicServices get instance => _instance;

  // MusicServices._internal();
  final AudioPlayer audioPlayer = AudioPlayer();
  List<SongModel> songs = [];
  int currentIndex = -1;
  SongModel get currentSong =>
      (songs.isNotEmpty && currentIndex >= 0) ? songs[currentIndex] : songs[0];
  Future<List<SongModel>> getSongs() async {
    songs.clear();
    try {
      final List<String> allDirectories = getAllStorageDirectories();
      for (final directory in allDirectories) {
        await scanDirectory(directory);
      }
      songs = removeDuplicates(songs);
      songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } catch (e) {
      log("Error getting storage directories: $e");
    }
    return songs;
  }

  List<String> getAllStorageDirectories() {
    List<String> directories = [];
    const List<String> firstDirectories = [
      '/storage/emulated/0/',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/media',
      '/storage/emulated/0/Media',
      '/storage/emulated/0/Audio',
      '/storage/emulated/0/Podcasts',
      '/storage/emulated/0/AudioBooks',
      '/storage/emulated/0/Ringtones',
      '/storage/emulated/0/Alarms',
      '/sdcard',
    ];
    const List<String> secondDirectories = [
      '/storage/emulated/1',
      '/storage/sdcard1',
      '/storage/sdcard2',
      '/storage/extSdCard',
      '/storage/external_SD',
      '/storage/external_SDCard',
      '/storage/usb_storage',
      '/storage/usb1',
      '/storage/usb2',
    ];
    directories.addAll(firstDirectories);
    directories.addAll(secondDirectories);
    try {
      final storageDirectory = Directory('/storage');
      final List<FileSystemEntity> entities = storageDirectory.listSync();
      for (final entity in entities) {
        if (entity is Directory && entity.path.contains('/storage/')) {
          directories.add(entity.path);
        }
      }
    } catch (e) {
      log("Error getting storage directories: $e");
    }
    List<String> existingDirectories = [];
    for (final directory in directories) {
      if (Directory(directory).existsSync()) {
        existingDirectories.add(directory);
      }
    }
    return existingDirectories;
  }

  Future<void> scanDirectory(String directoryPath) async {
    try {
      Directory directory = Directory(directoryPath);
      List<FileSystemEntity> entities = directory.listSync(
        recursive: true,
        followLinks: false,
      );
      for (FileSystemEntity element in entities) {
        if (element is File && isAudioFile(element.path)) {
          final SongModel song = await createSongFromFile(element);
          songs.add(song);
        }
      }
    } catch (e) {
      log("Error scanning directory $directoryPath : $e");
    }
  }

  List<SongModel> removeDuplicates(List<SongModel> songs) {
    final List<SongModel> uniqueSongs = [];
    for (final song in songs) {
      if (!uniqueSongs.contains(song)) {
        uniqueSongs.add(song);
      }
    }
    return uniqueSongs;
  }

  bool isAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    final List<String> audioExtensions = [
      '.mp3',
      '.wav',
      '.flac',
      '.aac',
      '.ogg',
      '.m4a',
      '.wma',
      '.opus',
    ];

    return audioExtensions.contains(extension);
  }

  Future<SongModel> createSongFromFile(File element) async {
    String filePath = element.path;
    String title = path.basenameWithoutExtension(filePath);
    String album = 'Unknown Album';
    String artist = 'Unknown Artist';
    Duration duration = Duration.zero;
    AudioPlayer tempAudio = AudioPlayer();
    await tempAudio.setFilePath(filePath);
    if (tempAudio.duration != null) {
      duration = tempAudio.duration!;
    }
    tempAudio.dispose();
    return SongModel(
      title: title,
      path: filePath,
      album: album,
      artist: artist,
      duration: duration,
      image: "",
    );
  }

  Future<void> playSong(int index) async {
    if (index >= 0 && index < songs.length) {
      currentIndex = index;
      await audioPlayer.setFilePath(songs[currentIndex].path);
      await audioPlayer.play();
    }
  }

  Future<void> pauseAndResumeSong() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> stopSong() async {
    await audioPlayer.stop();
  }

  Future<void> nextSong() async {
    if ((currentIndex < songs.length - 1) && (currentIndex >= 0)) {
      await playSong(currentIndex + 1);
    } else {
      await playSong(0);
    }
  }

  Future<void> previousSong() async {
    if ((currentIndex > 0) && (currentIndex < songs.length)) {
      await playSong(currentIndex - 1);
    } else {
      await playSong(songs.length - 1);
    }
  }

  Future<void> seekSong(Duration position) async {
    await audioPlayer.seek(position);
  }

  void shufflePlayList() async {
    if (songs.length > 1) {
      final SongModel currentSong = songs[currentIndex];
      songs.shuffle();
      int newIndex = songs.indexOf(currentSong);
      if (newIndex != currentIndex) {
        final SongModel tempSong = songs[currentIndex];
        songs[currentIndex] = songs[newIndex];
        songs[newIndex] = tempSong;
      }
    }
  }

  void dispose() {
    audioPlayer.dispose();
    songs.clear();
    currentIndex = -1;
  }
}
