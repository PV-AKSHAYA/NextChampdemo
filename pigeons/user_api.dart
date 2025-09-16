// pigeons/api.dart

class UserDetails {
  String? name;
  String? gender;
  String? mobile;
  String? email;
}

@HostApi()
abstract class UserApi {
  UserDetails? registerUser(UserDetails details);
}
