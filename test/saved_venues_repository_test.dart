import 'package:brewdesk/data/repositories/saved_venues_repository.dart';
import 'package:brewdesk/data/services/saved_venues_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saved venues persist across repository instances', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SavedVenuesRepository(SavedVenuesService(preferences));

    await repository.toggle('spot-1');

    final restored = SavedVenuesRepository(SavedVenuesService(preferences));
    expect(restored.contains('spot-1'), isTrue);

    await restored.toggle('spot-1');
    expect(restored.ids, isEmpty);
  });
}
