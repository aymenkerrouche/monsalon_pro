import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({Key? key, this.text, this.image,this.text2}) : super(key: key);
  final String? text, image,text2;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: Stack(
        children: <Widget>[
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(image!,),fit: BoxFit.fitHeight),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1, 0.7),
                  end: Alignment(1, 0),
                  stops:[0, 1],
                  colors: [
                    Color(0xFF15013A),
                    Color.fromARGB(80, 0, 0, 0),
                  ],
                )
              ),
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 80),
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*Card(
                   // shape: const CircleBorder(),
                    color: primaryPro.withOpacity(.01),
                    elevation: 20,
                    child: Container(
                      height: 80,
                      //width: size.width * 0.8,
                      padding: const EdgeInsets.only(right: 5,top: 5,bottom: 5),
                      child: Image.asset('assets/images/logo2.png',color: Colors.white,),
                    ),
                  ),
                  const SizedBox(height: 50,),*/
                  Text(
                    text!.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 24,letterSpacing: 1),
                  ),
                  const SizedBox(height: 15,),
                  Text(
                    text2!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white,fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
