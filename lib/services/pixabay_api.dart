import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/image_model.dart';

class PixabayApi {
  final http.Client client;
  final _apiKey = dotenv.env['PIXABAY_API_KEY'];
  final _baseUrl = dotenv.env['PIXABAY_API_URL'];

  PixabayApi({http.Client? client}) : client = client ?? http.Client();

  Future<List<ImageModel>> fetchImages(String query, int page) async {
    try {
      final response = await client.get(
        Uri.parse(
            '$_baseUrl?key=$_apiKey&q=$query&image_type=photo&per_page=20&page=$page'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['hits'] as List)
            .map((item) => ImageModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      throw Exception('Failed to load images: $e');
    }
  }
}
