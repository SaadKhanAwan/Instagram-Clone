import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/view/widget/textfield.dart';
import 'package:instagram_clone/viewmodel/controller/profile/edit_profilecontroller.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final String currentImage;
  final String currentName;
  final String currentBio;

  const EditProfile({
    super.key,
    required this.currentImage,
    required this.currentName,
    required this.currentBio,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // String? _image;
  // final _globalkey = GlobalKey<FormState>();
  // bool isloading = false;

  // late String username;
  // late String bio;
  // late String profileImageUrl;

  // @override
  // void initState() {
  //   super.initState();
  //   username = widget.currentName;
  //   bio = widget.currentBio;
  //   profileImageUrl = widget.currentImage;
  //   _image = null;
  // }

  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (_) => EditProfilecontroller(
          currentBio: widget.currentBio,
          currentImage: widget.currentImage,
          currentName: widget.currentName),
      builder: (context, index) {
        return Consumer<EditProfilecontroller>(
            builder: (context, provider, child) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text("Edit Profile"),
                actions: [
                  GestureDetector(
                    onTap: () {
                      if (provider.globalkey.currentState!.validate()) {
                        provider.globalkey.currentState!.save();
                        Navigator.pop(context, {
                          'image': widget.currentImage,
                          'name': provider.username,
                          'bio': provider.bio,
                        });
                      }
                    },
                    child: const Icon(Icons.check),
                  ),
                  SizedBox(width: mwidth * .03),
                ],
              ),
              body: Form(
                key: provider.globalkey,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: mheight * .01,
                    left: mwidth * .05,
                    right: mwidth * .05,
                  ),
                  child: ListView(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              provider.image != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(mheight * .4),
                                      child: Image.file(
                                        File(provider.image!),
                                        height: mheight * 0.23,
                                        width: mwidth * 0.45,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(mheight * .4),
                                      child: CachedNetworkImage(
                                        height: mheight * .23,
                                        width: mwidth * .45,
                                        fit: BoxFit.cover,
                                        imageUrl: provider.profileImageUrl,
                                        errorWidget: (context, url, error) =>
                                            const Icon(CupertinoIcons.person),
                                      ),
                                    ),
                              Positioned(
                                bottom: mheight * .01,
                                right: mwidth * .02,
                                child: GestureDetector(
                                  onTap: () {
                                    _showbuttonsheet(provider: provider);
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: mheight * .07),
                          MyTextField(
                            prefixicon: Icons.person,
                            hintText: "Enter user name",
                            initaialValue: provider.username,
                            onsave: (val) => provider.username = val ?? "",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your user name';
                              }
                              if (value.trim().length < 3) {
                                return 'User name must have at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mheight * .07),
                          MyTextField(
                            prefixicon: Icons.notes,
                            hintText: "Enter bio",
                            initaialValue: provider.bio,
                            onsave: (val) => provider.bio = val ?? "",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your bio';
                              }
                              if (value.length > 100) {
                                return 'Bio must be less than 100 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mheight * .07),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(mwidth * .7, mheight * .07),
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () async {
                              await provider.updateProfile(context: context);
                            },
                            label: provider.state == ViewState.loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                                  ),
                            icon: provider.state == ViewState.loading
                                ? null
                                : const Icon(
                                    Icons.edit,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showbuttonsheet({required EditProfilecontroller provider}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 20, bottom: 50),
          children: [
            const Text(
              "Pick Profile Picture",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // for picking image from camera
                ElevatedButton(
                  onPressed: () async {
                    await provider.pickImage(
                        context: context, source: ImageSource.camera);
                  },
                  style:
                      ElevatedButton.styleFrom(fixedSize: const Size(150, 150)),
                  child: Image.asset("assets/images/camera.png"),
                ),
                // for picking image from gallery
                ElevatedButton(
                  onPressed: () async {
                    await provider.pickImage(
                        context: context, source: ImageSource.gallery);
                  },
                  style:
                      ElevatedButton.styleFrom(fixedSize: const Size(150, 150)),
                  child: Image.asset("assets/images/gallery.png"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
