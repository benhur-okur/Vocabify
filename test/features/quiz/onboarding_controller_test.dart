test('completes onboarding and persists', () async {
     SharedPreferences.setMockInitialValues({});
     final prefs = await SharedPreferences.getInstance();
     final container = ProviderContainer(overrides: [
       sharedPreferencesProvider.overrideWithValue(prefs),
     ]);
     final ctrl = container.read(onboardingControllerProvider.notifier);
     ctrl.toggleInterest('tech');
     ctrl.toggleMovie('breaking_bad');
     await ctrl.complete();
     expect(container.read(onboardingControllerProvider).isCompleted, true);
   });