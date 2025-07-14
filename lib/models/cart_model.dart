import 'package:pos_desktop_loop/db/tables/product/products_table.dart';

class CartItem {
  final ProductsTable product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
