import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:pixabay_gallery/models/image_model.dart';
import 'package:pixabay_gallery/providers/image_provider.dart';
import 'package:pixabay_gallery/services/pixabay_api.dart';

class MockPixabayApi extends Mock implements PixabayApi {}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [imageProvider.overrideWith((ref) => ImageNotifier())],
    );
  });

  test('initial state is correct', () {
    final state = container.read(imageProvider);
    expect(state.images, isEmpty);
    expect(state.favorites, isEmpty);
    expect(state.isLoading, false);
  });

  test('toggleFavorite adds and removes image id', () {
    final notifier = container.read(imageProvider.notifier);
    final image =
        ImageModel(id: '1', imageUrl: '', user: 'test', imageSize: 100);

    notifier.toggleFavorite(image);
    expect(notifier.state.favorites.contains('1'), true);

    notifier.toggleFavorite(image);
    expect(notifier.state.favorites.contains('1'), false);
  });

  test('favoriteImages returns only favorite items', () {
    final notifier = container.read(imageProvider.notifier);
    final image1 =
        ImageModel(id: '1', imageUrl: '', user: 'test1', imageSize: 100);
    final image2 =
        ImageModel(id: '2', imageUrl: '', user: 'test2', imageSize: 200);
    notifier.state = notifier.state.copyWith(images: [image1, image2]);
    notifier.toggleFavorite(image2);

    final favorites = notifier.favoriteImages;
    expect(favorites.length, 1);
    expect(favorites[0].id, '2');
  });
}
