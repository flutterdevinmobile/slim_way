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
          "Also, provide a short health tip in Uzbek, English, and Russian on how to make this meal healthier (e.g., 'Use less oil' or 'Add more greens'). "
          "${customPrompt != null && customPrompt.isNotEmpty ? "The user provided this description: '$customPrompt'. Use it for better context." : ""}"
          "If the image is not food, respond with nameUz 'Noma'lum' and 0 calories. "
          "Respond ONLY with a valid JSON in this format: "
          "{\"nameUz\": \"Ovqat nomi\", \"nameEn\": \"Food name\", \"nameRu\": \"Название\", \"calories\": 450, \"protein\": 15.5, \"carbs\": 40.2, \"fats\": 10.1, \"tipsUz\": \"Yashil ko'kat qo'shing\", \"tipsEn\": \"Add more greens\", \"tipsRu\": \"Добавьте зелени\", \"portionSize\": \"300g\"}";

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
        tipsUz: resultJson['tipsUz'] as String?,
        tipsEn: resultJson['tipsEn'] as String?,
        tipsRu: resultJson['tipsRu'] as String?,
        portionSize: resultJson['portionSize'] as String?,
      );

    } catch (e) {
      session.log("Error analyzing food image: $e", level: LogLevel.error);
      return AiAnalysisResult(nameUz: "Xatolik", nameEn: "Error", nameRu: "Ошибка", calories: 0.0, protein: 0, fat: 0, carbs: 0);
    }
  }

  Future<String> chatWithAi(
    Session session,
    List<String> history,
    String message, {
    DailyLog? dailyLog,
  }) async {
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
      
      String contextMsg = "";
      if (dailyLog != null) {
        contextMsg = "\nUSER CONTEXT FOR TODAY:\n"
            "- Calories Consumed: ${dailyLog.foodCal.toInt()} kcal\n"
            "- Protein: ${(dailyLog.protein ?? 0).toInt()}g\n"
            "- Carbs: ${(dailyLog.carbs ?? 0).toInt()}g\n"
            "- Fat: ${(dailyLog.fat ?? 0).toInt()}g\n"
            "- Water Intake: ${dailyLog.waterMl ?? 0}ml\n"
            "- Walk Calories: ${dailyLog.walkCal.toInt()} kcal\n"
            "- Net Calories: ${dailyLog.netCal.toInt()} kcal\n";
      }

      final systemPrompt = "You are SlimWay AI, an elite health and nutrition coach. "
          "You are professional, encouraging, and data-driven. "
          "Provide concise, actionable advice. If the user mentions health issues, always advise consulting a doctor. $contextMsg";

      final response = await chat.sendMessage(Content.text("User: $message\n\n(System Note: Use the provided context if relevant: $systemPrompt)"));
      return response.text ?? "I'm processing...";
    } catch (e) {
      session.log("Chat Error: $e", level: LogLevel.error);
      return "Technical issues. Please try again.";
    }
  }

}
