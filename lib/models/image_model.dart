class ImageModel {
  final String id;
  final String imageUrl;
  final String user;
  final int imageSize;

  ImageModel({
    required this.id,
    required this.imageUrl,
    required this.user,
    required this.imageSize,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'].toString(),
      imageUrl: json['webformatURL'],
      user: json['user'],
      imageSize: json['imageSize'],
    );
  }
}