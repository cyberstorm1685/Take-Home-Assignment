import 'package:get/get.dart';
import '../data/models/post_model.dart';
import '../data/repository/post_repository.dart';

class PostViewModel extends GetxController {
  final PostRepository repository;
  PostViewModel({required this.repository});

  var isLoading = false.obs;
  var isError = false.obs;
  var posts = <Post>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchPosts();
    super.onInit();
  }

  Future<void> fetchPosts({bool forceRefresh = false}) async {
    try {
      isLoading(true);
      isError(false);
      errorMessage('');
      final fetched = await repository.fetchPosts(forceRefresh: forceRefresh);
      posts.value = fetched;
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<Post?> getPostDetail(int id) async {
    try {
      isLoading(true);
      isError(false);
      final p = await repository.fetchPostDetail(id);
      return p;
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
      return null;
    } finally {
      isLoading(false);
    }
  }
}
