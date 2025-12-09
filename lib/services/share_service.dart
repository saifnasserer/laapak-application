import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';

/// Share Service
///
/// Service for sharing content from the app.
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  /// Share text
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      // Handle share error silently
    }
  }

  /// Share report information
  Future<void> shareReport({
    required String reportId,
    required String deviceModel,
    String? serialNumber,
    String? inspectionDate,
  }) async {
    // Build the report URL in the format: https://reports.laapak.com/report.html?id=REPORT_ID
    final reportUrl = 'https://reports.laapak.com/report.html?id=$reportId';

    final buffer = StringBuffer();
    buffer.writeln('تقرير من ${AppConstants.appName}');
    buffer.writeln('');
    buffer.writeln('نوع الجهاز: $deviceModel');
    if (serialNumber != null && serialNumber.isNotEmpty) {
      buffer.writeln('السيريال: $serialNumber');
    }
    if (inspectionDate != null && inspectionDate.isNotEmpty) {
      buffer.writeln('تاريخ المعاينة: $inspectionDate');
    }
    buffer.writeln('');
    buffer.writeln('لمشاهدة التقرير الكامل:');
    buffer.writeln(reportUrl);

    await shareText(
      buffer.toString(),
      subject: 'تقرير من ${AppConstants.appName}',
    );
  }

  /// Share invoice information
  Future<void> shareInvoice({
    required String invoiceId,
    required String total,
    String? date,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('فاتورة من ${AppConstants.appName}');
    buffer.writeln('');
    if (date != null && date.isNotEmpty) {
      buffer.writeln('التاريخ: $date');
    }
    buffer.writeln('المبلغ الإجمالي: $total');
    buffer.writeln('');
    buffer.writeln('لمشاهدة الفاتورة الكاملة:');
    buffer.writeln('${AppConstants.appWebsite}/invoices/$invoiceId');

    await shareText(
      buffer.toString(),
      subject: 'فاتورة من ${AppConstants.appName}',
    );
  }

  /// Share app
  Future<void> shareApp() async {
    final text = '''
تطبيق ${AppConstants.appName}

تطبيق لإدارة التقارير والفواتير والضمان

${AppConstants.appWebsite}
''';

    await shareText(
      text,
      subject: 'تطبيق ${AppConstants.appName}',
    );
  }
}

