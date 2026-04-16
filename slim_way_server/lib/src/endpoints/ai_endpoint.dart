import 'dart:convert';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiEndpoint extends Endpoint {
  Future<AiAnalysisResult> analyzeFoodImage(
    Session session,
    ByteData imageData, {
    String? customPrompt,
  }) async {
    final apiKey = session.passwords['googleAiApiKey'];

    if (apiKey == null || apiKey == 'YOUR_KEY_HERE' || apiKey.isEmpty) {
      return AiAnalysisResult(
        nameUz: "Mockup Ovqat (Kalit yo'q)",
        nameEn: "Mockup Food (No API Key)",
        nameRu: "Mockup Еда (Нет ключа)",
        calories: 250.0,
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
      );

      final systemPrompt =
          "Analyze this food image as a professional clinical nutritionist. "
          "Identify the dish, estimate the portion size, and calculate total calories, protein, carbs, and fats with high precision. "
          "${customPrompt != null && customPrompt.isNotEmpty ? "The user provided this description: '$customPrompt'. Use it for better context." : ""}"
          "If the image is not food, respond with nameUz 'Noma'lum' and 0 calories. "
          "Respond ONLY with a valid JSON in this format: "
          "{\"nameUz\": \"Ovqat nomi (UZ)\", \"nameEn\": \"Food name (EN)\", \"nameRu\": \"Название (RU)\", \"calories\": 450, \"protein\": 15.5, \"carbs\": 40.2, \"fats\": 10.1}";

      final content = [
        Content.multi([
          TextPart(systemPrompt),
          DataPart('image/jpeg', imageData.buffer.asUint8List()),
        ]),
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      if (text == null || text.isEmpty) throw Exception("Empty AI response");

      final cleanedContent = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonMatch = RegExp(r'\{[^{}]*\}').firstMatch(cleanedContent);
      if (jsonMatch == null) throw Exception("No JSON in response");

      final Map<String, dynamic> resultJson = jsonDecode(jsonMatch.group(0)!);

      return AiAnalysisResult(
        nameUz: resultJson['nameUz'] as String? ?? "Noma'lum",
        nameEn: resultJson['nameEn'] as String? ?? "Unknown",
        nameRu: resultJson['nameRu'] as String? ?? "Неизвестно",
        calories: (resultJson['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (resultJson['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (resultJson['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (resultJson['fats'] as num?)?.toDouble() ?? (resultJson['fat'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      session.log("Error analyzing food image: $e", level: LogLevel.error);
      return AiAnalysisResult(nameUz: "Xatolik", nameEn: "Error", nameRu: "Ошибка", calories: 0.0, protein: 0, fat: 0, carbs: 0);
    }
  }

  Future<String> chatWithAi(
    Session session,
    List<String> history,
    String message,
  ) async {
    final apiKey = session.passwords['googleAiApiKey'];
    if (apiKey == null || apiKey.isEmpty) return "AI Key missing.";

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
      );

      final chatSessionHistory = history.map((line) {
        if (line.startsWith('User: ')) {
          return Content.text(line.replaceFirst('User: ', ''));
        } else if (line.startsWith('AI: ')) {
          return Content.model([TextPart(line.replaceFirst('AI: ', ''))]);
        }
        return Content.text(line);
      }).toList();

      final chat = model.startChat(history: chatSessionHistory);
      
      final systemPrompt = "You are SlimWay AI, an elite health and nutrition coach. "
          "You are professional, encouraging, and data-driven. "
          "Provide concise, actionable advice. If the user mentions health issues, always advise consulting a doctor.";

      final response = await chat.sendMessage(Content.text("$systemPrompt\n\nUser: $message"));
      return response.text ?? "I'm processing...";
    } catch (e) {
      session.log("Chat Error: $e", level: LogLevel.error);
      return "Technical issues. Please try again.";
    }
  }
}
