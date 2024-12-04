class User{
  final int? id;
  final String name;
  final String password;
  final String email;

  User({this.id, required this.name, required this.password, required this.email});

  Map<String, dynamic> toMap(){
      return{'id' : id, 'name' : name, 'password' : password, 'email' : email};
  }
}