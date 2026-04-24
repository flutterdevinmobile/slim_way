import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    on<SettingsInitRequested>(_onInitRequested);
    on<ThemeToggled>(_onThemeToggled);
    on<LocaleChanged>(_onLocaleChanged);
  }

  void _onInitRequested(SettingsInitRequested event, Emitter<SettingsState> emit) {
    final box = Hive.box('auth_box');
    final mode = box.get('theme_mode', defaultValue: 'dark');
    final locale = box.get('locale', defaultValue: 'uz');

    emit(SettingsSuccess(
      themeMode: mode == 'light' ? ThemeMode.light : ThemeMode.dark,
      locale: locale,
    ));
  }

  void _onThemeToggled(ThemeToggled event, Emitter<SettingsState> emit) {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final box = Hive.box('auth_box');
    box.put('theme_mode', newMode == ThemeMode.light ? 'light' : 'dark');
    emit(SettingsSuccess(themeMode: newMode, locale: state.locale));
  }

  void _onLocaleChanged(LocaleChanged event, Emitter<SettingsState> emit) {
    final box = Hive.box('auth_box');
    box.put('locale', event.locale);
    emit(SettingsSuccess(themeMode: state.themeMode, locale: event.locale));
  }
}
