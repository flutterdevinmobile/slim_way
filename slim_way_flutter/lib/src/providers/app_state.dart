import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:slim_way_client/slim_way_client.dart';
import '../../main.dart' as main;
import 'package:pedometer/pedometer.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/notification_service.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  User? _currentUser;
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _sessionInitialized = false;
  bool _initializationError = false;

  bool get sessionInitialized => _sessionInitialized;
  bool get initializationError => _initializationError;
  bool get isSyncing => _isSyncing;
  bool get isLoading => _isLoading;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  set selectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
  
  // Theme & Localization
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  String _locale = 'uz';
  String get locale => _locale;

  // Chat History
  List<String> _chatHistory = [];
  List<String> get chatHistory => _chatHistory;

  // Real-time Data
  DailyLog? _todayLog;
  DailyLog? get todayLog => _todayLog;
  List<Food> _todayFoods = [];
  List<Food> get todayFoods => _todayFoods;
  
  List<DailyLog> _weeklyStats = [];
  List<WeeklyWeight> _weightHistory = [];
  List<DailyLog> get weeklyStats => _weeklyStats;
  List<WeeklyWeight> get weightHistory => _weightHistory;

  AppState() {
    _initSession();
    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen for live notification actions
    NotificationService.waterUpdateStream.listen((ml) {
      print('Real-time Water Update Received: $ml ml');
      addWater(ml);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App Resumed: Refreshing status...');
      fetchDailySummary();
    }
  }

  int _unsyncedSteps = 0;

  void _loadSettings() {
    final box = Hive.box('auth_box');
    final mode = box.get('theme_mode', defaultValue: 'dark');
    _themeMode = mode == 'light' ? ThemeMode.light : ThemeMode.dark;
    _locale = box.get('locale', defaultValue: 'uz');
    _unsyncedSteps = box.get('unsynced_steps', defaultValue: 0);
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final box = Hive.box('auth_box');
    box.put('theme_mode', _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  void setLocale(String langCode) {
    _locale = langCode;
    final box = Hive.box('auth_box');
    box.put('locale', langCode);
    notifyListeners();
  }

  Future<void> _initSession() async {
    try {
      _initializationError = false;
      if (main.sessionManager.isSignedIn) {
        final userInfo = main.sessionManager.signedInUser;
        if (userInfo != null) {
          await fetchUserByAuthId(userInfo.id!);
        }
      }
    } catch (e) {
      _initializationError = true;
    } finally {
      _sessionInitialized = true;
      notifyListeners();
    }
  }

  Future<void> retryInit() async {
    _sessionInitialized = false;
    _initializationError = false;
    notifyListeners();
    await _initSession();
  }

  bool get isSignedIn => _sessionInitialized && main.sessionManager.isSignedIn;

  Future<void> fetchUserByAuthId(int authId) async {
    _setSyncing(true);
    try {
      _currentUser = await main.client.user.getUserByAuthId(authId);
      if (_currentUser != null) {
        await Future.wait([
          initPedometer(),
          fetchDailySummary(),
          fetchHistory(),
        ]);
        if (_unsyncedSteps > 0) {
          _syncStepsWithBackend(0);
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _setSyncing(false);
      notifyListeners();
    }
  }

  List<Walk> _todayWalkLogs = [];
  List<Walk> get todayWalkLogs => _todayWalkLogs;

  // Global aggregate of today's steps (pedometer delta + manual entries + previously synced pedometer steps)
  int get totalTodaySteps {
    int dbSteps = 0;
    for (var w in _todayWalkLogs) {
      dbSteps += w.steps;
    }
    // We only add unsynced steps to the total, because synced steps are already in the DB
    int currentUnsynced = _steps - _lastSyncedSteps;
    int totalUnsynced = (currentUnsynced > 0 ? currentUnsynced : 0) + _unsyncedSteps;
    return dbSteps + totalUnsynced;
  }

  Future<void> fetchDailySummary() async {
    if (_currentUser == null) return;
    _setSyncing(true);
    try {
      final now = DateTime.now();
      final localStartOfDay = DateTime.utc(now.year, now.month, now.day);
      
      _todayLog = await main.client.stats.getDailySummary(_currentUser!.id!, localStartOfDay);
      
      // Offline Background Water Sync
      final box = Hive.box('auth_box');
      int unsyncedWater = box.get('unsynced_water_ml', defaultValue: 0);
      if (unsyncedWater > 0) {
        await box.put('unsynced_water_ml', 0); // Clear immediately to avoid loops
        await addWater(unsyncedWater); // Pass as int
      } else {
        if (_todayLog != null) {
          NotificationService.scheduleWaterReminders((_todayLog!.waterMl ?? 0).toInt());
        }
      }

      _todayFoods = await main.client.food.getFoodLogs(_currentUser!.id!, localStartOfDay);
      
      _todayWalkLogs = await main.client.walk.getWalkHistory(
        _currentUser!.id!, 
        localStartOfDay, 
        DateTime.utc(now.year, now.month, now.day, 23, 59, 59)
      );

      notifyListeners();
    } catch (e) {
      print('Error fetching summary: $e');
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> fetchHistory() async {
    if (_currentUser == null) return;
    _setSyncing(true);
    try {
      final stats = await main.client.stats.getHistory(_currentUser!.id!);
      stats.sort((a, b) => a.date.compareTo(b.date));
      _weeklyStats = stats.length > 7 ? stats.sublist(stats.length - 7) : stats;

      final weights = await main.client.weeklyWeight.getWeightHistory(_currentUser!.id!);
      weights.sort((a, b) => a.weekStart.compareTo(b.weekStart));
      _weightHistory = weights;

      notifyListeners();
    } catch (e) {
      print('Error fetching history: $e');
    } finally {
      _setSyncing(false);
    }
  }

  // Pedometer Logic
  int _steps = 0;
  int _initialSteps = -1;
  int _lastSyncedSteps = 0;
  bool _pedometerInitialized = false;
  int get steps => _steps; // Raw session steps

  Future<void> initPedometer() async {
    if (_pedometerInitialized) return;

    if (await Permission.activityRecognition.request().isGranted) {
      Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (_initialSteps == -1) _initialSteps = event.steps;
          int currentDailySteps = event.steps - _initialSteps;
          _steps = currentDailySteps < 0 ? 0 : currentDailySteps;

          int delta = _steps - _lastSyncedSteps;
          if (delta >= 20 || delta < 0) {
             if (delta > 0) {
                _syncStepsWithBackend(delta);
             }
             _lastSyncedSteps = _steps; // reset anyway to prevent wrong sync looping
          }
          notifyListeners();
        },
        onError: (e) => print('Pedometer Error: $e'),
      );
      _pedometerInitialized = true;
    }
  }

  Future<void> _syncStepsWithBackend(int newlyAddedSteps) async {
    if (_currentUser == null) return;
    
    _unsyncedSteps += newlyAddedSteps;
    try {
      final box = Hive.box('auth_box');
      await box.put('unsynced_steps', _unsyncedSteps);
    } catch (_) {}

    if (_unsyncedSteps <= 0) return;

    try {
      final now = DateTime.now();
      await main.client.walk.syncSteps(_currentUser!.id!, _unsyncedSteps, DateTime.utc(now.year, now.month, now.day));
      
      _unsyncedSteps = 0;
      try {
        final box = Hive.box('auth_box');
        await box.put('unsynced_steps', 0);
      } catch (_) {}
      
      await fetchDailySummary(); // Refresh total count from DB
    } catch (e) {
      print('Failed to sync steps (Stored locally for offline): $e');
    }
  }

  // AI & Food Logic
  Future<AiAnalysisResult?> analyzeFoodImage(Uint8List imageBytes, {String? prompt}) async {
    _setLoading(true);
    try {
      final byteData = ByteData.view(imageBytes.buffer);
      return await main.client.ai.analyzeFoodImage(byteData, customPrompt: prompt);
    } catch (e) {
      return null;
    } finally {
      _setLoading(false);
    }
  }

  String getLocalizedFoodName(AiAnalysisResult result) {
    if (_locale == 'uz') return result.nameUz ?? "Noma'lum";
    if (_locale == 'ru') return result.nameRu ?? "Неизвестно";
    return result.nameEn ?? "Unknown";
  }

  Future<void> addFood(Food food, {Uint8List? imageBytes}) async {
    if (_currentUser == null) return;
    try {
      food.userId = _currentUser!.id!;
      if (imageBytes != null) {
        food.photoUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      }
      await main.client.food.addFood(food);
      await fetchDailySummary();
      await fetchHistory();
    } catch (e) {
      print('Error adding food: $e');
    }
  }

  // Water Logic
  Future<void> addWater(int amountMl) async {
    if (_currentUser == null) return;
    
    int finalAmount = amountMl;
    if (finalAmount < 0) {
      int currentWater = _todayLog?.waterMl ?? 0;
      if (currentWater <= 0) return;
      if (currentWater + finalAmount < 0) {
        finalAmount = -currentWater;
      }
    }

    try {
      final now = DateTime.now();
      await main.client.water.addWater(_currentUser!.id!, finalAmount, DateTime.utc(now.year, now.month, now.day));
      await fetchDailySummary();
      
      // Reschedule reminders based on new progress
      if (_todayLog != null) {
        NotificationService.scheduleWaterReminders((_todayLog!.waterMl ?? 0).toInt());
      }
    } catch (e) {
      print('Error adding water: $e');
    }
  }

  Future<void> updateWaterGlassSize(int glassSize) async {
    if (_currentUser == null) return;
    try {
      _currentUser = await main.client.water.updateWaterGlassSize(_currentUser!.id!, glassSize);
      notifyListeners();
    } catch (e) {
      print('Error updating glass size: $e');
    }
  }

  int get waterGlassSize => _currentUser?.waterGlassSize ?? 250;
  
  // Goals (Macros)
  double get dailyProteinGoal => (_currentUser?.currentWeight ?? 70) * 1.5; // Example: 1.5g per kg
  double get dailyFatGoal => dailyCalorieLimit * 0.25 / 9; // 25% of calories
  double get dailyCarbsGoal => (dailyCalorieLimit - (dailyProteinGoal * 4) - (dailyFatGoal * 9)) / 4;

  Future<void> deleteFood(int foodId) async {
    if (_currentUser == null) return;
    try {
      await main.client.food.deleteFood(foodId, _currentUser!.id!);
      await fetchDailySummary();
      await fetchHistory();
    } catch (e) {
      print('Error deleting food: $e');
    }
  }

  Future<void> addWalk(Walk walk) async {
    if (_currentUser == null) return;
    try {
      walk.userId = _currentUser!.id!;
      await main.client.walk.addWalk(walk);
      await fetchDailySummary();
      await fetchHistory();
    } catch (e) {
      print('Error adding walk: $e');
    }
  }

  // Chat logic
  Future<void> sendChatMessage(String message) async {
    _chatHistory.add('User: $message');
    notifyListeners();

    try {
      final response = await main.client.ai.chatWithAi(_chatHistory, message);
      _chatHistory.add('AI: $response');
    } catch (e) {
      _chatHistory.add('AI: Texnik nosozlik yuz berdi. Iltimos qaytadan urinib ko\'ring.');
    } finally {
      notifyListeners();
    }
  }

  User? get currentUser => _currentUser;
  
  double get dailyCalorieLimit {
    if (_currentUser == null) return 2000.0;
    double bmr = (10 * _currentUser!.currentWeight) + (6.25 * _currentUser!.height) - (5 * _currentUser!.age);
    if (_currentUser!.gender.toLowerCase() == 'male') bmr += 5; else bmr -= 161;
    double tdee = bmr * 1.2;
    if (_currentUser!.targetWeight < _currentUser!.currentWeight) return tdee - 500.0;
    if (_currentUser!.targetWeight > _currentUser!.currentWeight) return tdee + 300.0;
    return tdee;
  }

  Future<void> updateUser(User user) async {
    _setLoading(true);
    try {
      _currentUser = await main.client.user.updateUser(user);
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSyncing(bool value) {
    _isSyncing = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await main.sessionManager.signOutDevice();
    _currentUser = null;
    notifyListeners();
  }
}
