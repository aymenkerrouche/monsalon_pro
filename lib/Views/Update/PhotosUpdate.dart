// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../../Provider/AuthProvider.dart';
import '../../Theme/colors.dart';
import '../../Widgets/SnaKeBar.dart';
import '../../Widgets/keyboard.dart';
import '../../models/Image.dart';

class UpdatePhotos extends StatelessWidget {
  const UpdatePhotos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(onTap: () {FocusScope.of(context).unfocus();KeyboardUtil.hideKeyboard(context);},
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Photos",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600)),
          backgroundColor: primary,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed:() async {
                final provider =  Provider.of<AuthProvider>(context,listen: false);
                final ImagePicker picker = ImagePicker();
                final List<XFile> imagesTemp = await picker.pickMultiImage(imageQuality: 100);
                if(imagesTemp.isNotEmpty){
                  for (var element in imagesTemp) {
                    provider.addTempsImages(element);
                  }
                }
              },
              icon: const Icon(Icons.add_photo_alternate_rounded,color: Colors.white,size: 26,),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
            ),
            const SizedBox(width: 8,),
          ],
          leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          height: size.height,
          width: size.width,
          child: const UpdatePhotosBody()
        ),
      ),
    );
  }
}



class UpdatePhotosBody extends StatefulWidget {
  const UpdatePhotosBody({Key? key}) : super(key: key);

  @override
  State<UpdatePhotosBody> createState() => _UpdatePhotosBodyState();
}

class _UpdatePhotosBodyState extends State<UpdatePhotosBody> {

  bool next = false;
  bool done = false;

  Future<void> getPhotos() async {
    final provider =  Provider.of<AuthProvider>(context,listen: false);
    await provider.getSalonImages().then((value){
      Timer(const Duration(milliseconds: 500), () {setState(() {done = true;});});
    });
  }

  @override
  void initState() {
    getPhotos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if(done == false){
            return const Center(child: CircularProgressIndicator(color: primary, strokeWidth: 3,));
          }
          if(auth.images.isEmpty && auth.imagesFiles.isEmpty){
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Il n'y a pas de photos",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 1), maxLines:2,),
                Image.asset("assets/icons/empty.png",height: 200,),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20,),
                        const Text("Ajoutez vos photos",style: TextStyle(color: primaryPro, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: 1), maxLines: 3,),
                        const SizedBox(height: 20,),

                        // OLD PHOTOS
                        Wrap(children: List.generate(auth.images.length, (index) => PhotoCardNetwork(photo: auth.images[index])),),

                        if(auth.imagesFiles.isNotEmpty && auth.images.isNotEmpty) const Divider(height: 30,thickness: 2,color: primaryLite,),

                        // NEW PHOTOS
                        Wrap(children: List.generate(auth.imagesFiles.length, (index) => PhotoCard(photo: auth.imagesFiles[index],)),),


                        const SizedBox(height: 50,),
                      ],
                    )
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if(auth.imagesFiles.isEmpty){Navigator.pop(context);}
                  else{
                    setState(() {next = true;});
                    await Provider.of<AuthProvider>(context,listen: false).uploadSalonImages().then((value){
                      setState(() {next = false;});
                      final snackBar = SnackBar(
                        elevation: 10,
                        padding: const EdgeInsets.only(left: 10),
                        backgroundColor: primaryLite2,
                        behavior: SnackBarBehavior.floating,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mise à jour réussie",
                              style: TextStyle(color: Colors.white,fontFamily: "Rubik"),
                            ),
                            Lottie.asset("assets/animation/done2.json",height: 50,width: 50,reverse: true,repeat: true)
                          ],
                        ),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.pop(context);})
                    .catchError((onError){
                      setState(() {next = false;});
                      final snackBar = snaKeBar(onError.toString());
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                    setState(() {next = false;});
                  }
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primary,
                    elevation: 4,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
                ),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      const Text("Sauvegarder", style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 1)),
                      const SizedBox(width: 10,),
                      next ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,),) :
                      const Icon(Icons.check_rounded, size: 22,)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25,),
            ],
          );
        }
    );
  }
}


class PhotoCard extends StatelessWidget {
  const PhotoCard({Key? key, required this.photo}) : super(key: key);
  final XFile photo;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          margin: EdgeInsets.all(size.width * 0.03),
          child: Material(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: InkWell(
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    enableDrag: false,
                    builder: (context) => Stack(
                        children:[
                          PhotoView(
                            imageProvider: Image.file(File(photo.path)).image,
                          ),
                          Positioned(top: 40,right: 16,child: IconButton(
                            onPressed:() => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded,color: primaryPro,size: 30,),
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primary,
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                elevation: 20
                            ),
                          ),)
                        ]
                    ),
                  );
                },
                onLongPress: () async {
                  await showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16)),),
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16)),),
                          title: const Text("Supprimer",style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20, letterSpacing: 1)),
                          trailing: const Icon(CupertinoIcons.delete,color: pinkPro,),
                          onTap: () {
                            Provider.of<AuthProvider>(context,listen: false).removeTempsImages(photo.path);
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(height: 0,thickness: 1,color: Colors.grey,),
                        ListTile(
                          title: const Text("Image principale",style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20, letterSpacing: 1)),
                          trailing: const Icon(CupertinoIcons.photo_on_rectangle,color: primary,),
                          onTap: () {
                            Provider.of<AuthProvider>(context,listen: false).changeMainPhoto(photo.path);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 5,)
                      ],
                    ),
                  );
                },
                splashColor: primary.withOpacity(.5),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: Container(
                  height: size.width * 0.4,width: size.width * 0.4,
                  padding: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Ink.image(image: Image.file(File(photo.path)).image,fit:BoxFit.cover,),
                )
            ),
          ),
        ),
        if(photo.path == Provider.of<AuthProvider>(context,listen: false).mySalon.photo)const Positioned(top: 0,right: 0,child:Icon(Icons.check_circle,color: Colors.pinkAccent,),)
      ],
    );
  }
}

class PhotoCardNetwork extends StatelessWidget {
  const PhotoCardNetwork({Key? key, required this.photo, }) : super(key: key);
  final Pic photo;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          margin: EdgeInsets.all(size.width * 0.03),
          child: Material(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: InkWell(
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    enableDrag: false,
                    builder: (context) => Stack(
                        children:[
                          PhotoView(
                            imageProvider: Image.network(photo.path!).image,
                          ),
                          Positioned(top: 40,right: 16,child: IconButton(
                            onPressed:() => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded,color: primaryPro,size: 30,),
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primary,
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                elevation: 20
                            ),
                          ),)
                        ]
                    ),
                  );
                },
                onLongPress: () async {
                  await showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16)),),
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16)),),
                          title: const Text("Supprimer",style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20, letterSpacing: 1)),
                          trailing: const Icon(CupertinoIcons.delete,color: pinkPro,),
                          onTap: () {
                            Provider.of<AuthProvider>(context,listen: false).deleteImage(photo.name!);
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(height: 0,thickness: 1,color: Colors.grey,),
                        ListTile(
                          title: const Text("Image principale",style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20, letterSpacing: 1)),
                          trailing: const Icon(CupertinoIcons.photo_on_rectangle,color: primary,),
                          onTap: () {
                            Provider.of<AuthProvider>(context,listen: false).updateMainPicture(photo.path!);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 5,)
                      ],
                    ),
                  );
                },
                splashColor: primary.withOpacity(.5),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: Container(
                  height: size.width * 0.4,width: size.width * 0.4,
                  padding: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Ink.image(image: Image.network(photo.path!).image,fit:BoxFit.cover,),
                )
            ),
          ),
        ),
        if(photo.path == Provider.of<AuthProvider>(context,listen: false).mySalon.photo)const Positioned(top: 0,right: 0,child:Icon(Icons.check_circle,color: Colors.pinkAccent,),)
      ],
    );
  }
}



/*class AddPhoto extends StatelessWidget {
  const AddPhoto({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.all(size.width * 0.03),
      child: Material(
        color: primaryLite.withOpacity(.4),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: InkWell(
            onTap: () async {

            },
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Container(
              height: size.width * 0.3,width: size.width * 0.3,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                borderRadius:  BorderRadius.all(Radius.circular(16)
                ),
              ),
              child: Image.asset("assets/icons/image.png",color: primaryLite2,),
            )
        ),
      ),
    );
  }
}*/




