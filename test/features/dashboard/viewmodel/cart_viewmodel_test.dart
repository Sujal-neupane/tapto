import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';

void main() {
  // Helper to create a test cart item
  CartItemModel createItem({
    String id = 'p1',
    String name = 'Test Product',
    double price = 29.99,
    int quantity = 1,
    String size = 'M',
    String color = 'Red',
  }) {
    return CartItemModel(
      productId: id,
      productName: name,
      productImage: 'https://example.com/image.jpg',
      price: price,
      quantity: quantity,
      size: size,
      color: color,
    );
  }

  group('CartState', () {
    // Test 1: Initial state is empty
    test('should have empty items and zero subtotal by default', () {
      final state = CartState();

      expect(state.items, isEmpty);
      expect(state.subtotal, 0.0);
      expect(state.shippingFee, 0.0);
      expect(state.tax, 0.0);
      expect(state.total, 0.0);
      expect(state.itemCount, 0);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    // Test 2: Subtotal calculation with multiple items
    test('should calculate subtotal correctly', () {
      final items = [
        createItem(id: 'p1', price: 10.0, quantity: 2),
        createItem(id: 'p2', price: 25.0, quantity: 1),
      ];
      final state = CartState(items: items);

      expect(state.subtotal, 45.0); // (10*2) + (25*1)
    });

    // Test 3: Shipping fee is 10 when items exist, 0 when empty
    test('should have shipping fee of 10.0 when items exist', () {
      final state = CartState(items: [createItem()]);

      expect(state.shippingFee, 10.0);
    });

    // Test 4: Item count sums all quantities
    test('should sum all item quantities for itemCount', () {
      final items = [
        createItem(id: 'p1', quantity: 3),
        createItem(id: 'p2', quantity: 2),
      ];
      final state = CartState(items: items);

      expect(state.itemCount, 5);
    });

    // Test 5: Total is subtotal + shipping + tax
    test('should calculate total as subtotal + shipping + tax', () {
      final items = [
        createItem(id: 'p1', price: 100.0, quantity: 1),
      ];
      final state = CartState(items: items);

      // subtotal: 100, shipping: 10, tax: 0
      expect(state.total, 110.0);
    });

    // Test 6: copyWith preserves unchanged fields
    test('copyWith should preserve unchanged fields', () {
      final original = CartState(
        items: [createItem()],
        isLoading: true,
        error: 'some error',
      );
      final updated = original.copyWith(isLoading: false);

      expect(updated.items.length, 1);
      expect(updated.isLoading, false);
      expect(updated.error, isNull); // error is nullable, copyWith sets null when not passed
    });
  });

  group('CartItemModel', () {
    // Test 7: fromJson creates correct model
    test('should create CartItemModel from JSON', () {
      final json = {
        'productId': 'p1',
        'productName': 'Test Shirt',
        'productImage': '/uploads/shirt.jpg',
        'price': 49.99,
        'quantity': 2,
        'size': 'L',
        'color': 'Blue',
      };

      final item = CartItemModel.fromJson(json);

      expect(item.productId, 'p1');
      expect(item.productName, 'Test Shirt');
      expect(item.price, 49.99);
      expect(item.quantity, 2);
      expect(item.size, 'L');
      expect(item.color, 'Blue');
    });

    // Test 8: toJson produces correct map
    test('should convert CartItemModel to JSON', () {
      final item = createItem(
        id: 'p1',
        name: 'Dress',
        price: 89.99,
        quantity: 1,
        size: 'S',
        color: 'Black',
      );

      final json = item.toJson();

      expect(json['productId'], 'p1');
      expect(json['productName'], 'Dress');
      expect(json['price'], 89.99);
      expect(json['quantity'], 1);
      expect(json['size'], 'S');
      expect(json['color'], 'Black');
    });

    // Test 9: copyWith creates new instance with updated fields
    test('copyWith should update specified fields', () {
      final original = createItem(id: 'p1', quantity: 1);
      final updated = original.copyWith(quantity: 5);

      expect(updated.quantity, 5);
      expect(updated.productId, 'p1');
      expect(original.quantity, 1); // original unchanged
    });

    // Test 10: totalPrice calculation
    test('totalPrice should be price * quantity', () {
      final item = createItem(price: 25.0, quantity: 4);

      expect(item.totalPrice, 100.0);
    });
  });
}
