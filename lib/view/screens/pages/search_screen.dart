import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/responsiveness/sizes.dart';
import 'package:instagram_clone/viewmodel/controller/search/search_controller.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchControllerprovider(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Consumer<SearchControllerprovider>(
              builder: (context, provider, child) {
                return TextField(
                  controller: provider.searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    border: InputBorder.none,
                  ),
                );
              },
            ),
          ),
          body: Consumer<SearchControllerprovider>(
            builder: (context, provider, child) {
              return provider.isSearching
                  ? _buildSearchResults(provider)
                  : _buildRandomImages(provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(SearchControllerprovider controller) {
    if (controller.searchResults.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return ListView.builder(
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        UserData user = controller.searchResults[index];
        return ListTile(
          leading: ClipRRect(
              borderRadius:
                  BorderRadius.circular(ResponsiveSizes.height(context, .1)),
              child: GestureDetector(
                onTap: () async {},
                child: CachedNetworkImage(
                  height: ResponsiveSizes.height(context, .10),
                  width: ResponsiveSizes.width(context, .14),
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                ),
              )),
          title: Text(user.name),
          onTap: () {
            // Navigate to user profile
          },
        );
      },
    );
  }

  Widget _buildRandomImages(SearchControllerprovider controller) {
    if (controller.isLoadingImages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.randomImages.isEmpty) {
      return const Center(child: Text('No images available.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!controller.isLoadingMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          controller.loadMoreImages();
        }
        return false;
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: controller.randomImages.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: controller.randomImages[index],
            errorWidget: (context, url, error) =>
                const Icon(CupertinoIcons.person),
          );
        },
      ),
    );
  }
}
