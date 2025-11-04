import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../network/dio_client.dart';

class PostRepository {
  final DioClient dioClient;
  final GetStorage box;

  PostRepository({DioClient? dioClient, GetStorage? storage})
      : dioClient = dioClient ?? DioClient(),
        box = storage ?? GetStorage();

  static const _postsKey = 'cached_posts';

  Future<List<Post>> fetchPosts({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && box.hasData(_postsKey)) {
        final cached = box.read<List>(_postsKey);
        if (cached != null && cached.isNotEmpty) {
          return cached.map((e) => Post.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }

      final Response res = await dioClient.get('/posts');
      final data = res.data as List;
      final posts = data.map((e) => Post.fromJson(Map<String, dynamic>.from(e))).toList();
      // cache raw json list
      box.write(_postsKey, data);
      return posts;
    } catch (e) {
      // fallback to cache if available
      if (box.hasData(_postsKey)) {
        final cached = box.read<List>(_postsKey)!;
        return cached.map((e) => Post.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      rethrow;
    }
  }

  Future<Post> fetchPostDetail(int id) async {
    final Response res = await dioClient.get('/posts/$id');
    return Post.fromJson(Map<String, dynamic>.from(res.data));
  }
}
