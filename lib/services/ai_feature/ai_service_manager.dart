
import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/services/ai_feature/gemini_service.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:get/get.dart';

// Enum for AI Service Provider Type
enum AiServiceProviderType {
  openAI,
  gemini,
}

// GetX Controller to manage AI service selection and registration
class AiServiceManager extends GetxController {
  static AiServiceManager get to => Get.find();

  final Rx<AiServiceProviderType> currentServiceType = AiServiceProviderType.openAI.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the AiService binding and update it when the type changes
    _updateAiServiceBinding(currentServiceType.value);
    // Listen to changes in currentServiceType to update the AiService registration
    ever(currentServiceType, _updateAiServiceBinding);
  }

  // Updates the registered AiService instance based on the current type.
  void _updateAiServiceBinding(AiServiceProviderType type) {
    final AiService newService = (type == AiServiceProviderType.gemini)
        ? GeminiService()
        : OpenAiService();

    if (Get.isRegistered<AiService>()) {
      Get.replace<AiService>(newService);
    } else {
      // Use permanent: true if this service should live throughout the app's lifecycle
      Get.put<AiService>(newService, permanent: true);
    }
  }

  // Switches the AI service provider type.
  void switchService(AiServiceProviderType type) {
    currentServiceType.value = type;
  }
}
