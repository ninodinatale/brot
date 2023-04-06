import 'package:cloud_functions/cloud_functions.dart';

import 'models/json_serializable/payload.dart';

final fbFunctionInstance = FirebaseFunctions.instanceFor(region: 'europe-west1');

Future<HttpsCallableResult> callFbFunction<T extends Payload>(String function, [T? data]) {
  return fbFunctionInstance.httpsCallable(function).call(data?.toJson());
}
