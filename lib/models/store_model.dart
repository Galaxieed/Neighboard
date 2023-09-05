class StoreModel {
  late String storeId;
  late String storeName;
  late String storeHouseNumber;
  late String storeStreetName;
  late String storeContactNo;
  late String storeImage;

  StoreModel({
    required this.storeId,
    required this.storeName,
    required this.storeHouseNumber,
    required this.storeStreetName,
    required this.storeContactNo,
    required this.storeImage,
  });

  StoreModel.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeHouseNumber = json['store_house_number'];
    storeStreetName = json['store_street_name'];
    storeContactNo = json['store_contact_no'];
    storeImage = json['store_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['store_house_number'] = storeHouseNumber;
    data['store_street_name'] = storeStreetName;
    data['store_contact_no'] = storeContactNo;
    data['store_image'] = storeImage;
    return data;
  }
}
