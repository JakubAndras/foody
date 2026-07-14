class OpenAiUsage {
  final int promptTokens;
  final int completionTokens;
  final int cachedTokens;

  const OpenAiUsage({
    required this.promptTokens,
    required this.completionTokens,
    this.cachedTokens = 0,
  });

  static OpenAiUsage? fromResponse(Map<String, dynamic>? data) {
    if (data == null) return null;
    final usage = data['usage'];
    if (usage is! Map) return null;
    final cached = (usage['prompt_tokens_details'] is Map) ? (usage['prompt_tokens_details']['cached_tokens'] as num? ?? 0).toInt() : 0;
    return OpenAiUsage(
      promptTokens: (usage['prompt_tokens'] as num? ?? 0).toInt(),
      completionTokens: (usage['completion_tokens'] as num? ?? 0).toInt(),
      cachedTokens: cached,
    );
  }
}
