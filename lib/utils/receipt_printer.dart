
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/transaction.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> printReceipt(Transaction transaction) async {
  final printers = await Printing.info();

  if (printers.canPrint) {
    final doc = pw.Document();
    final storeName = objectBox.storeDetailsBox.getAll().first.name;
    final formatter = NumberFormat.currency(symbol: "P");

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(storeName, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Transaction ID:', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('${transaction.transactionID}', style: const pw.TextStyle(fontSize: 9)),
                ]
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date & Time:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('${transaction.time}', style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Cashier:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('${transaction.user.target?.firstName} ${transaction.user.target?.lastName}', style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.SizedBox(height: 20),

              // Packaged Products
              pw.Text('Packaged Products:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              for (var package in transaction.packages) ...[
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(package.name, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text("", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text(package.quantity.toString(), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text(formatter.format(package.price), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),

                      ]
                    ),
                    for (var product in package.productsList)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(product.name, style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(formatter.format(product.unitPrice), style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(product.quantity.toString(), style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(formatter.format(product.totalPrice), style: const pw.TextStyle(fontSize: 9))
                        ]
                      )
                  ]
                ),
                pw.SizedBox(height: 9),
              ],
              pw.SizedBox(height: 20),

              pw.Text('Products:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              for (var product in transaction.products)
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(product.name, style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(formatter.format(product.unitPrice), style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(product.quantity.toString(), style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(formatter.format(product.totalPrice), style: const pw.TextStyle(fontSize: 9))
                    ]
                ),
              pw.SizedBox(height: 20),

              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Sub-Total:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(formatter.format(transaction.subTotal), style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(formatter.format(transaction.discount), style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(formatter.format(transaction.totalAmount), style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Method:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(transaction.paymentMethod, style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Reference Number:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(transaction.referenceNumber, style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(formatter.format(transaction.payment), style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Change:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(formatter.format(transaction.change), style: const pw.TextStyle(fontSize: 9)),
                  ]
              ),
              pw.SizedBox(height: 20),
            ]
          );
        }
      ),
    );


    try {
      // Trigger the print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to print: $e");
    }
  } else {
    Fluttertoast.showToast(msg: "No printers available");
  }
}