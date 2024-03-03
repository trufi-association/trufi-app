import 'package:flutter/material.dart';
import 'package:async_executor/async_executor.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:trufi_core/base/widgets/alerts/fetch_error_handler.dart';

import 'package:trufi_core/base/widgets/screen/screen_helpers.dart';

AsyncExecutor customAsyncExecutor = AsyncExecutor(
  loadingMessage: (
    BuildContext context,
  ) async {
    return await showTrufiDialog(
      context: context,
      barrierDismissible: false,
      onWillPop: false,
      builder: (context) {
        return const FlareActor(
          "assets/images/loading.flr",
          animation: "Trufi Drive",
        );
      },
    );
  },
  errorMessage: (BuildContext context, dynamic error) async {
    return await onFetchError(context, error);
  },
);
