import 'package:flutter/material.dart';
import 'package:instagram_clone/viewmodel/controller/addpost/addpost_controller.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AddpostController(),
        builder: (context, child) {
          return Consumer<AddpostController>(
            builder: (context, provider, child) {
              return Scaffold(
                  appBar: AppBar(
                    leading: InkWell(
                        onTap: () {
                          provider.imagenull();
                        },
                        child: provider.image != null
                            ? const Icon(Icons.arrow_back_ios_sharp)
                            : const SizedBox.shrink()),
                    centerTitle: provider.image == null ? true : false,
                    title: provider.image == null
                        ? const Text("Select Image")
                        : const Text("Create Post"),
                    actions: [
                      provider.image == null
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () async {
                                if (provider.isposting == false) {
                                  FocusScope.of(context).unfocus();
                                  await provider.addpost(context);
                                }
                              },
                              child: Text(
                                "Post",
                                style: TextStyle(
                                    color: provider.isposting == false
                                        ? Colors.blue
                                        : Colors.grey,
                                    fontSize: 20),
                              ),
                            ),
                      const SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                  body: provider.image == null
                      ? Center(child: _buildaddButton(context))
                      : builduploadpost(context));
            },
          );
        });
  }

  Widget _buildaddButton(BuildContext context) {
    final provider = Provider.of<AddpostController>(context, listen: false);
    return InkWell(
      onTap: () {
        provider.pickImage();
      },
      child: const Center(
        child: Icon(
          Icons.upload,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  builduploadpost(BuildContext context) {
    final provider = Provider.of<AddpostController>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        children: [
          provider.isposting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: LinearProgressIndicator(
                    value: null,
                    color: Colors.blue,
                  ),
                )
              : const SizedBox.shrink(),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(provider.image!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: provider.captionController,
              onChanged: (value) {
                provider.captionvalue(value);
              },
              decoration: InputDecoration(
                hintText: "Write a caption...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: null, // Allow multiple lines
            ),
          ),
        ],
      ),
    );
  }
}
