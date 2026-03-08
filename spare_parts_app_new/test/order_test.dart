import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts_app/services/order_service.dart';
import 'package:spare_parts_app/models/order.dart';

void main() {
  group('OrderService Tests', () {
    test('Order model serialization', () {
      final order = Order(
        id: 1,
        customerId: 1,
        customerName: 'Test Customer',
        sellerId: 2,
        sellerName: 'Test Seller',
        totalAmount: 1000.0,
        status: 'PENDING',
        createdAt: DateTime.now().toIso8601String(),
        items: [],
      );

      final json = order.toJson();
      expect(json['status'], 'PENDING');

      final fromJson = Order.fromJson(json);
      expect(fromJson.status, 'PENDING');
    });
  });
}
