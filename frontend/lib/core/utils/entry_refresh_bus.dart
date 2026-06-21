import 'package:flutter/foundation.dart';

final ValueNotifier<int> entryRefreshBus = ValueNotifier<int>(0);

void notifyEntriesChanged() {
  entryRefreshBus.value++;
}
