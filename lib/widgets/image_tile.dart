import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:pixabay_gallery/utils/utils.dart';
import '../models/image_model.dart';
import '../providers/image_provider.dart';

class ImageTile extends ConsumerStatefulWidget {
  final ImageModel image;
  final VoidCallback? onRemove;

  const ImageTile({
    super.key,
    required this.image,
    this.onRemove,
  });

  @override
  ConsumerState<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends ConsumerState<ImageTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _readableSize(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) return "${(bytes / mb).toStringAsFixed(1)} MB";
    return "${(bytes / kb).toStringAsFixed(1)} KB";
  }

  @override
  Widget build(BuildContext context) {
    final isFav = ref.watch(imageProvider).favorites.contains(widget.image.id);
    if (!isFav) {
      _controller.value = 0;
    }
    return GestureDetector(
      onTap: widget.onRemove ??
          () {
            if (isFav) {
              return;
            }
            ref.read(imageProvider.notifier).toggleFavorite(widget.image);
            if (!isFav) {
              _controller.forward(from: 0);
            }
          },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(widget.image.imageUrl,
                      fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.image.user,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(_readableSize(widget.image.imageSize),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Lottie.asset(
                    AppAssets.favoriteAnimation,
                    controller: _controller,
                    width: 60,
                    height: 60,
                    repeat: false,
                    onLoaded: (composition) {
                      _controller.duration = composition.duration;
                      _controller.value = isFav ? 1 : 0;
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
