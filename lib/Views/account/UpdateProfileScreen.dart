import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../Widgets/Photo_Profil.dart';
import 'components/UpdateProfileForm.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key, this.isSignUP = false});
  final bool isSignUP;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Profil",style: TextStyle(color: Colors.white,letterSpacing: .8),),
        backgroundColor: primary,
        elevation: 10,
        leading: isSignUP ? const SizedBox() : IconButton(
            onPressed:(){Navigator.pop(context);},
            icon:  const Icon(Icons.arrow_back_ios_new_rounded,color: Colors.white,)),
      ),
      body:  Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 0.5,left: 20,right: 20),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                const PhotoProfil(),
                const SizedBox(height: 60),
                UpdateProfileForm(isSignUP: isSignUP,),
              ],
            ),
          ),
        ),
      )
    );
  }
}





