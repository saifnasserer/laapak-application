import 'dart:convert';
import 'package:http/http.dart' as http;

/// Laapak Report System API Service
/// 
/// This service provides a comprehensive interface to interact with the
/// Laapak Report System API. It supports both API Key and JWT token authentication.
class LaapakApiService {
  /// Base URL for API Key endpoints
  static const String _apiKeyBaseUrl = 'https://reports.laapak.com/api/v2/external';
  
  /// Base URL for JWT endpoints
  static const String _jwtBaseUrl = 'https://reports.laapak.com/api';
  
  /// Development base URL
  static const String _devBaseUrl = 'http://localhost:3000/api';
  
  final String? apiKey;
  final String? jwtToken;
  final bool useDevelopment;
  
  /// Base URL based on authentication method and environment
  String get baseUrl {
    if (useDevelopment) return _devBaseUrl;
    return apiKey != null ? _apiKeyBaseUrl : _jwtBaseUrl;
  }
  
  /// Headers for API requests
  Map<String, String> get headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (apiKey != null) {
      headers['x-api-key'] = apiKey!;
    } else if (jwtToken != null) {
      headers['x-auth-token'] = jwtToken!;
    }
    
    return headers;
  }
  
  /// Constructor
  /// 
  /// [apiKey] - API key for API key authentication (format: ak_live_... or ak_test_...)
  /// [jwtToken] - JWT token for user-based authentication
  /// [useDevelopment] - Use development server (default: false)
  /// 
  /// Note: Either apiKey or jwtToken should be provided, not both
  LaapakApiService({
    this.apiKey,
    this.jwtToken,
    this.useDevelopment = false,
  }) : assert(
          apiKey != null || jwtToken != null,
          'Either apiKey or jwtToken must be provided',
        );
  
  /// Make HTTP request to API
  Future<Map<String, dynamic>> _makeRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    var url = Uri.parse('$baseUrl$endpoint');
    
    // Add query parameters
    if (queryParams != null && queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }
    
    final request = http.Request(method, url);
    request.headers.addAll(headers);
    
    if (data != null && (method == 'POST' || method == 'PUT')) {
      request.body = jsonEncode(data);
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw LaapakApiException(
        message: errorData['message'] ?? 'Unknown error',
        errorCode: errorData['error'] ?? 'UNKNOWN_ERROR',
        statusCode: response.statusCode,
      );
    }
  }
  
  // ==================== Authentication ====================
  
  /// Health check endpoint
  /// 
  /// Returns API health status and permissions (for API key)
  Future<Map<String, dynamic>> healthCheck() async {
    final endpoint = apiKey != null ? '/health' : '/health';
    return await _makeRequest(endpoint, 'GET');
  }
  
  /// Admin login
  /// 
  /// Returns JWT token and user information
  Future<Map<String, dynamic>> adminLogin({
    required String username,
    required String password,
  }) async {
    return await _makeRequest(
      '/auth/login',
      'POST',
      data: {
        'username': username,
        'password': password,
      },
    );
  }
  
  /// Client login
  /// 
  /// Returns JWT token and client information
  Future<Map<String, dynamic>> clientLogin({
    required String phone,
    required String orderCode,
  }) async {
    return await _makeRequest(
      '/clients/auth',
      'POST',
      data: {
        'phone': phone,
        'orderCode': orderCode,
      },
    );
  }
  
  /// Verify client credentials (API Key only)
  /// 
  /// Verifies client using phone/email and order code
  Future<Map<String, dynamic>> verifyClient({
    String? phone,
    String? email,
    required String orderCode,
  }) async {
    assert(phone != null || email != null, 'Either phone or email must be provided');
    assert(apiKey != null, 'API key is required for this operation');
    
    final data = <String, dynamic>{
      'orderCode': orderCode,
    };
    
    if (phone != null) {
      data['phone'] = phone;
    }
    if (email != null) {
      data['email'] = email;
    }
    
    return await _makeRequest(
      '/auth/verify-client',
      'POST',
      data: data,
    );
  }
  
  // ==================== Client Management ====================
  
  /// Get client profile (API Key)
  Future<Map<String, dynamic>> getClientProfile(int clientId) async {
    assert(apiKey != null, 'API key is required for this operation');
    return await _makeRequest('/clients/$clientId/profile', 'GET');
  }
  
  /// Get all clients (JWT - Admin only)
  Future<Map<String, dynamic>> getAllClients() async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    return await _makeRequest('/clients', 'GET');
  }
  
  /// Get single client
  Future<Map<String, dynamic>> getClient(int clientId) async {
    return await _makeRequest('/clients/$clientId', 'GET');
  }
  
  /// Create client (JWT - Admin only)
  Future<Map<String, dynamic>> createClient({
    required String name,
    required String phone,
    String? email,
    String? address,
    required String orderCode,
    String? status,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    return await _makeRequest(
      '/clients',
      'POST',
      data: {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        'orderCode': orderCode,
        if (status != null) 'status': status,
      },
    );
  }
  
  /// Update client (JWT - Admin only)
  Future<Map<String, dynamic>> updateClient(
    int clientId, {
    String? name,
    String? phone,
    String? email,
    String? address,
    String? status,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (address != null) data['address'] = address;
    if (status != null) data['status'] = status;
    
    return await _makeRequest(
      '/clients/$clientId',
      'PUT',
      data: data,
    );
  }
  
  /// Bulk client lookup (API Key)
  Future<Map<String, dynamic>> bulkLookupClients({
    List<String>? phones,
    List<String>? emails,
    List<String>? orderCodes,
  }) async {
    assert(apiKey != null, 'API key is required for this operation');
    
    final data = <String, dynamic>{};
    if (phones != null && phones.isNotEmpty) data['phones'] = phones;
    if (emails != null && emails.isNotEmpty) data['emails'] = emails;
    if (orderCodes != null && orderCodes.isNotEmpty) data['orderCodes'] = orderCodes;
    
    return await _makeRequest(
      '/clients/bulk-lookup',
      'POST',
      data: data,
    );
  }
  
  /// Export client data (API Key)
  Future<Map<String, dynamic>> exportClientData(
    int clientId, {
    String format = 'json',
  }) async {
    assert(apiKey != null, 'API key is required for this operation');
    
    return await _makeRequest(
      '/clients/$clientId/data-export',
      'GET',
      queryParams: {'format': format},
    );
  }
  
  // ==================== Reports ====================
  
  /// Get client reports (API Key)
  Future<Map<String, dynamic>> getClientReports(
    int clientId, {
    String? status,
    String? startDate,
    String? endDate,
    String? deviceModel,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortOrder,
  }) async {
    assert(apiKey != null, 'API key is required for this operation');
    
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (deviceModel != null) queryParams['deviceModel'] = deviceModel;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    
    return await _makeRequest(
      '/clients/$clientId/reports',
      'GET',
      queryParams: queryParams,
    );
  }
  
  /// Get specific report
  Future<Map<String, dynamic>> getReport(String reportId) async {
    final endpoint = apiKey != null 
        ? '/reports/$reportId'
        : '/reports/$reportId';
    return await _makeRequest(endpoint, 'GET');
  }
  
  /// Get all reports (JWT - Admin)
  Future<Map<String, dynamic>> getAllReports({
    bool? billingEnabled,
    String? fetchMode,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    final queryParams = <String, String>{};
    if (billingEnabled != null) queryParams['billing_enabled'] = billingEnabled.toString();
    if (fetchMode != null) queryParams['fetch_mode'] = fetchMode;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (status != null) queryParams['status'] = status;
    
    return await _makeRequest(
      '/reports',
      'GET',
      queryParams: queryParams,
    );
  }
  
  /// Create report (JWT - Admin)
  Future<Map<String, dynamic>> createReport({
    required int clientId,
    required String deviceModel,
    String? serialNumber,
    String? inspectionDate,
    String? hardwareStatus,
    String? externalImages,
    String? notes,
    bool? billingEnabled,
    double? amount,
    String? status,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    final data = <String, dynamic>{
      'client_id': clientId,
      'device_model': deviceModel,
    };
    
    if (serialNumber != null) data['serial_number'] = serialNumber;
    if (inspectionDate != null) data['inspection_date'] = inspectionDate;
    if (hardwareStatus != null) data['hardware_status'] = hardwareStatus;
    if (externalImages != null) data['external_images'] = externalImages;
    if (notes != null) data['notes'] = notes;
    if (billingEnabled != null) data['billing_enabled'] = billingEnabled;
    if (amount != null) data['amount'] = amount;
    if (status != null) data['status'] = status;
    
    return await _makeRequest(
      '/reports',
      'POST',
      data: data,
    );
  }
  
  /// Update report (JWT - Admin)
  Future<Map<String, dynamic>> updateReport(
    String reportId, {
    String? status,
    String? notes,
    bool? billingEnabled,
    double? amount,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    final data = <String, dynamic>{};
    if (status != null) data['status'] = status;
    if (notes != null) data['notes'] = notes;
    if (billingEnabled != null) data['billing_enabled'] = billingEnabled;
    if (amount != null) data['amount'] = amount;
    
    return await _makeRequest(
      '/reports/$reportId',
      'PUT',
      data: data,
    );
  }
  
  /// Search reports (JWT)
  Future<Map<String, dynamic>> searchReports(String query) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    return await _makeRequest(
      '/reports/search',
      'GET',
      queryParams: {'q': query},
    );
  }
  
  // ==================== Invoices ====================
  
  /// Get client invoices (API Key)
  Future<Map<String, dynamic>> getClientInvoices(
    int clientId, {
    String? paymentStatus,
    String? startDate,
    String? endDate,
    int? limit,
    int? offset,
  }) async {
    assert(apiKey != null, 'API key is required for this operation');
    
    final queryParams = <String, String>{};
    if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    
    return await _makeRequest(
      '/clients/$clientId/invoices',
      'GET',
      queryParams: queryParams,
    );
  }
  
  /// Get specific invoice
  Future<Map<String, dynamic>> getInvoice(String invoiceId) async {
    final endpoint = apiKey != null 
        ? '/invoices/$invoiceId'
        : '/invoices/$invoiceId';
    return await _makeRequest(endpoint, 'GET');
  }
  
  /// Get all invoices (JWT - Admin)
  Future<Map<String, dynamic>> getAllInvoices({
    String? paymentMethod,
    String? paymentStatus,
    int? clientId,
    String? startDate,
    String? endDate,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    final queryParams = <String, String>{};
    if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;
    if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;
    if (clientId != null) queryParams['clientId'] = clientId.toString();
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    
    return await _makeRequest(
      '/invoices',
      'GET',
      queryParams: queryParams,
    );
  }
  
  /// Create invoice (JWT - Admin)
  Future<Map<String, dynamic>> createInvoice({
    required int clientId,
    required String date,
    required double subtotal,
    double? discount,
    double? taxRate,
    double? tax,
    required double total,
    String? paymentStatus,
    String? paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    final data = <String, dynamic>{
      'client_id': clientId,
      'date': date,
      'subtotal': subtotal,
      'total': total,
      'items': items,
    };
    
    if (discount != null) data['discount'] = discount;
    if (taxRate != null) data['taxRate'] = taxRate;
    if (tax != null) data['tax'] = tax;
    if (paymentStatus != null) data['paymentStatus'] = paymentStatus;
    if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
    
    return await _makeRequest(
      '/invoices',
      'POST',
      data: data,
    );
  }
  
  /// Create bulk invoice (JWT - Admin)
  Future<Map<String, dynamic>> createBulkInvoice({
    required String date,
    required List<String> reportIds,
    required int clientId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double total,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    return await _makeRequest(
      '/invoices/bulk',
      'POST',
      data: {
        'date': date,
        'reportIds': reportIds,
        'client_id': clientId,
        'items': items,
        'subtotal': subtotal,
        'total': total,
      },
    );
  }
  
  /// Update invoice (JWT - Admin)
  Future<Map<String, dynamic>> updateInvoice(
    String invoiceId, {
    String? paymentStatus,
    String? paymentMethod,
    String? notes,
  }) async {
    assert(jwtToken != null, 'JWT token is required for this operation');
    
    final data = <String, dynamic>{};
    if (paymentStatus != null) data['paymentStatus'] = paymentStatus;
    if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
    if (notes != null) data['notes'] = notes;
    
    return await _makeRequest(
      '/invoices/$invoiceId',
      'PUT',
      data: data,
    );
  }
}

/// Custom exception for Laapak API errors
class LaapakApiException implements Exception {
  final String message;
  final String errorCode;
  final int statusCode;
  
  LaapakApiException({
    required this.message,
    required this.errorCode,
    required this.statusCode,
  });
  
  @override
  String toString() {
    return 'LaapakApiException: $errorCode ($statusCode) - $message';
  }
}

