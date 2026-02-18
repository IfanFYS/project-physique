import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class NavigationNotifier extends _$NavigationNotifier {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}
