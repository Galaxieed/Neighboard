import 'package:english_words/english_words.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/store_model.dart';

List<StoreModel> stores = [
  StoreModel(
    storeId: generateRandomId(8),
    storeName: WordPair.random().asPascalCase,
    storeAddress: 'Block and Lot Address',
    storeImage: bigScoopImage,
  ),
  StoreModel(
    storeId: generateRandomId(8),
    storeName: WordPair.random().asPascalCase,
    storeAddress: 'Block and Lot Address',
    storeImage: bigScoopImage,
  ),
  StoreModel(
    storeId: generateRandomId(8),
    storeName: WordPair.random().asPascalCase,
    storeAddress: 'Block and Lot Address',
    storeImage: bigScoopImage,
  ),
  StoreModel(
    storeId: generateRandomId(8),
    storeName: WordPair.random().asPascalCase,
    storeAddress: 'Block and Lot Address',
    storeImage: bigScoopImage,
  ),
];
