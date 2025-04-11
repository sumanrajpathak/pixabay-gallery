import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixabay_gallery/models/image_model.dart';
import 'package:pixabay_gallery/utils/utils.dart';
import '../providers/image_provider.dart';
import '../widgets/image_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imageProvider.select(
      (state) => state.images
          .where((img) => state.favorites.contains(img.id))
          .toList(),
    ));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.favorites)),
      body: images.isEmpty
          ? const Center(child: Text(AppStrings.noFavorites))
          : GridView.builder(
              itemCount: images.length,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return _FadeOutImageTile(
                  key: ValueKey(images[index].id),
                  image: images[index],
                  onRemove: () {
                    ref
                        .read(imageProvider.notifier)
                        .toggleFavorite(images[index]);
                  },
                );
              },
            ),
    );
  }
}

class _FadeOutImageTile extends StatefulWidget {
  final ImageModel image;
  final VoidCallback onRemove;

  const _FadeOutImageTile({
    super.key,
    required this.image,
    required this.onRemove,
  });

  @override
  State<_FadeOutImageTile> createState() => _FadeOutImageTileState();
}

class _FadeOutImageTileState extends State<_FadeOutImageTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.8).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.removeFavorite),
        content: const Text(AppStrings.doYouWantYoRemoveThis),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(AppStrings.remove)),
        ],
      ),
    );

    if (result == true) {
      await _controller.forward();
      widget.onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ImageTile(
          image: widget.image,
          onRemove: _handleTap,
        ),
      ),
    );
  }
}
