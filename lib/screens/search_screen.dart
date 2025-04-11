import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixabay_gallery/utils/utils.dart';
import 'package:pixabay_gallery/widgets/loading.dart';
import '../providers/image_provider.dart';
import '../widgets/image_tile.dart';
import 'favorites_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText:AppStrings.searchImage,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    ref
                        .read(imageProvider.notifier)
                        .searchImages(_controller.text);
                    
                  },
                  child: const Text(AppStrings.search),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    ref.read(imageProvider.notifier).loadMoreImages();
                  }
                  return false;
                },
                child: imageState.isLoading && imageState.images.isEmpty
                    ? const Center(child: CustomCircularLoader())
                    : GridView.builder(
                        itemCount: imageState.images.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final image = imageState.images[index];
                          return ImageTile(
                            image: image,
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
