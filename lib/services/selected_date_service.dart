import 'package:get/get.dart';

class SelectedDateService extends GetxService {
  static SelectedDateService get to {
    if (Get.isRegistered<SelectedDateService>()) {
      return Get.find<SelectedDateService>();
    }
    return Get.put(SelectedDateService(), permanent: true);
  }

  static DateTime normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  final Rx<DateTime> selectedDate = normalize(DateTime.now()).obs;

  void setSelectedDate(DateTime date) {
    selectedDate.value = normalize(date);
  }
}
