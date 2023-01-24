import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/item_size.dart';
import 'package:loja_virtual/models/product.dart';

class CartProduct extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String id;
  String productId;
  int quantity;
  String size;

  Product? product;
  CartProduct.fromProduct(this.product)
      : id = '',
        productId = product!.id,
        quantity = 1,
        size = product.selectedSize!.name;

  CartProduct.fromDocument(DocumentSnapshot document)
      : id = document.id,
        productId = document.get('productId') as String,
        quantity = document.get('quantity') as int,
        size = document.get('size') as String {
    _firestore.doc('products/$productId').get().then((doc) {
      product = Product.fromDocument(doc);
      notifyListeners();
    });
  }

  ItemSize? get itemSize {
    if (product == null)
      return null;
    else
      return product!.findSize(size);
  }

  num get unitPrice {
    if (product == null)
      return 0;
    else
      return itemSize?.price ?? 0;
  }

  num get totalPrice => unitPrice * quantity;

  bool stackable(Product product) =>
      product.id == productId && product.selectedSize!.name == size;

  bool get hasStock {
    final size = itemSize;
    if (size == null)
      return false;
    else
      return size.stock >= quantity;
  }

  void increment() {
    quantity++;
    notifyListeners();
  }

  void decrement() {
    quantity--;
    notifyListeners();
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'productId': productId,
        'quantity': quantity,
        'size': size,
      };
}