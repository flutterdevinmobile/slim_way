part of 'navigation_bloc.dart';

sealed class NavigationState extends Equatable {
  final int selectedIndex;
  const NavigationState({this.selectedIndex = 0});
  @override
  List<Object?> get props => [selectedIndex];
}

final class NavigationInitial extends NavigationState {
  const NavigationInitial({super.selectedIndex = 0});
}

final class NavigationSelected extends NavigationState {
  const NavigationSelected({required super.selectedIndex});
}
