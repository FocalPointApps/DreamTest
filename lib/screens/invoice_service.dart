import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:grocery_store/models/payHistory.dart';

class CustomRow {
  final String statment;
  final String currency;
  final String total;
  final String date;

  CustomRow(this.statment, this.currency, this.total, this.date);
}

class PdfInvoiceService {
  Future<Uint8List> createHelloWorld() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hello World"),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> createInvoice(GroceryUser user,BuildContext context,PayHistory pay) async {
    final pdf = pw.Document();

    final List<CustomRow> elements = [
      CustomRow(getTranslated(context, "statement"), getTranslated(context, "currency"),getTranslated(context, "total"),getTranslated(context, "date")),
        CustomRow(
       "dddd",// "user.name",
          "dddd",// getTranslated(context, "sar"),
          "dddd",// double.parse((double.parse(  pay.balance.toString())*3.69).toString()).toStringAsFixed(1),
          "dddd",//'${new DateFormat('dd MMM yyyy, hh:mm a').format(pay.payTime.toDate())}',
        ),

    ];
    final image = (await rootBundle.load('assets/applicationIcons/Group165.png')).buffer.asUint8List();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Image(pw.MemoryImage(image), width: 150, height: 150, fit: pw.BoxFit.cover),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text("Customer Name"),
                      pw.Text("Customer Address"),
                      pw.Text("Customer City"),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text("Max Weber"),
                      pw.Text("Weird Street Name 1"),
                      pw.Text("77662 Not my City"),
                      pw.Text("Vat-id: 123456"),
                      pw.Text("Invoice-Nr: 00001")
                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Text(
                  "Dear Customer, thanks for buying at Flutter Explained, feel free to see the list of items below."),
              pw.SizedBox(height: 25),
              itemColumn(elements),
              pw.SizedBox(height: 25),
              pw.Text("Thanks for your trust, and till the next time."),
              pw.SizedBox(height: 25),
              pw.Text("Kind regards,"),
              pw.SizedBox(height: 25),
              pw.Text("Max Weber")
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Expanded itemColumn(List<CustomRow> elements) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          for (var element in elements)
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text(element.statment, textAlign: pw.TextAlign.left)),
                pw.Expanded(child: pw.Text(element.currency, textAlign: pw.TextAlign.right)),
                pw.Expanded(child: pw.Text(element.total, textAlign: pw.TextAlign.right)),
                pw.Expanded(child: pw.Text(element.date, textAlign: pw.TextAlign.right)),
              ],
            )
        ],
      ),
    );
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
   // await OpenDocument.openDocument(filePath: filePath);
  }


}
