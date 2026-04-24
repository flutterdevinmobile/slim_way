import 'package:slim_way_client/slim_way_client.dart';

class UserUtils {
  /// Calculates the daily calorie limit based on the user's profile and goals.
  static double calculateCalorieLimit(User user) {
    // Revised Mifflin-St Jeor Equation
    double bmr = (10 * user.currentWeight) + (6.25 * user.height) - (5 * user.age);
    
    if (user.gender.toLowerCase() == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    
    // Low activity multiplier (default for baseline)
    double tdee = bmr * 1.2;
    
    // Goal adjustment
    if (user.targetWeight < user.currentWeight) {
      return tdee - 500.0; // Deficit for weight loss
    } else if (user.targetWeight > user.currentWeight) {
      return tdee + 300.0; // Surplus for weight gain
    }
    
    return tdee; // Maintenance
  }
}
