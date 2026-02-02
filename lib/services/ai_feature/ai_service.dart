import 'dart:io';

import 'package:diplomka/model/ai_response.dart';

abstract class AiService {
  Future<AiResponse?> generateResponse({
    List<File>? imageFiles,
    String? textPrompt,
  });
}
