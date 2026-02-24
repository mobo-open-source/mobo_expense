import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_expenses/features/profile/pages/profile_screen.dart';
import 'package:mobo_expenses/features/profile/widgets/profile_header_card.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/profile_wrapper.dart';
import '../mocks/mock_provider.dart';

void main() {
  late MockProfileProvider profileProvider;
  late MockSessionService sessionService;
  setUp(() {
    profileProvider = MockProfileProvider();
    sessionService = MockSessionService();
    registerFallbackValue(FakeBuildContext());
    when(() => profileProvider.isLoading).thenReturn(false);
    when(() => profileProvider.hasInternet).thenReturn(false);
    when(() => profileProvider.initialize()).thenAnswer((_) async {});
    when(() => profileProvider.normalizeForEdit(any())).thenReturn('Developer');
    when(() => profileProvider.userAvatar).thenReturn(null);

    when(() => profileProvider.userData).thenReturn({
      'name': "fake name",
      'email': "fake@gmail.com",
      'function': 'developer',
    });
  });

  testWidgets("ProfileScreen renders without crashing", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      profileWrapper(
        child: ProfileScreen(),
        profileProvider: profileProvider,
        sessionService: sessionService,
      ),
    );
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Configuration'), findsOneWidget);
  });

  testWidgets("Profile Configuration screen", (WidgetTester tester) async {
    await tester.pumpWidget(
      profileWrapper(
        child: ProfileScreen(),
        profileProvider: profileProvider,
        sessionService: sessionService,
      ),
    );

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Configuration'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
    expect(find.text('fake name'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Switch Accounts'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.byType(ProfileHeaderCard), findsOneWidget);
  });

  testWidgets("profile detail screen", (WidgetTester tester) async {
    when(
      () => profileProvider.formatAddress(any()),
    ).thenReturn("faked address");
    when(() => profileProvider.hasPendingUpdates).thenReturn(false);
    when(() => profileProvider.loadRelatedCompany()).thenAnswer((_) async {});

    await tester.pumpWidget(
      profileWrapper(
        child: ProfileScreen(),
        profileProvider: profileProvider,
        sessionService: sessionService,
      ),
    );
    expect(find.byType(ProfileHeaderCard), findsOneWidget);

    await tester.tap(find.byType(ProfileHeaderCard));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    ///==>in profile details screen
    expect(find.text("Profile Details"), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('fake name'), findsNWidgets(2));

    final button = find.byKey(Key("button"));
    expect(button, findsOneWidget);
    expect(find.text("Edit"), findsOneWidget);
    expect(find.text("Save"), findsNothing);
    expect(find.text("Cancel"), findsNothing);

    await tester.tap(button);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Save"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
  });

  testWidgets("verify cancel in profile detail screen", (
    WidgetTester tester,
  ) async {
    when(
      () => profileProvider.formatAddress(any()),
    ).thenReturn("faked address");
    when(() => profileProvider.hasPendingUpdates).thenReturn(false);
    when(() => profileProvider.loadRelatedCompany()).thenAnswer((_) async {});

    await tester.pumpWidget(
      profileWrapper(
        child: ProfileScreen(),
        profileProvider: profileProvider,
        sessionService: sessionService,
      ),
    );
    expect(find.byType(ProfileHeaderCard), findsOneWidget);

    await tester.tap(find.byType(ProfileHeaderCard));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    ///==>in profile details screen
    expect(find.text("Profile Details"), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    final button = find.byKey(Key("button"));
    expect(button, findsOneWidget);
    expect(find.text("Edit"), findsOneWidget);
    await tester.tap(button);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Save"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);

    ///cancel

    await tester.tap(find.text("Cancel"));
    await tester.pump(const Duration(seconds: 5));

    expect(find.text("Save"), findsNothing);
  });
  testWidgets("verify save in profile detail screen", (
    WidgetTester tester,
  ) async {
    when(
      () => profileProvider.formatAddress(any()),
    ).thenReturn("faked address");
    when(() => profileProvider.hasPendingUpdates).thenReturn(false);
    when(() => profileProvider.loadRelatedCompany()).thenAnswer((_) async {});
    when(
      () => profileProvider.updateProfileFields(any()),
    ).thenAnswer((_) async {});
    when(
      () => profileProvider.updatePartnerFields(any()),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      profileWrapper(
        child: ProfileScreen(),
        profileProvider: profileProvider,
        sessionService: sessionService,
      ),
    );
    expect(find.byType(ProfileHeaderCard), findsOneWidget);

    await tester.tap(find.byType(ProfileHeaderCard));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));

    ///==>in profile details screen
    expect(find.text("Profile Details"), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    final button = find.byKey(Key("button"));
    expect(button, findsOneWidget);
    expect(find.text("Edit"), findsOneWidget);
    await tester.tap(button);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Save"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);

    ///save===
    await tester.tap(find.text("Save"));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text("Cancel"), findsNothing);
  });
}
