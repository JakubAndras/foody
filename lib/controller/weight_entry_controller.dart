import 'package:get/get.dart';

import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/weight_entry_repository.dart';
import 'base_controller.dart';

class WeightEntryController extends BaseController {
  static WeightEntryController get to => Get.find();

  WeightEntryController({required WeightEntryRepository repository}) : _repository = repository;

  final WeightEntryRepository _repository;

  final RxList<WeightEntry> entries = <WeightEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshEntries();
  }

  Future<void> refreshEntries() async {
    final data = await _repository.getAllEntries();
    entries.assignAll(data);
  }

  Future<void> saveEntry(WeightEntry entry) async {
    await _repository.upsertEntry(entry);
    await refreshEntries();
  }

  Future<void> deleteEntry(WeightEntry entry) async {
    await _repository.deleteEntry(entry);
    await refreshEntries();
  }

  WeightEntry? get latestEntry => entries.isNotEmpty ? entries.first : null;

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
