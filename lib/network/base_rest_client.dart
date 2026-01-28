import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as DioPackage;
import 'package:get/get.dart';
import 'package:diplomka/utils/error.dart';

abstract class BaseRestClient extends GetxService {
  final DioPackage.Dio dio = DioPackage.Dio();
  RxBool hasNetworkConnection = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    dio.options.connectTimeout = 30000;
    dio.options.receiveTimeout = 30000;

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      hasNetworkConnection.value = result != ConnectivityResult.none;
    });
  }

  Future<void> checkInternetConnection() async {
    await Connectivity().checkConnectivity().then(
          (ConnectivityResult connectivityResult) {
        hasNetworkConnection.value = connectivityResult != ConnectivityResult.none;
        if (connectivityResult == ConnectivityResult.none) {
          throw Error.noInternetConnection();
        }
      },
    );
  }
}

enum Method { post, postMultipart, postFormData, get, put, delete, patch }