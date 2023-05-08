import 'package:flutter/material.dart';
import 'package:inwentarz_ee/data_access/equipment_service.dart';
import 'package:inwentarz_ee/views/equipment_details_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zeskanuj kod QR"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: AspectRatio(
            aspectRatio: 1,
            child: MobileScanner(
              fit: BoxFit.cover,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.format == BarcodeFormat.qrCode &&
                      RegExp("^[0-9a-fA-F]{8}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{12}\$")
                          .hasMatch(barcode.rawValue ?? "")) {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentDetailsPage(
                              EquipmentService.getEquipmentByUuid(
                                  barcode.rawValue!)),
                        ));
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
