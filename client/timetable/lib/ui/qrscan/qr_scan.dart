import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan/scan.dart';

class QRCodeScanPage extends StatelessWidget {
  final ScanController controller = ScanController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ScanView(
        controller: controller,
// custom scan area, if set to 1.0, will scan full area
        scanAreaScale: .7,
        scanLineColor: Colors.green.shade400,
        onCapture: (data) {
          Navigator.pop(context, data);
        },
      ),
    );
  }
}
