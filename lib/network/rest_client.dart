import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart' as dio_package;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'base_rest_client.dart';

class RestClient extends BaseRestClient {
  static RestClient get to => Get.find();
  static String prefixName = 'Foody';

}

class ApiUrl {
  // some endpoints

}