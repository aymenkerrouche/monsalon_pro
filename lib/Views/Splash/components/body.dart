// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Views/Auth/authOTP.dart';
import 'package:monsalon_pro/Views/Splash/components/splash_content.dart';
import '../../../theme/colors.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  @override
  void didChangeDependencies() {
    precacheImage(const AssetImage('assets/images/spa.jpg'), context);
    precacheImage(const AssetImage('assets/images/chv2.jpg'), context);
    precacheImage(const AssetImage('assets/images/barber.jpg'), context);
    super.didChangeDependencies();
  }
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Réservez 24h/24 et 7j/7",
      "text2": "Réservez où vous voulez quand vous voulez depuis votre chambre ou dans le taxi.",
      "image": "assets/images/barber.jpg"
    },
    {
      "text": "Promotions et réductions",
      "text2": "Economisez jusqu’à moins 50% sur vos prestations préférées !",
      "image": "assets/images/chv2.jpg"
    },
    {
      "text": "Trouvez votre prochain salon",
      "text2": "Choisissez votre établissement le plus proche et surtout qui convient à votre budge",
      "image": "assets/images/spa.jpg"
    },
  ];
  PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        SizedBox(
          height: size.height,
          width: size.width,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            itemCount: splashData.length,
            itemBuilder: (context, index) => SplashContent(
              image: splashData[index]["image"],
              text: splashData[index]['text'],
              text2: splashData[index]['text2'],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                splashData.length,
                (index) => buildDot(index: index),
              ),
            ),
          ),),
        Positioned(
          bottom: 15,
          child: SizedBox(
            width: size.width,
            child: Row(
              children: [
                const SizedBox(width: 10,),
                if(currentPage != 0)IconButton(
                  onPressed:(){
                    setState(() {currentPage--;});
                    controller.animateToPage(
                      currentPage,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn);
                    },
                  icon: const Icon(Icons.arrow_back_ios_rounded,color: Colors.white,size: 26,),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white70
                  ),
                ),
                const Spacer(),
                if(currentPage != 2)IconButton(
                  onPressed:(){
                    setState(() {currentPage++;});
                    controller.animateToPage(
                      currentPage,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn);
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 26,),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white70
                  ),
                ),
                if(currentPage == 2)TextButton(
                  onPressed:(){
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => const AuthOTP()),
                            (Route<dynamic> route) => false);
                  },
                  child: const Text("Continue",style: TextStyle(color: Colors.white ,fontWeight: FontWeight.w700,fontSize: 18,letterSpacing: 1),),
                ),
                const SizedBox(width: 10,),
              ],
            ),
          ),
        )
      ]
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? primary : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
