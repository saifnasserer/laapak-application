/// Client Model
///
/// Represents a client/user in the Laapak system.
class ClientModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String orderCode;
  final String? status;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.orderCode,
    this.status,
    this.createdAt,
    this.lastLogin,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      orderCode: json['orderCode'] as String? ?? json['order_code'] as String? ?? '',
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : json['last_login'] != null
              ? DateTime.parse(json['last_login'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      'orderCode': orderCode,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
    };
  }
}

