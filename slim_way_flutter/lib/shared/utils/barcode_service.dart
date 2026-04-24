import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BarcodeProduct {
  final String name;
  final double calories; // per 100g
  final double protein;
  final double fat;
  final double carbs;
  final String? imageUrl;

  BarcodeProduct({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.imageUrl,
  });
}

class BarcodeService {
  static Future<BarcodeProduct?> getProductByBarcode(String barcode) async {
    debugPrint('DEBUG: Scanning Barcode: $barcode');
    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    
    try {
      final response = await http.get(url);
      debugPrint('DEBUG: API Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 || data['status'] == "found") {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};
          
          // Try multiple names
          String name = product['product_name'] ?? 
                       product['product_name_en'] ?? 
                       product['product_name_uz'] ??
                       'Unknown Product ($barcode)';
          
          // Try multiple calorie fields
          double calories = (nutriments['energy-kcal_100g'] ?? 
                             nutriments['energy-kcal'] ?? 
                             nutriments['energy_100g'] ?? 0.0).toDouble();
          
          // If energy is in kJ (energy_100g), it needs to be converted if calories is 0
          if (calories > 500 && nutriments['energy-kcal_100g'] == null) {
              // Likely kJ, convert to kcal (1 kcal = 4.184 kJ)
              calories = calories / 4.184;
          }

          final result = BarcodeProduct(
            name: name,
            calories: calories,
            protein: (nutriments['proteins_100g'] ?? nutriments['proteins'] ?? 0.0).toDouble(),
            fat: (nutriments['fat_100g'] ?? nutriments['fat'] ?? 0.0).toDouble(),
            carbs: (nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates'] ?? 0.0).toDouble(),
            imageUrl: product['image_url'] ?? product['image_front_url'],
          );

          debugPrint('DEBUG: Product found: ${result.name}');
          return result;
        } else {
          debugPrint('DEBUG: Product not found in Open Food Facts database');
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Barcode Service Error: $e');
    }
    return null;
  }
}
