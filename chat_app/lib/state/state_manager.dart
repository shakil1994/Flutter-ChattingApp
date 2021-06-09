import 'package:chat_app/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatUser = StateProvider((ref) => UserModel());