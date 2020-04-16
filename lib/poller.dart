import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'data.dart';
import 'misc.dart';
import 'rest_client.dart';

class Poller {
  static Timer pollingTimer;
  static AppLifecycleState appLifecycleState;
  static double backoffTime = 10.0;
  static String lastExplicitRefreshError;
  static Random _random = Random();

  static void startPollingTimerIfNotRunning() {
    if (pollingTimer == null) {
      pollingTimer = Timer.periodic(Duration(seconds: 2), (t) {
        timerTick();
      });
    }
  }

  static bool isInForeground() {
    return (appLifecycleState == null ||
        appLifecycleState.index == null ||
        appLifecycleState.index == 0);
  }

  static void setLastRefreshError(APICallException e) {
    debugPrint("setLastRefreshError $e");
    if (e == null) {
      lastExplicitRefreshError = null;
    } else {
      lastExplicitRefreshError = e.cause;
    }
  }

  static void timerTick() async {
    int tokenValidSeconds = TokenWrapper.tokenValidSeconds(TokenWrapper.token);
    if (tokenValidSeconds == null) {
      debugPrint("Token invalid, skipping tick.");
      return;
    }
    debugPrint("TOKEN VALID FOR: $tokenValidSeconds s");
    if (tokenValidSeconds < REFRESH_TOKEN_BEFORE) {
      TokenWrapper.maybeTryToRefresh();
      return;
    }

    bool inForeground = isInForeground();
    debugPrint("Timer tick, inForeground: $inForeground");
    if (inForeground) {
      Data.maybePollAndThen(backoffTime, (e) {
        // Only clear up the bar when we manage to fetch data after it
        // previously failed manually, but don't spam this with auto-refresh
        // failures.
        if (e == null) {
          debugPrint("Poll successful.");
          setLastRefreshError(e);
          backoffTime = STALENESS_LIMIT_MS;
        } else {
          debugPrint("Poll failed.");
          backoffTime =
              backoffTime * 3 + (backoffTime * _random.nextInt(100) * 0.01);
        }
        //setState(() {});
      });
    }
  }
}
