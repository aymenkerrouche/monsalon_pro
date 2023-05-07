
// ignore_for_file: must_be_immutable

import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/material.dart';
import 'package:monsalon_pro/models/Category.dart';
import 'package:provider/provider.dart';
import '../../Provider/AuthProvider.dart';
import '../../Provider/CategoriesProvider.dart';
import '../../Theme/colors.dart';
import '../../models/Service.dart';

class ListCategories extends StatelessWidget {
  const ListCategories({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<CategoriesProvider>(
        builder: (context, categories, child){
          return SizedBox(
            height: size.height * 0.75,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(categories.categories.length, (index) => ServicesList(category: categories.categories[index],)),
              ),
            ),
          );
        }
    );
  }
}

class ServicesList extends StatefulWidget {
  const ServicesList({Key? key, required this.category, this.isNew = false}) : super(key: key);
  final Category category;
  final bool isNew;

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {

  late GroupController serviceController;
  List<Service> srvInit = [];

  @override
  void initState() {
    if(widget.isNew == true){
      final provider = Provider.of<AuthProvider>(context,listen: false);
      if(widget.category.servicesParDefault.isNotEmpty){
        for (var element in provider.mySalon.service) {
          if(widget.category.servicesParDefault.where((service) => service.id == element.serviceID).isNotEmpty){
            srvInit.add(widget.category.servicesParDefault.where((service) => service.id == element.serviceID).first);
            //serviceController.select(widget.category.servicesParDefault.where((service) => service.id == element.serviceID));
          }
        }
      }
      serviceController = GroupController(isMultipleSelection: true,initSelectedItem: srvInit);
    }
    else{
      serviceController = GroupController(isMultipleSelection: true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context,listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        child: SimpleGroupedCheckbox<Service>(
          controller: serviceController,
          groupTitle: widget.category.category,
          groupTitleAlignment: Alignment.centerLeft,
          helperGroupTitle: true,
          isExpandableTitle: true,
          itemsTitle: List.generate(widget.category.servicesParDefault.length, (index) => "${widget.category.servicesParDefault[index].service}"),
          values: widget.category.servicesParDefault.toList(),
          groupStyle: GroupStyle(
            activeColor: primary,
            itemTitleStyle: const TextStyle(fontSize: 16),
            groupTitleStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black,),
          ),
          checkFirstElement: false,
          onItemSelected: (v){
            List<Service> lista = v;
            if(lista.isNotEmpty){
              if(provider.mySalon.categories.where((element) => element == widget.category.category).isEmpty){
                provider.mySalon.categories.add(widget.category.category!);
                provider.mySalon.service.addAll(lista);
              }
              else{
                provider.mySalon.service.removeWhere((element) => element.category == widget.category.category);
                provider.mySalon.service.addAll(lista);
              }
            }
            else{
              provider.mySalon.categories.removeWhere((element) => element == widget.category.category);
              provider.mySalon.service.removeWhere((element) => element.category == widget.category.category);
            }
            provider.refresh();
          },
        ),
      ),
    );
  }
}