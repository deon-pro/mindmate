
import '/backend/backend.dart';

int likes(UserPostsRecord? post) {
  return post!.likes.length;
}

bool hasUploadedMedia(String? mediaPath) {
  return mediaPath != null && mediaPath.isNotEmpty;
}
