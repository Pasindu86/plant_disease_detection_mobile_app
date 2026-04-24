class MarketItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String phoneNumber; // Added phone number

  MarketItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.phoneNumber,
  });

  MarketItem copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    String? phoneNumber,
  }) {
    return MarketItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'phoneNumber': phoneNumber,
    };
  }

  factory MarketItem.fromMap(Map<String, dynamic> map, String id) {
    return MarketItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}