import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {

  SettingsState({
    this.useDyslexiaFont = true, // Default to true as per user's focus
  });
  final bool useDyslexiaFont;

  SettingsState copyWith({
    bool? useDyslexiaFont,
  }) => SettingsState(
      useDyslexiaFont: useDyslexiaFont ?? this.useDyslexiaFont,
    );
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => SettingsState();

  void toggleDyslexiaFont() {
    state = state.copyWith(useDyslexiaFont: !state.useDyslexiaFont);
  }

  void setDyslexiaFont(bool value) {
    state = state.copyWith(useDyslexiaFont: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
