import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';

class CartItem {
  final ProductsTable product;
  int quantity;
  String priceMode; // 'retail', 'wholesale', or 'offer'
  double unitPrice; // Stores the price at time of adding to cart

  CartItem({
    required this.product,
    this.quantity = 1,
    this.priceMode = 'retail',
  }) : unitPrice = _getPriceForMode(product, priceMode);

  static double _getPriceForMode(ProductsTable product, String mode) {
    switch (mode) {
      case 'wholesale':
        return product.wholesalePrice ?? product.unitPrice;
      case 'offer':
        return product.offerPrice! > 0
            ? (product.offerPrice ?? product.unitPrice)
            : product.unitPrice;
      case 'retail':
      default:
        return product.unitPrice;
    }
  }

  double get itemTotal => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': itemTotal,
      'priceMode': priceMode,
      'isService': product.isService,
    };
  }
}

class CartProvider with ChangeNotifier {
  // ShopID -> (ProductID -> CartItem)
  final Map<int, Map<int, CartItem>> _shopCarts = {};

  // ShopID -> price mode
  final Map<int, String> _shopPriceModes = {};

  // ShopID -> manual adjustment flag
  final Map<int, bool> _shopManualAdjustments = {};

  // Public getters
  Map<int, Map<int, CartItem>> get shopCarts => Map.unmodifiable(_shopCarts);
  int get totalItemCount =>
      _shopCarts.values.fold(0, (sum, cart) => sum + cart.length);

  // Get cart for a specific shop
  Map<int, CartItem>? getCartForShop(int shopId) {
    return _shopCarts[shopId] != null
        ? Map.unmodifiable(_shopCarts[shopId]!)
        : null;
  }

  // Get subtotal for a specific shop
  double getSubtotalForShop(int shopId) {
    return _shopCarts[shopId]?.values.fold(
          0.0,
          (sum, item) => sum! + item.itemTotal,
        ) ??
        0.0;
  }

  // Get total amount across all shops
  double get totalAmount {
    return _shopCarts.values.fold(0.0, (total, cart) {
      return total + cart.values.fold(0.0, (sum, item) => sum + item.itemTotal);
    });
  }

  // Core cart operations per shop
  void addItem(int shopId, ProductsTable product, {int quantity = 1}) {
    if (product.id == null) return;

    // Initialize shop cart if needed
    _shopCarts.putIfAbsent(shopId, () => {});
    _shopPriceModes.putIfAbsent(shopId, () => 'retail');
    _shopManualAdjustments.putIfAbsent(shopId, () => false);

    final productId = product.id!;
    final cart = _shopCarts[shopId]!;
    final priceMode = _shopPriceModes[shopId]!;

    if (cart.containsKey(productId)) {
      cart[productId]!.quantity += quantity;
    } else {
      cart[productId] = CartItem(
        product: product,
        quantity: quantity,
        priceMode: priceMode,
      );
    }
    notifyListeners();
  }

  void removeItem(int shopId, int productId) {
    final cart = _shopCarts[shopId];
    if (cart == null || !cart.containsKey(productId)) return;

    cart.remove(productId);
    // Clean up if shop cart is empty
    if (cart.isEmpty) {
      _shopCarts.remove(shopId);
      _shopPriceModes.remove(shopId);
      _shopManualAdjustments.remove(shopId);
    }
    notifyListeners();
  }

  void updateQuantity(int shopId, ProductsTable product, int newQuantity) {
    if (product.id == null || newQuantity < 1) {
      removeItem(shopId, product.id!);
      return;
    }

    final cart = _shopCarts[shopId];
    if (cart == null) return;

    final productId = product.id!;
    if (cart.containsKey(productId)) {
      cart[productId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  void updateUnitPrice(int shopId, int productId, double newPrice) {
    final cart = _shopCarts[shopId];
    if (cart == null || !cart.containsKey(productId)) return;

    cart[productId]!.unitPrice = newPrice;
    _shopManualAdjustments[shopId] = true;
    notifyListeners();
  }

  void setPriceModeForShop(int shopId, String newMode) {
    if (_shopPriceModes[shopId] == newMode) return;

    _shopPriceModes[shopId] = newMode;

    // Only update prices if no manual adjustments
    if (!(_shopManualAdjustments[shopId] ?? false)) {
      final cart = _shopCarts[shopId];
      if (cart != null) {
        for (final item in cart.values) {
          item.priceMode = newMode;
          item.unitPrice = CartItem._getPriceForMode(item.product, newMode);
        }
      }
    }
    notifyListeners();
  }

  void clearCartForShop(int shopId) {
    if (_shopCarts.containsKey(shopId)) {
      _shopCarts.remove(shopId);
      _shopPriceModes.remove(shopId);
      _shopManualAdjustments.remove(shopId);
      notifyListeners();
    }
  }

  void clearAllCarts() {
    _shopCarts.clear();
    _shopPriceModes.clear();
    _shopManualAdjustments.clear();
    notifyListeners();
  }

  // Helper methods
  int getProductQuantityForShop(int shopId, int productId) {
    return _shopCarts[shopId]?[productId]?.quantity ?? 0;
  }

  bool shopContainsProduct(int shopId, int productId) {
    return _shopCarts[shopId]?.containsKey(productId) ?? false;
  }

  // Loading cart state
  void loadCartItemsForShop(
    int shopId,
    List<Map<String, dynamic>> items,
    List<ProductsTable> allProducts,
  ) {
    clearCartForShop(shopId);

    for (var item in items) {
      final productId = item['productId'] as int;
      final product = allProducts.firstWhere(
        (p) => p.id == productId,
        orElse:
            () => ProductsTable(
              id: productId,
              name: item['productName'] as String,
              unitPrice: item['unitPrice'] as double,
              isService: (item['isService'] as int? ?? 0) == 1,
              wholesalePrice: item['wholesalePrice'] as double?,
              offerPrice: item['offerPrice'] as double? ?? 0.0,
              categoryId: item['categoryId'] as int? ?? 0,
              taxCategory: item['taxCategory'] as int? ?? 0,
              quantity: item['quantity'] as int? ?? 0,
              barcode: item['barcode'] as String? ?? '',
              buyingPrice: item['buyingPrice'] as double? ?? 0.0,
              restockLevel: item['restockLevel'] as int? ?? 0,

              shopId: shopId,
              isOffer: (item['isOffer'] as int? ?? 0) == 1,
            ),
      );

      addItem(shopId, product, quantity: item['quantity'] as int);

      // Restore manual price if different from default
      final savedPrice = item['unitPrice'] as double;
      final defaultPrice = CartItem._getPriceForMode(
        product,
        item['priceMode'] as String,
      );
      if (savedPrice != defaultPrice) {
        updateUnitPrice(shopId, productId, savedPrice);
      }
    }

    // Restore price mode if available
    if (items.isNotEmpty) {
      _shopPriceModes[shopId] = items.first['priceMode'] as String? ?? 'retail';
    }
  }

  void removeFromCart(int shopId, int productId) {
    final cart = _shopCarts[shopId];
    if (cart != null) {
      cart.remove(productId);
      notifyListeners();
    }
  }
}
