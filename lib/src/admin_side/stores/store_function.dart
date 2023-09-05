import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighboard/models/store_model.dart';

class StoreFunction {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> addStore(StoreModel storeModel) async {
    try {
      await _firestore
          .collection("stores")
          .doc(storeModel.storeId)
          .set(storeModel.toJson());

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<StoreModel>?> getAllStores() async {
    try {
      final result = await _firestore.collection("stores").get();
      List<StoreModel> storeModel = [];
      storeModel =
          result.docs.map((e) => StoreModel.fromJson(e.data())).toList();

      return storeModel;
    } catch (e) {
      return null;
    }
  }
}
