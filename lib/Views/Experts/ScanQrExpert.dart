import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Theme/colors.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../Provider/AuthProvider.dart';
import '../../models/Team.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool adding = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null) SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("L'EXPERT ID:"),
                          Text("${result!.code}"),
                        ],
                      ),
                    )
                  else  const Text('Scanner le code'),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FutureBuilder(
                          future: controller?.getFlashStatus(),
                          builder: (context, snapshot) {
                            return IconButton(
                              onPressed:() async {
                                await controller?.toggleFlash();
                                setState(() {});
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: primaryLite
                              ),
                              icon: Icon(snapshot.data == true ?  Icons.flashlight_on_outlined : Icons.flashlight_off_outlined,color: Colors.white,size: 30,),
                            );
                          },
                        ),
                        result?.code != null ? IconButton(
                          onPressed:() async {
                            setState(() {adding = true;});
                            await checkExpertExist();
                          },
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white
                          ),
                          icon: const Icon(Icons.check_rounded,color: Colors.white,size: 30,),
                        ):
                        IconButton(
                          onPressed:() async {},
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.teal.shade100,
                            foregroundColor: Colors.white
                          ),
                          icon: const Icon(Icons.check_rounded,color: Colors.white,size: 30,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 0.8;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: primaryLite2,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
  
  Future<void> checkExpertExist() async {
    final provider = Provider.of<AuthProvider>(context,listen: false);
    if(provider.mySalon.teams.where((element) => element.userID == result?.code).isEmpty){
      FirebaseFirestore.instance.collection("users").doc(result?.code).get().then((exp) async {
        if(exp.exists){
          Team newTeam = Team.fromJson({
            "salonID":FirebaseAuth.instance.currentUser?.uid,
            "name": exp.data()!["name"] ?? '',
            "userID": result?.code,
            "accept": true,
            "create": true,
            "active": true
          });

          try{
            await Provider.of<AuthProvider>(context,listen: false).ajouterExperts(newTeam).then((value) => Navigator.pop(context));
          }
          catch(e){
            final snackBar = snaKeBar(e.toString(),);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {adding = false;});
          }
        }
        else{
          final snackBar = snaKeBar("Utilisateur non trouvé");
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        setState(() {adding = false;});
      });
    }
    else{
      final snackBar = snaKeBar("L'expert existe déjà");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}