import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';

class InvoiceService {
  static Future<Uint8List> generateInvoice(OrderEntity order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(order),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildOrderInfo(order),
          pw.SizedBox(height: 20),
          _buildAddressSection(order),
          pw.SizedBox(height: 20),
          _buildItemsTable(order),
          pw.SizedBox(height: 20),
          _buildSummary(order),
          pw.SizedBox(height: 40),
          _buildPaymentInfo(order),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(OrderEntity order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TAPTO',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Your Go-To App for Everything!',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '#${order.id.substring(order.id.length - 8).toUpperCase()}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColors.grey300, thickness: 1),
        // Show cancelled banner if order is cancelled
        if (order.status == OrderStatus.cancelled) ...[
          pw.SizedBox(height: 12),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: pw.BoxDecoration(
              color: PdfColors.red100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.red400),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'ORDER CANCELLED',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                if (order.cancellationReason != null) ...[
                  pw.Text(
                    ' - ${order.cancellationReason}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.red700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildOrderInfo(OrderEntity order) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final isCancelled = order.status == OrderStatus.cancelled;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: isCancelled ? PdfColors.red50 : PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: isCancelled ? pw.Border.all(color: PdfColors.red200) : null,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Order Date:', dateFormat.format(order.createdAt)),
              pw.SizedBox(height: 4),
              _buildInfoRow('Tracking No:', order.trackingNumber ?? 'N/A'),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.Text(
                    'Status: ',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    order.status.name.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: isCancelled ? PdfColors.red700 : PdfColors.grey900,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              if (order.deliveredAt != null && !isCancelled)
                _buildInfoRow('Delivered:', dateFormat.format(order.deliveredAt!)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAddressSection(OrderEntity order) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILLING ADDRESS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                order.shippingAddress.fullName,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                order.shippingAddress.street,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                '${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.zipCode}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                order.shippingAddress.phone,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 40),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SHIPPING ADDRESS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                order.shippingAddress.fullName,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                order.shippingAddress.street,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                '${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.zipCode}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                order.shippingAddress.phone,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(OrderEntity order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ORDER ITEMS',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue800),
              children: [
                _buildTableHeader('Product'),
                _buildTableHeader('Qty'),
                _buildTableHeader('Price'),
                _buildTableHeader('Total'),
              ],
            ),
            // Item rows
            ...order.items.map((item) => pw.TableRow(
              children: [
                _buildTableCell(item.productName),
                _buildTableCell('${item.quantity}', align: pw.TextAlign.center),
                _buildTableCell('\$${item.price.toStringAsFixed(2)}', align: pw.TextAlign.right),
                _buildTableCell('\$${(item.price * item.quantity).toStringAsFixed(2)}', align: pw.TextAlign.right),
              ],
            )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildSummary(OrderEntity order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _buildSummaryRow('Subtotal:', '\$${order.subtotal.toStringAsFixed(2)}'),
              pw.SizedBox(height: 4),
              _buildSummaryRow('Shipping:', '\$${order.shippingFee.toStringAsFixed(2)}'),
              pw.SizedBox(height: 4),
              _buildSummaryRow('Tax (13%):', '\$${order.tax.toStringAsFixed(2)}'),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentInfo(OrderEntity order) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final isRefunded = order.status == OrderStatus.refunded;
    
    String paymentStatus;
    PdfColor statusColor;
    
    if (isCancelled) {
      paymentStatus = 'CANCELLED';
      statusColor = PdfColors.red700;
    } else if (isRefunded) {
      paymentStatus = 'REFUNDED';
      statusColor = PdfColors.purple700;
    } else if (order.status == OrderStatus.delivered) {
      paymentStatus = 'PAID';
      statusColor = PdfColors.green700;
    } else {
      paymentStatus = 'PENDING';
      statusColor = PdfColors.orange700;
    }
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: isCancelled ? PdfColors.red300 : PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
        color: isCancelled ? PdfColors.red50 : null,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT INFORMATION',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text(
                'Payment Method: ',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                order.paymentMethod.type.toUpperCase(),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text(
                'Payment Status: ',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                paymentStatus,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (isCancelled && order.cancellationReason != null) ...[
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Text(
                  'Cancellation Reason: ',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.Expanded(
                  child: pw.Text(
                    order.cancellationReason!,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.red700),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Thank you for shopping with TapTo!',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'For questions about this invoice, contact support@tapto.com',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey500,
          ),
        ),
      ],
    );
  }
}
