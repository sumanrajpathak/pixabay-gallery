import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pixabay_gallery/models/image_model.dart';
import 'dart:convert';

import 'package:pixabay_gallery/services/pixabay_api.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });
  test('fetchImages returns list of ImageModel on success', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
          json.encode({
            'hits': [
              {
                'id': 1,
                'webformatURL': 'https://example.com/image.jpg',
                'user': 'Suman raj',
                'imageSize': 112211,
              }
            ]
          }),
          200);
    });

    final api = PixabayApi(client: mockClient);
    final result = await api.fetchImages('nature', 1);
    expect(result, isA<List<ImageModel>>());
    expect(result.first.user, 'Suman raj');
  });

  test('fetchImages throws exception on failure', () async {
    final mockClient = MockClient((request) async {
      return http.Response('Internal Server Error', 500);
    });

    final api = PixabayApi(client: mockClient);

    expect(() async => await api.fetchImages('nature', 1), throwsException);
  });
}
