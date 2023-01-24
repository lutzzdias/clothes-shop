import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/models/cart_product.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/models/user.dart';
import 'package:loja_virtual/models/user_manager.dart';

class CartManager extends ChangeNotifier {
  List<CartProduct> items = [];
  User? user;
  num productsPrice = 0.0;

  bool get isCartValid {
    for (final CartProduct cartProduct in items)
      if (!cartProduct.hasStock) return false;
    return true;
  }

  void updateUser(UserManager userManager) {
    user = userManager.user;
    items.clear();

    if (user != null) {
      _loadCartItems();
    }
  }

  _loadCartItems() async {
    final QuerySnapshot? cartSnap = await user?.cartRef.get();
    items = cartSnap?.docs.map((doc) {
          final item = CartProduct.fromDocument(doc);
          item.addListener(() => _onItemUpdated(item));
          return item;
        }).toList() ??
        [];
  }

  void addToCart(Product product) {
    try {
      final cartItem = items.firstWhere((item) => item.stackable(product));
      cartItem.increment();
    } catch (e) {
      final CartProduct cartProduct = CartProduct.fromProduct(product);
      cartProduct.addListener(() => _onItemUpdated(cartProduct));
      items.add(cartProduct);
      user?.cartRef.add(cartProduct.toMap()).then((doc) {
        cartProduct.id = doc.id;
        _onItemUpdated(cartProduct);
      });
    }
    notifyListeners();
  }

  void _onItemUpdated(CartProduct cartProduct) {
    if (cartProduct.quantity > 0)
      _updateCartProduct(cartProduct);
    else
      _removeFromCart(cartProduct);
    _calculateTotalPrice();
    notifyListeners();
  }

  void _removeFromCart(CartProduct cartProduct) {
    items.removeWhere((element) => element.id == cartProduct.id);
    user!.cartRef.doc(cartProduct.id).delete();
    cartProduct.removeListener(() => _onItemUpdated(cartProduct));
    notifyListeners();
  }

  void _updateCartProduct(CartProduct cartProduct) {
    user!.cartRef.doc(cartProduct.id).update(cartProduct.toMap());
  }

  void _calculateTotalPrice() {
    productsPrice = 0;
    for (CartProduct cartProduct in items)
      productsPrice += cartProduct.totalPrice;
  }
}