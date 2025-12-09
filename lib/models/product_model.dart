/// Product Model
///
/// Represents a product that helps with device care
class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double? price;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.price,
  });

  /// Convert from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}

/// Mock Products Data
class MockProducts {
  static List<ProductModel> get careProducts => [
        ProductModel(
          id: '1',
          name: 'مواد تنظيف مخصصة للشاشات',
          description: 'مناديل وسوائل تنظيف آمنة على الشاشات، تحافظ على طبقة الحماية وتزيل البقع والأتربة بسهولة.',
          imageUrl: 'https://via.placeholder.com/300x200?text=Cleaning+Products',
          price: 150.0,
        ),
        ProductModel(
          id: '2',
          name: 'شنطة حماية مبطنة',
          description: 'شنطة مخصصة للابتوب بحماية من الصدمات، مبطنة من الداخل لحماية الجهاز أثناء التنقل.',
          imageUrl: 'https://via.placeholder.com/300x200?text=Protection+Bag',
          price: 350.0,
        ),
        ProductModel(
          id: '3',
          name: 'قاعدة تبريد',
          description: 'قاعدة تبريد لتحسين تدفق الهواء وتقليل الحرارة، تحافظ على أداء الجهاز وتمنع السخونة الزائدة.',
          imageUrl: 'https://via.placeholder.com/300x200?text=Cooling+Pad',
          price: 250.0,
        ),
        ProductModel(
          id: '4',
          name: 'غطاء حماية للكيبورد',
          description: 'غطاء سيليكون لحماية الكيبورد من الأتربة والسوائل، سهل التركيب والتنظيف.',
          imageUrl: 'https://via.placeholder.com/300x200?text=Keyboard+Cover',
          price: 120.0,
        ),
        ProductModel(
          id: '5',
          name: 'شاحن احتياطي أصلي',
          description: 'شاحن احتياطي أصلي متوافق مع جهازك، يضمن شحن آمن وكفاءة عالية للبطارية.',
          imageUrl: 'https://via.placeholder.com/300x200?text=Original+Charger',
          price: 400.0,
        ),
        ProductModel(
          id: '6',
          name: 'حقيبة حماية للشاحن',
          description: 'حقيبة لحماية كابل الشاحن من التلف والانحناء، تحافظ على الشاحن لفترة أطول.',
          imageUrl: 'https://via.placeholder.com/300x200?text=Charger+Case',
          price: 80.0,
        ),
      ];
}

