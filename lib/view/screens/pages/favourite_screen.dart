import 'package:flutter/material.dart';
import 'package:instagram_clone/view/widget/post_widget/postcard.dart';
import 'package:instagram_clone/viewmodel/controller/pages/home_controller.dart';
import 'package:instagram_clone/viewmodel/services/firebase_services.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final FirebaseServices firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Favourite"),
          ),
          body: Consumer<HomeController>(
            builder: (context, homeController, child) {
              if (homeController.loadingFavorites == true) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                ));
              }
              // If there are no favorite posts, show a message
              if (homeController.favoritePosts.isEmpty) {
                return RefreshIndicator(
                    backgroundColor: Colors.black,
                    color: Colors.white,
                    onRefresh: () async {
                      homeController.loadFavoritePosts();
                    },
                    child: const Center(child: Text('No favorite posts.')));
              }

              // Display the list of favorite posts
              return RefreshIndicator(
                backgroundColor: Colors.black,
                color: Colors.white,
                onRefresh: () async {
                  homeController.loadFavoritePosts();
                },
                child: ListView.builder(
                  itemCount: homeController.favoritePosts.length,
                  itemBuilder: (context, index) {
                    var post = homeController.favoritePosts[index]['post'];
                    var user = homeController.favoritePosts[index]['user'];

                    return Postcard(post: post, user: user);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
