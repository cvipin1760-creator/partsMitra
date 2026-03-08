class Product {
  final int id;
  final String name;
  final String partNumber;
  final String? rackNumber;
  final double mrp;
  final double sellingPrice; // General/Default price
  final double wholesalerPrice;
  final double retailerPrice;
  final double mechanicPrice;
  final int stock;
  final int wholesalerId;
  final String? imagePath;
  final bool enabled;

  Product({
    required this.id,
    required this.name,
    required this.partNumber,
    this.rackNumber,
    required this.mrp,
    required this.sellingPrice,
    required this.wholesalerPrice,
    required this.retailerPrice,
    required this.mechanicPrice,
    required this.stock,
    required this.wholesalerId,
    this.imagePath,
    this.enabled = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      partNumber: json['partNumber'],
      rackNumber: json['rackNumber'],
      mrp: (json['mrp'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      wholesalerPrice:
          (json['wholesalerPrice'] ?? json['sellingPrice'] as num).toDouble(),
      retailerPrice:
          (json['retailerPrice'] ?? json['sellingPrice'] as num).toDouble(),
      mechanicPrice:
          (json['mechanicPrice'] ?? json['sellingPrice'] as num).toDouble(),
      stock: json['stock'],
      wholesalerId: json['wholesalerId'] ?? 0,
      imagePath: json['imagePath'],
      enabled: (json['enabled'] ?? 1) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'partNumber': partNumber,
      'rackNumber': rackNumber,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'wholesalerPrice': wholesalerPrice,
      'retailerPrice': retailerPrice,
      'mechanicPrice': mechanicPrice,
      'stock': stock,
      'wholesalerId': wholesalerId,
      'imagePath': imagePath,
      'enabled': enabled ? 1 : 0,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? partNumber,
    String? rackNumber,
    double? mrp,
    double? sellingPrice,
    double? wholesalerPrice,
    double? retailerPrice,
    double? mechanicPrice,
    int? stock,
    int? wholesalerId,
    String? imagePath,
    bool? enabled,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      rackNumber: rackNumber ?? this.rackNumber,
      mrp: mrp ?? this.mrp,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      wholesalerPrice: wholesalerPrice ?? this.wholesalerPrice,
      retailerPrice: retailerPrice ?? this.retailerPrice,
      mechanicPrice: mechanicPrice ?? this.mechanicPrice,
      stock: stock ?? this.stock,
      wholesalerId: wholesalerId ?? this.wholesalerId,
      imagePath: imagePath ?? this.imagePath,
      enabled: enabled ?? this.enabled,
    );
  }
}
