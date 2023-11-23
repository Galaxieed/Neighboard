class HOAModel {
  late String hoaId;
  late String firstName;
  late String lastName;
  late String suffix;
  late String street;
  late bool isRegistered;

  HOAModel({
    required this.hoaId,
    required this.firstName,
    required this.lastName,
    required this.suffix,
    required this.street,
    required this.isRegistered,
  });

  HOAModel.fromJson(Map<String, dynamic> json) {
    hoaId = json['hoa_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    suffix = json['suffix'];
    street = json['street'];
    isRegistered = json['is_registered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hoa_id'] = hoaId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['suffix'] = suffix;
    data['street'] = street;
    data['is_registered'] = isRegistered;
    return data;
  }
}
