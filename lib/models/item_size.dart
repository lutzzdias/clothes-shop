class ItemSize {
  String name;
  num price;
  int stock;

  ItemSize({
    required this.name,
    required this.price,
    required this.stock,
  });

  ItemSize.fromMap(Map<String, dynamic> map)
      : name = map['name'] as String,
        price = map['price'] as num,
        stock = map['stock'] as int;

  ItemSize.empty()
      : name = '',
        price = 0,
        stock = 0;

  bool get hasStock => stock > 0;

  ItemSize clone() => ItemSize(name: name, price: price, stock: stock);

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'stock': stock,
      };

  @override
  String toString() => 'ItemSize { name: $name, price: $price, stock: $stock }';
}
