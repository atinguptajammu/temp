import 'package:get/get.dart';

class HomeController extends GetxController{
  @override
  void onInit() async{
    super.onInit();
    await Future.delayed(const Duration(seconds: 2));
  }

}