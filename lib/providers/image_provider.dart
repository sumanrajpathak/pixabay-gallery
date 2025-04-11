
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_model.dart';
import '../services/pixabay_api.dart';

class ImageState {
  final List<ImageModel> images;
  final Set<String> favorites;
  final bool isLoading;

  ImageState({
    required this.images,
    required this.favorites,
    this.isLoading = false,
  });

  ImageState copyWith({
    List<ImageModel>? images,
    Set<String>? favorites,
    bool? isLoading,
  }) {
    return ImageState(
      images: images ?? this.images,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ImageNotifier extends StateNotifier<ImageState> {
  ImageNotifier() : super(ImageState(images: [], favorites: {}));

  String _currentQuery = '';
  int _currentPage = 1;
  bool _hasMore = true;

  Future<void> searchImages(String query) async {
    _currentQuery = query;
    _currentPage = 1;
    _hasMore = true;
    state = state.copyWith(isLoading: true);
    final results = await PixabayApi().fetchImages(query, _currentPage);
    state = state.copyWith(images: results, isLoading: false);
  }

  Future<void> loadMoreImages() async {
    if (!_hasMore || state.isLoading) return;
    _currentPage++;
    state = state.copyWith(isLoading: true);
    final results = await PixabayApi().fetchImages(_currentQuery, _currentPage);
    if (results.isEmpty) {
      _hasMore = false;
    }
    state = state.copyWith(images: [...state.images, ...results], isLoading: false);
  }

  void toggleFavorite(ImageModel image) {
    final favorites = Set<String>.from(state.favorites);
    if (favorites.contains(image.id)) {
      favorites.remove(image.id);
    } else {
      favorites.add(image.id);
    }
    state = state.copyWith(favorites: favorites);
  }

  List<ImageModel> get favoriteImages =>
      state.images.where((img) => state.favorites.contains(img.id)).toList();
}

final imageProvider = StateNotifierProvider<ImageNotifier, ImageState>((ref) => ImageNotifier());
