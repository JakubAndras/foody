import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:diplomka/controller/base_controller.dart';

class ProfileScreen extends GetView<_ProfileScreenController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text(
          'Profile Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _ProfileScreenController extends BaseController {

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

}
