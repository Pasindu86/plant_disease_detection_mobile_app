import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> globalRouteObserver = RouteObserver<ModalRoute<void>>();
final ValueNotifier<bool> showAiAssistant = ValueNotifier<bool>(false);
