part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String locale;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.locale = 'uz',
  });

  @override
  List<Object?> get props => [themeMode, locale];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial() : super();
}

final class SettingsSuccess extends SettingsState {
  const SettingsSuccess({
    required super.themeMode,
    required super.locale,
  });
}
