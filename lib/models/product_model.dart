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

  /// Convert from WooCommerce JSON response
  factory ProductModel.fromWooCommerceJson(Map<String, dynamic> json) {
    // Extract image URL from images array
    String imageUrl = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final firstImage = (json['images'] as List).first;
      if (firstImage is Map<String, dynamic>) {
        imageUrl = firstImage['src']?.toString() ?? '';
      }
    }
    
    // Extract description - Use only short_description from WooCommerce
    String description = '';
    if (json['short_description'] != null && json['short_description'].toString().trim().isNotEmpty) {
      description = _stripHtmlTags(json['short_description'].toString());
    }
    
    // Extract price - WooCommerce uses 'price' or 'regular_price'
    double? price;
    if (json['price'] != null && json['price'].toString().isNotEmpty) {
      price = double.tryParse(json['price'].toString());
    } else if (json['regular_price'] != null && json['regular_price'].toString().isNotEmpty) {
      price = double.tryParse(json['regular_price'].toString());
    }
    
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: description,
      imageUrl: imageUrl,
      price: price,
    );
  }
  
  /// Strip HTML tags from description
  static String _stripHtmlTags(String htmlString) {
    // Simple HTML tag removal - you might want to use a package like html_unescape for better handling
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
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
/// 
/// Note: This is a fallback mock data class. In production, products should be
/// fetched from WooCommerce API. This class is kept for development/testing purposes only.
class MockProducts {
  static List<ProductModel> get careProducts => [
        ProductModel(
          id: '1',
          name: 'مواد تنظيف مخصصة للشاشات',
          description: 'مناديل وسوائل تنظيف آمنة على الشاشات، تحافظ على طبقة الحماية وتزيل البقع والأتربة بسهولة.',
          imageUrl: '',
          price: 150.0,
        ),
        ProductModel(
          id: '2',
          name: 'شنطة حماية مبطنة',
          description: 'شنطة مخصصة للابتوب بحماية من الصدمات، مبطنة من الداخل لحماية الجهاز أثناء التنقل.',
          imageUrl: '',
          price: 350.0,
        ),
        ProductModel(
          id: '3',
          name: 'قاعدة تبريد',
          description: 'قاعدة تبريد لتحسين تدفق الهواء وتقليل الحرارة، تحافظ على أداء الجهاز وتمنع السخونة الزائدة.',
          imageUrl: '',
          price: 250.0,
        ),
        ProductModel(
          id: '4',
          name: 'غطاء حماية للكيبورد',
          description: 'غطاء سيليكون لحماية الكيبورد من الأتربة والسوائل، سهل التركيب والتنظيف.',
          imageUrl: '',
          price: 120.0,
        ),
        ProductModel(
          id: '5',
          name: 'شاحن احتياطي أصلي',
          description: 'شاحن احتياطي أصلي متوافق مع جهازك، يضمن شحن آمن وكفاءة عالية للبطارية.',
          imageUrl: '',
          price: 400.0,
        ),
        ProductModel(
          id: '6',
          name: 'حقيبة حماية للشاحن',
          description: 'حقيبة لحماية كابل الشاحن من التلف والانحناء، تحافظ على الشاحن لفترة أطول.',
          imageUrl: '',
          price: 80.0,
        ),
      ];
}

