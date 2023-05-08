import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/Provider/AuthProvider.dart';
import 'package:provider/provider.dart';
import '../Theme/colors.dart';
import '../utils/cities.dart';
import '../utils/wilaya.dart';

class Wilaya extends StatefulWidget {
  const Wilaya({Key? key}) : super(key: key);

  @override
  State<Wilaya> createState() => _WilayaState();
}

class _WilayaState extends State<Wilaya> {

  @override
  void initState() {
    Provider.of<AuthProvider>(context,listen: false).laWilaya.addListener(Provider.of<AuthProvider>(context,listen: false).refresh);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: CustomDropdown(
            hintText: 'Wilaya',
            fillColor: clr3.withOpacity(.08),
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Rubik',
            ),
            items: wilaya.map((e) => '${e['code']!}  ${e['name']!}').toList(),
            controller: Provider.of<AuthProvider>(context,listen: false).laWilaya,
            listItemStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontFamily: 'Rubik',
            ),
            selectedStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600),
            fieldSuffixIcon: const Icon(Icons.arrow_drop_down_circle_outlined,color: primary,size: 20,),
            onChanged: (v){Provider.of<AuthProvider>(context,listen: false).clearLaCommune();},
          ),
        ),
        const SizedBox(height: 20,),
        Consumer<AuthProvider>(
            builder: (context, auth, child){
              if(Provider.of<AuthProvider>(context,listen: false).laWilaya.text.isEmpty) {
                return const SizedBox();
              }
              List<String> listCommune = [];
              listCommune = algeria_cites.where((el) => el['wilaya_code'] == Provider.of<AuthProvider>(context,listen: false).laWilaya.text.substring(0,2)).map((e) => '${e['commune_name_ascii']!}').toList();
              listCommune.sort((a, b) => a.compareTo(b));
              return SizedBox(
                height: 52,
                child: CustomDropdown(
                  hintText: 'Commune',
                  fillColor: clr3.withOpacity(.08),
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Rubik',
                  ),
                  items: listCommune,
                  controller: auth.laCommune,
                  listItemStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Rubik',
                  ),
                  selectedStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w600),
                  fieldSuffixIcon: Icon(Icons.arrow_drop_down_circle_outlined,color: primary,size: 20,),
                  //onChanged: (v){Provider.of<AuthProvider>(context,listen: false).setlaCommune(v);},
                ),
              );
            })
      ],
    );
  }
}
