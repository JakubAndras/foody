import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:flutter/material.dart';

class WeightHistoryEditEntryScreen extends StatelessWidget {
  const WeightHistoryEditEntryScreen({super.key, this.entry});

  final WeightEntry? entry;

  @override
  Widget build(BuildContext context) {
    return WeightLogSheet(entry: entry);
  }
}
