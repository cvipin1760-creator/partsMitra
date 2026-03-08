import 'package:flutter_test/flutter_test.dart';
import 'package:spare_parts_app/services/product_service.dart';
import 'package:spare_parts_app/models/product.dart';

void main() {
  group('ProductService Tests', () {
    test('getAllProducts exists', () async {
      final productService = ProductService();
      expect(productService.getAllProducts, isNotNull);
    });

    test('Product model serialization', () {
      final product = Product(
        id: 1,
        name: 'Spark Plug',
        partNumber: 'SP123',
        mrp: 500.0,
        sellingPrice: 450.0,
        wholesalerPrice: 400.0,
        retailerPrice: 420.0,
        mechanicPrice: 430.0,
        stock: 10,
        wholesalerId: 1,
      );
      
      final json = product.toJson();
      expect(json['name'], 'Spark Plug');
      
      final fromJson = Product.fromJson(json);
      expect(fromJson.name, 'Spark Plug');
    });
  });
}
