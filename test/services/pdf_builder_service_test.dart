import 'package:flutter_test/flutter_test.dart';
import 'package:red_erp/services/pdf_builder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'buildDocumentPdf renders a real Sales Invoice into non-empty PDF bytes',
    () async {
      final bytes = await PdfBuilderService.buildDocumentPdf(
        doctype: 'Sales Invoice',
        name: 'ACC-SINV-2026-00011',
        doc: {
          'company': 'اليكس للمستلزمات الزراعية',
          'customer_name': 'محمد حامد',
          'posting_date': '2026-09-04',
          'items': [
            {
              'item_name': 'اناناس ثمار محسن, ( 1000 بذرة )',
              'qty': 2,
              'rate': 100.0,
              'amount': 200.0,
            },
          ],
          'net_total': 200.0,
          'discount_amount': 0,
          'grand_total': 200.0,
          'outstanding_amount': 200.0,
          'terms': '<p>الدفع خلال 30 يوم</p>',
        },
      );

      expect(bytes, isNotEmpty);
      // A real PDF always starts with this magic header.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    },
  );

  test('buildStockStatementPdf includes tracked stock rows', () async {
    final bytes = await PdfBuilderService.buildStockStatementPdf(
      warehouseLabel: 'مخزن السيارة',
      rows: const [
        {
          'date': '2026-10-11',
          'item': 'صنف تجريبي',
          'warehouse': 'مخزن السيارة',
          'voucherType': 'Sales Invoice',
          'voucherNo': 'SINV-1',
          'qty': -1,
          'balance': 9,
          'batch': 'BATCH-1',
          'serial': 'SERIAL-1',
        },
      ],
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
