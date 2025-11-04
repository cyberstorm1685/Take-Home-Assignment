import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repository/post_repository.dart';
import '../../data/network/dio_client.dart';
import '../../viewmodel/post_viewmodel.dart';
import '../screens/post_detail_screen.dart';
import 'package:get_storage/get_storage.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});
  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late final PostViewModel controller;
  final TextEditingController searchC = TextEditingController();
  Timer? _debounce;
  List filtered = [];

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostViewModel(
        repository: PostRepository(dioClient: DioClient(), storage: GetStorage())));
    controller.fetchPosts();
  }

  void _onSearchChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final qLower = q.toLowerCase();
      setState(() {
        filtered = controller.posts
            .where((p) =>
        p.title.toLowerCase().contains(qLower) ||
            p.body.toLowerCase().contains(qLower))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 2,
        title: const Text('Posts Feed', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () {
              final box = GetStorage();
              final isDark = box.read('isDark') ?? false;
              box.write('isDark', !isDark);
              Get.changeThemeMode(!isDark ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchPosts(forceRefresh: true),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.isError.value) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text('Something went wrong!',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: controller.fetchPosts,
                        child: const Text('Retry'))
                  ],
                ),
              );
            }

            final listToShow =
            searchC.text.isEmpty ? controller.posts : filtered;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: listToShow.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final post = listToShow[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Get.to(() => PostDetailScreen(postId: post.id)),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  post.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: theme.hintColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
