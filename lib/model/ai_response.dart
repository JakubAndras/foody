import 'package:json_annotation/json_annotation.dart';

part 'ai_response.g.dart';
part 'answer.dart';
part 'ingredient_response.dart';
part 'nutritional_values.dart';

@JsonSerializable()
class AiResponse {
  final bool valid;
  final Answer answer;

  AiResponse({required this.valid, required this.answer});

  factory AiResponse.fromJson(Map<String, dynamic> json) => _$AiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AiResponseToJson(this);
}
