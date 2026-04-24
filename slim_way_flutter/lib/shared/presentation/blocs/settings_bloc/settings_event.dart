part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsInitRequested extends SettingsEvent {}

class ThemeToggled extends SettingsEvent {}

class LocaleChanged extends SettingsEvent {
  final String locale;
  const LocaleChanged(this.locale);
  @override
  List<Object?> get props => [locale];
}
