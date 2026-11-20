import 'package:flutter_test/flutter_test.dart';
import 'package:tikvply/core/constants/app_strings.dart';

void main() {
  test('uses the approved user-facing product name', () {
    expect(AppStrings.appName, 'Plytired video');
  });
}
