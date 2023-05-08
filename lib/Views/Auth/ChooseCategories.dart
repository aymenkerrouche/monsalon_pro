
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/AuthProvider.dart';
import '../../Theme/colors.dart';
import '../../Widgets/ListOfCategories.dart';
import 'Done.dart';


class ChooseCategories extends StatelessWidget {
  ChooseCategories({Key? key}) : super(key: key);
  bool next = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const FittedBox(child: Text("Choisissez vos catégories",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_rounded,color: Colors.white,)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            const ListCategories(),
            const Spacer(),
            StatefulBuilder(
              builder: (context, setInnerState) {
                return TextButton(
                onPressed:() async {
                  setInnerState((){next = true;});
                  await Provider.of<AuthProvider>(context,listen: false).createSalonCategoriesAndServices().then((value){
                    setInnerState((){next = false;});
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DoneScreen()));});
                },
                style: TextButton.styleFrom(
                  backgroundColor: primary,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Text("  Continue", style: TextStyle(fontSize: 24,color: Colors.white,fontWeight: FontWeight.w600),),
                    const SizedBox(width: 10,),
                    next ? const SizedBox(height: 20,width: 20,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2.5,),) :
                    const Icon(Icons.arrow_forward_rounded,size: 26,color: Colors.white,),
                  ],
                ),
              );
              }
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}





