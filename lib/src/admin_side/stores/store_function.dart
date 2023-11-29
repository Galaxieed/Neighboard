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

  static Future<List<StoreModel>?> getStoresLocation() async {
    try {
      final result = await _firestore
          .collection("stores")
          .where("store_location", isNotEqualTo: "")
          .get();
      List<StoreModel> storeModel = [];
      storeModel =
          result.docs.map((e) => StoreModel.fromJson(e.data())).toList();

      return storeModel;
    } catch (e) {
      return null;
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

  static Future<bool> removeStore(StoreModel store) async {
    try {
      //archive store
      await _firestore
          .collection("archived_stores")
          .doc(store.storeId)
          .set(store.toJson())
          .then((value) async {
        //remove announcement
        await _firestore.collection("stores").doc(store.storeId).delete();
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> retrieveArchivedStore(StoreModel store) async {
    try {
      //archive store
      await _firestore
          .collection("stores")
          .doc(store.storeId)
          .set(store.toJson())
          .then((value) async {
        //remove announcement
        await _firestore
            .collection("archived_stores")
            .doc(store.storeId)
            .delete();
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<StoreModel>?> getArchivedStores() async {
    try {
      final result = await _firestore.collection("archived_stores").get();
      List<StoreModel> stores = [];
      stores = result.docs.map((e) => StoreModel.fromJson(e.data())).toList();
      return stores;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateStore(String storeId, String name, String offers,
      String houseNo, String street) async {
    try {
      //update
      await _firestore.collection("stores").doc(storeId).update({
        "store_name": name,
        "store_offers": offers,
        "store_house_number": houseNo,
        "store_street_name": street
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
