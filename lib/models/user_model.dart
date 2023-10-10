class UserModel {
  String? fullName;
  String? email;
  String? password;
  String? imageRef;
  String? payment;
  UserModel(
      {
        this.fullName,
        this.email,
        this.password,
        this.imageRef,
        this.payment
      });

  // receiving data from server
  factory UserModel.fromMapRegsitration(map) {
    return UserModel(
        email: map['email'],
        fullName: map['fullName'],
        password: map['password'],
      imageRef: map['imageRef'],
        payment: map['payment']
    );
  }


  // sending data to our server
  Map<String, dynamic> toBecomeRegistration() {
    return {
      'email': email,
      'fullName': fullName,
      'password': password,
      'imageRef': imageRef,
      'payment': payment,
    };
  }
}
