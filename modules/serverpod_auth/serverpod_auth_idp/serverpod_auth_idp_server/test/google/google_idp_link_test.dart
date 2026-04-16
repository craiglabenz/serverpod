import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:test/test.dart';

import '../test_tags.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  late MockGoogleIdpUtils utils;
  late Session session;

  final GoogleAccountDetails mockDetails = (
    userIdentifier: 'google-123',
    email: 'test@gmail.com',
    name: 'Test',
    fullName: 'Test User',
    image: Uri.parse('http://image.com'),
    verifiedEmail: true,
  );

  MockGoogleIdpUtils createUtils({
    final AuthUsersConfig authConfig = const AuthUsersConfig(),
    final AccountMergeConfig mergeConfig = const AccountMergeConfig(),
  }) {
    return MockGoogleIdpUtils(
      config: GoogleIdpConfig(
        clientSecret: GoogleClientSecret.fromJson({
          'web': {
            'client_id': 'id',
            'client_secret': 'secret',
            'redirect_uris': ['uri'],
          },
        }),
      ),
      authUsers: AuthUsers(config: authConfig),
      accountMerger: AccountMerger(config: mergeConfig),
      mockDetails: mockDetails,
    );
  }

  withServerpod(
    'Given GoogleIdpUtils',
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      setUp(() {
        utils = createUtils();
        session = sessionBuilder.build();
      });

      test(
        'when authenticating with new Google ID and no session then creates '
        'new user',
        () async {
          final result = await utils.authenticate(
            session,
            idToken: 'token',
            accessToken: 'token',
            transaction: null,
          );

          expect(result.newAccount, isTrue);
          expect(result.authUserId, isNotNull);

          final googleAccount = await GoogleAccount.db.findFirstRow(session);
          expect(googleAccount, isNotNull);
          expect(googleAccount?.userIdentifier, mockDetails.userIdentifier);
          expect(googleAccount?.authUserId, result.authUserId);
        },
      );

      test(
        'when authenticating with new Google ID and authenticated session then '
        'links to existing user',
        () async {
          // Create user A
          final authUser = await const AuthUsers().create(session);
          final authenticatedSession = sessionBuilder
              .copyWith(
                authentication: AuthenticationOverride.authenticationInfo(
                  authUser.id.toString(),
                  {},
                ),
              )
              .build();

          final result = await utils.authenticate(
            authenticatedSession,
            idToken: 'token',
            accessToken: 'token',
            transaction: null,
          );

          // Google Account is new, but AuthUser is not new
          expect(result.newAccount, isFalse);
          // Linked to session user
          expect(result.authUserId, authUser.id);

          final googleAccount = await GoogleAccount.db.findFirstRow(session);
          expect(googleAccount?.authUserId, authUser.id);
        },
      );

      test(
        'when authenticating with existing Google ID linked to current user '
        'then returns success',
        () async {
          // Create user A and link Google
          final authUser = await const AuthUsers().create(session);
          await GoogleAccount.db.insertRow(
            session,
            GoogleAccount(
              userIdentifier: mockDetails.userIdentifier,
              email: mockDetails.email,
              authUserId: authUser.id,
            ),
          );

          final authenticatedSession = sessionBuilder
              .copyWith(
                authentication: AuthenticationOverride.authenticationInfo(
                  authUser.id.toString(),
                  {},
                ),
              )
              .build();

          final result = await utils.authenticate(
            authenticatedSession,
            idToken: 'token',
            accessToken: 'token',
            transaction: null,
          );

          expect(result.newAccount, isFalse);
          expect(result.authUserId, authUser.id);
        },
      );

      test(
        'when authenticating with existing Google ID linked to OTHER user then '
        'throws AccountAlreadyLinkedException',
        () async {
          // Create user B and link Google
          final otherUser = await const AuthUsers().create(session);
          await GoogleAccount.db.insertRow(
            session,
            GoogleAccount(
              userIdentifier: mockDetails.userIdentifier,
              email: mockDetails.email,
              authUserId: otherUser.id,
            ),
          );

          // Authenticate as User A
          final currentUser = await const AuthUsers().create(session);
          final authenticatedSession = sessionBuilder
              .copyWith(
                authentication: AuthenticationOverride.authenticationInfo(
                  currentUser.id.toString(),
                  {},
                ),
              )
              .build();

          expect(
            () => utils.authenticate(
              authenticatedSession,
              idToken: 'token',
              accessToken: 'token',
              transaction: null,
            ),
            throwsA(isA<AccountAlreadyLinkedException>()),
          );
        },
      );

      test(
        'when authenticating with conflict and merge callback defined then '
        'merges and links to current user',
        () async {
          // Create user B (original owner of Google Account)
          final originalUser = await const AuthUsers().create(session);
          await GoogleAccount.db.insertRow(
            session,
            GoogleAccount(
              userIdentifier: mockDetails.userIdentifier,
              email: mockDetails.email,
              authUserId: originalUser.id,
            ),
          );

          // Authenticate as User A (target user)
          final targetUser = await const AuthUsers().create(session);
          final authenticatedSession = sessionBuilder
              .copyWith(
                authentication: AuthenticationOverride.authenticationInfo(
                  targetUser.id.toString(),
                  {},
                ),
              )
              .build();

          bool mergeCalled = false;
          utils = createUtils(
            mergeConfig: AccountMergeConfig(
              applicationMergeHandler:
                  (
                    final session, {
                    required final UuidValue userToKeepId,
                    required final UuidValue userToRemoveId,
                    required final Transaction transaction,
                  }) async {
                    mergeCalled = true;
                    expect(userToRemoveId, originalUser.id);
                    expect(userToKeepId, targetUser.id);
                  },
            ),
          );

          final result = await utils.authenticate(
            authenticatedSession,
            idToken: 'token',
            accessToken: 'token',
            transaction: null,
          );

          expect(mergeCalled, isTrue);
          expect(result.authUserId, targetUser.id);

          final googleAccount = await GoogleAccount.db.findFirstRow(session);
          expect(googleAccount?.authUserId, targetUser.id);
        },
      );
    },
  );
}

class MockGoogleIdpUtils extends GoogleIdpUtils {
  final GoogleAccountDetails mockDetails;

  MockGoogleIdpUtils({
    required super.config,
    required super.authUsers,
    required super.accountMerger,
    required this.mockDetails,
  });

  @override
  Future<GoogleAccountDetails> fetchAccountDetails(
    final Session session, {
    required final String idToken,
    required final String? accessToken,
  }) async {
    return mockDetails;
  }
}
