import 'package:flutter/foundation.dart';

// Shared state for the light bulb to synchronize between HomePage and DetailPage
final ValueNotifier<bool> globalLightStateNotifier = ValueNotifier<bool>(false);
