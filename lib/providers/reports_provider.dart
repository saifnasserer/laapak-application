import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Reports Provider
/// 
/// Fetches and manages report data for the authenticated client
final reportsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, reportId) async {
  final apiService = ref.watch(authenticatedApiServiceProvider);
  
  if (apiService == null) {
    developer.log('❌ No authenticated API service available', name: 'Reports');
    return null;
  }

  try {
    developer.log('📥 Fetching report: $reportId', name: 'Reports');
    final report = await apiService.getReport(reportId);
    developer.log('✅ Report fetched successfully', name: 'Reports');
    developer.log('   Report keys: ${report.keys}', name: 'Reports');
    developer.log('   Report data: $report', name: 'Reports');
    return report;
  } catch (e, stackTrace) {
    developer.log('❌ Failed to fetch report: $e', name: 'Reports');
    developer.log('   Error type: ${e.runtimeType}', name: 'Reports');
    developer.log('   Stack trace: $stackTrace', name: 'Reports');
    rethrow;
  }
});

/// Client Reports List Provider
/// 
/// Fetches all reports for the authenticated client
final clientReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final authState = ref.watch(authProvider);
  final apiService = ref.watch(authenticatedApiServiceProvider);
  
  if (apiService == null || authState.client == null) {
    developer.log('❌ No authenticated API service or client available', name: 'Reports');
    return [];
  }

  try {
    developer.log('📥 Fetching reports for client: ${authState.client!.id}', name: 'Reports');
    
    // Use the new /api/reports/me endpoint
    // This endpoint automatically uses the client_id from JWT token
    developer.log('   Using /api/reports/me endpoint', name: 'Reports');
    final response = await apiService.getMyReports(
      limit: 100, // Get all reports (max 100)
      sortBy: 'created_at', // Sort by creation date
      sortOrder: 'DESC', // Most recent first
    );
    developer.log('   ✅ Successfully fetched from /api/reports/me', name: 'Reports');
    
    developer.log('📥 API Response received', name: 'Reports');
    developer.log('   Response type: ${response.runtimeType}', name: 'Reports');
    developer.log('   Response keys: ${response.keys}', name: 'Reports');
    developer.log('   Response: $response', name: 'Reports');
    
    // Handle different response formats
    List<Map<String, dynamic>> reports = [];
    
    // Check if response has 'reports' key
    if (response.containsKey('reports')) {
      final reportsList = response['reports'];
      developer.log('   Found "reports" key, type: ${reportsList.runtimeType}', name: 'Reports');
      if (reportsList is List) {
        reports = List<Map<String, dynamic>>.from(
          reportsList.map((e) => e as Map<String, dynamic>),
        );
      }
    } 
    // Check if response has 'data' key
    else if (response.containsKey('data')) {
      final dataList = response['data'];
      developer.log('   Found "data" key, type: ${dataList.runtimeType}', name: 'Reports');
      if (dataList is List) {
        reports = List<Map<String, dynamic>>.from(
          dataList.map((e) => e as Map<String, dynamic>),
        );
      }
    }
    // Check if response itself is a list (wrapped by API service)
    else if (response.containsKey('data') && response['data'] is List) {
      final dataList = response['data'] as List;
      developer.log('   Response has "data" as List', name: 'Reports');
      reports = List<Map<String, dynamic>>.from(
        dataList.map((e) => e as Map<String, dynamic>),
      );
    }
    // If response is empty or has unexpected structure
    else {
      developer.log('   ⚠️ Unexpected response structure', name: 'Reports');
      developer.log('   Response content: $response', name: 'Reports');
    }
    
    developer.log('✅ Fetched ${reports.length} reports', name: 'Reports');
    return reports;
  } catch (e, stackTrace) {
    developer.log('❌ Failed to fetch reports: $e', name: 'Reports');
    developer.log('   Error type: ${e.runtimeType}', name: 'Reports');
    developer.log('   Stack trace: $stackTrace', name: 'Reports');
    return [];
  }
});

