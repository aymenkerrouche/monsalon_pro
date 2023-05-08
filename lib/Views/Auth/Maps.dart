
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:monsalon_pro/Provider/AuthProvider.dart';
import 'package:monsalon_pro/Widgets/SnaKeBar.dart';
import 'package:provider/provider.dart';
import '../../Provider/CategoriesProvider.dart';
import '../../Services/location_services.dart';
import '../../theme/colors.dart';
import 'ChooseCategories.dart';


class MapScreen extends StatelessWidget {
  MapScreen({Key? key, this.isUpdate = false}) : super(key: key);
  LatLng? currentLocation;
  bool isUpdate;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Position GPS",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 24)),
        backgroundColor: primary,
        centerTitle: true,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,),),
        actions: [
          if(!isUpdate)TextButton(
            onPressed:() async {
              final provider = Provider.of<CategoriesProvider>(context,listen: false);
              try{
                await Provider.of<AuthProvider>(context,listen: false).createSalonSansLocation().then((value) async =>
                  await provider.getCategories()
                    .then((value) async => await provider.getServices()
                      .then((v) => Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseCategories()),)),
                  )
                );
              }
              catch(e){
                final snackBar = snaKeBar(e.toString());
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text("passer",style: TextStyle(color: Colors.white),),
          )
        ],
      ),
      body: Consumer<AuthProvider>(
          builder: (context, maps, child){
            return Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  indoorViewEnabled: true,
                  onCameraMove: (e) => currentLocation = e.target,
                  zoomControlsEnabled : false,
                  initialCameraPosition: maps.myLocation,
                  onMapCreated: (GoogleMapController controller) {_controller.complete(controller);},
                  markers: maps.markers,
                ),
                Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/icons/location.png'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: maps.markers.isEmpty? Colors.grey :  primaryLite2,
                          foregroundColor: Colors.white,
                          fixedSize: Size(size.width, 48)
                      ),
                      onPressed: () async {
                        if(maps.markers.isEmpty){
                          GFToast.showToast("Placer le marqueur à l'emplacement du salon", context,backgroundColor: Colors.black,toastPosition: GFToastPosition.BOTTOM,toastDuration: 4);
                        }
                        else{
                          final provider = Provider.of<CategoriesProvider>(context,listen: false);
                          try{
                            await maps.createSalon().then((value) async {
                              await provider.getCategories()
                                  .then((value) async => await provider.getServices()
                                  .then((v) => Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseCategories()),)));
                            });
                          }
                          catch(e){
                            GFToast.showToast(e.toString(), context,backgroundColor: Colors.black,toastPosition: GFToastPosition.BOTTOM,toastDuration: 4);
                          }
                        }

                      },
                      child: Text( isUpdate ? "Sauvegarder" : "Ajouter", style: const TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.w600),),
                    ),
                  ),
                ),
              ]
            );
          }
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "marker",
              onPressed: () => Provider.of<AuthProvider>(context,listen: false).setMarker(currentLocation!),
              //backgroundColor: Colors.black,
              child: const Icon(Icons.add_location_alt_outlined),
            ),
            const SizedBox(height: 20,),
            FloatingActionButton(
              heroTag: "mylocation",
              onPressed: () => getMyLocation(context),
              child: const Icon(Icons.gps_fixed),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getMyLocation(context) async {
    try{
      LocationData newLocation = await LocationService().getLocation();
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(newLocation.latitude!, newLocation.longitude!),
        zoom: 14.5,
      ),));
      Provider.of<AuthProvider>(context,listen: false).getMyLocation(context);
    }
    catch(e){
      GFToast.showToast(e.toString(), context,backgroundColor: Colors.black,toastPosition: GFToastPosition.BOTTOM,toastDuration: 4);
      await Location().serviceEnabled();
    }
  }

}