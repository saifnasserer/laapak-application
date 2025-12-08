import 'laapak_api_service.dart';

/// Example usage of LaapakApiService
/// 
/// This file demonstrates how to use the Laapak API service
/// for various operations.

// Example 1: Using API Key Authentication
Future<void> exampleApiKeyUsage() async {
  // Initialize service with API key
  final api = LaapakApiService(
    apiKey: 'ak_live_your_api_key_here',
  );
  
  try {
    // Health check
    final health = await api.healthCheck();
    print('API Health: $health');
    
    // Verify client credentials
    final verification = await api.verifyClient(
      phone: '01128260256',
      orderCode: 'ORD123456',
    );
    print('Client verified: ${verification['client']}');
    
    final clientId = verification['client']['id'] as int;
    
    // Get client reports
    final reports = await api.getClientReports(
      clientId,
      status: 'active',
      limit: 10,
    );
    print('Found ${reports['reports']?.length} reports');
    
    // Get client invoices
    final invoices = await api.getClientInvoices(
      clientId,
      paymentStatus: 'paid',
      limit: 10,
    );
    print('Found ${invoices['invoices']?.length} invoices');
    
    // Export client data
    final export = await api.exportClientData(clientId);
    print('Exported data: $export');
    
  } catch (e) {
    if (e is LaapakApiException) {
      print('API Error: ${e.errorCode} - ${e.message}');
    } else {
      print('Error: $e');
    }
  }
}

// Example 2: Using JWT Token Authentication (Admin)
Future<void> exampleJwtAdminUsage() async {
  // First, login to get JWT token
  final api = LaapakApiService(useDevelopment: false);
  
  try {
    // Admin login
    final loginResponse = await api.adminLogin(
      username: 'admin_username',
      password: 'admin_password',
    );
    
    final token = loginResponse['token'] as String;
    
    // Create new service with JWT token
    final adminApi = LaapakApiService(jwtToken: token);
    
    // Get all clients
    final clients = await adminApi.getAllClients();
    print('Total clients: ${clients['data']?.length}');
    
    // Create a new client
    final newClient = await adminApi.createClient(
      name: 'Ahmed Mohamed',
      phone: '01128260256',
      email: 'ahmed@example.com',
      orderCode: 'ORD123456',
      status: 'active',
    );
    print('Created client: ${newClient['id']}');
    
    // Create a report
    final report = await adminApi.createReport(
      clientId: 1,
      deviceModel: 'iPhone 15 Pro',
      serialNumber: 'ABC123456789',
      status: 'active',
      billingEnabled: true,
      amount: 500.00,
    );
    print('Created report: ${report['id']}');
    
    // Get all reports
    final reports = await adminApi.getAllReports(
      status: 'active',
      billingEnabled: true,
    );
    print('Total reports: ${reports['data']?.length}');
    
    // Create invoice
    final invoice = await adminApi.createInvoice(
      clientId: 1,
      date: DateTime.now().toIso8601String(),
      subtotal: 500.00,
      taxRate: 15.00,
      tax: 75.00,
      total: 575.00,
      paymentStatus: 'unpaid',
      paymentMethod: 'cash',
      items: [
        {
          'description': 'Device Repair',
          'type': 'service',
          'quantity': 1,
          'amount': 500.00,
          'totalAmount': 500.00,
        },
      ],
    );
    print('Created invoice: ${invoice['id']}');
    
  } catch (e) {
    if (e is LaapakApiException) {
      print('API Error: ${e.errorCode} - ${e.message}');
    } else {
      print('Error: $e');
    }
  }
}

// Example 3: Using JWT Token Authentication (Client)
Future<void> exampleJwtClientUsage() async {
  // First, login to get JWT token
  final api = LaapakApiService(useDevelopment: false);
  
  try {
    // Client login
    final loginResponse = await api.clientLogin(
      phone: '01128260256',
      orderCode: 'ORD123456',
    );
    
    final token = loginResponse['token'] as String;
    final client = loginResponse['client'];
    
    print('Logged in as: ${client['name']}');
    
    // Create new service with JWT token
    final clientApi = LaapakApiService(jwtToken: token);
    
    // Get client's own data
    final clientId = client['id'] as int;
    final clientData = await clientApi.getClient(clientId);
    print('Client data: $clientData');
    
    // Note: Clients typically can only access their own reports/invoices
    // through the API key endpoints, not JWT endpoints
    
  } catch (e) {
    if (e is LaapakApiException) {
      print('API Error: ${e.errorCode} - ${e.message}');
    } else {
      print('Error: $e');
    }
  }
}

// Example 4: Bulk Operations
Future<void> exampleBulkOperations() async {
  final api = LaapakApiService(
    apiKey: 'ak_live_your_api_key_here',
  );
  
  try {
    // Bulk client lookup
    final lookup = await api.bulkLookupClients(
      phones: ['01128260256', '01234567890'],
      emails: ['client1@example.com', 'client2@example.com'],
      orderCodes: ['ORD123456', 'ORD789012'],
    );
    print('Found ${lookup['count']} clients');
    
  } catch (e) {
    if (e is LaapakApiException) {
      print('API Error: ${e.errorCode} - ${e.message}');
    } else {
      print('Error: $e');
    }
  }
}

// Example 5: Error Handling
Future<void> exampleErrorHandling() async {
  final api = LaapakApiService(
    apiKey: 'ak_live_your_api_key_here',
  );
  
  try {
    await api.getClient(999999); // Non-existent client
  } on LaapakApiException catch (e) {
    switch (e.statusCode) {
      case 401:
        print('Authentication failed. Check your API key or token.');
        break;
      case 403:
        print('Access denied. Check your permissions.');
        break;
      case 404:
        print('Resource not found.');
        break;
      case 429:
        print('Rate limit exceeded. Please wait before retrying.');
        break;
      case 500:
        print('Server error. Please try again later.');
        break;
      default:
        print('Unexpected error: ${e.message}');
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}

