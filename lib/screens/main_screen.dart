import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:get/get.dart';

import 'package:diplomka/screens/dashboard_screen.dart';
import 'package:diplomka/screens/recipes_screen.dart';
import 'package:diplomka/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:diplomka/controller/base_controller.dart';

class MainScreen extends GetView<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => MainScreenController.to.widgetOptions.elementAt(controller._selectedIndex.value)),
      ),
      bottomNavigationBar: Obx(() => BottomNavBar(
        currentIndex: controller._selectedIndex.value,
        onTap: controller._onItemTapped,
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller._showImageSourceActionSheet(context);
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class MainScreenController extends BaseController {
  static MainScreenController get to => Get.find();
  final RxInt _selectedIndex = 0.obs;

  final List<Widget> widgetOptions = <Widget>[
    DashboardScreen(),
    RecipesScreen(),
  ];

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.black),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  DashboardController.to.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  DashboardController.to.pickImage(ImageSource.gallery);
                },
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
