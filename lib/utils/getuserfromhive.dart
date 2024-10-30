import 'package:hive/hive.dart';
import 'package:iris_app/models/user_model.dart';

Future<UserModel?> loadUserData() async {
  var userBox = Hive.box('userBox');
  UserModel? user = await userBox.get('user');
  print(user);
  if (user != null) {
    print("Username ${user.name}");
    return user;
  }
  return null;
}
