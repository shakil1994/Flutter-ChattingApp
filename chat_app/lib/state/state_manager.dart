import 'package:camera/camera.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatUser = StateProvider((ref) => UserModel());
final userLogged = StateProvider((ref) => UserModel());
final isCapture = StateProvider((ref) => false);
final thumbnailImage = StateProvider((ref) => XFile('default'));
