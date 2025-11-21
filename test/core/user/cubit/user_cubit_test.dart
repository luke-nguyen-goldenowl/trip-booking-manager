import 'package:bloc_test/bloc_test.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/models/user_model.dart';
import 'package:bus_ticket_app/models/result_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:typed_data';
import 'user_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserService>()])
void main() {
  late UserCubit userCubit;
  late MockUserService mockUserService;

  final testUser = MUser(
    id: 1,
    email: 'test@example.com',
    fullName: 'Test User',
    phone: '0123456789',
    role: 'Khách hàng',
    createdAt: DateTime(2024, 1, 1),
    avatarUrl: 'https://example.com/avatar.jpg',
  );

  final updatedUser = MUser(
    id: 1,
    email: 'test@example.com',
    fullName: 'Updated User',
    phone: '0987654321',
    role: 'Khách hàng',
    createdAt: DateTime(2024, 1, 1),
    avatarUrl: 'https://example.com/avatar.jpg',
  );

  setUp(() {
    mockUserService = MockUserService();
    userCubit = UserCubit(mockUserService);
  });

  tearDown(() {
    userCubit.close();
  });

  group('loadUser', () {
    test('initial state is UserInitial', () {
      expect(userCubit.state, isA<UserInitial>());
    });

    blocTest<UserCubit, UserState>(
      'emits [UserLoading, UserLoaded] when loadUser is successful',
      build: () {
        when(
          mockUserService.getUserInfo(any),
        ).thenAnswer((_) async => MResult.success(testUser));
        return userCubit;
      },
      act: (cubit) => cubit.loadUser('test@example.com'),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserLoaded>()
                .having((state) => state.user.email, 'email', testUser.email)
                .having(
                  (state) => state.user.fullName,
                  'fullName',
                  testUser.fullName,
                ),
          ],
      verify: (_) {
        verify(mockUserService.getUserInfo('test@example.com')).called(1);
      },
    );

    blocTest<UserCubit, UserState>(
      'emits [UserLoading, UserError] when user not found',
      build: () {
        when(mockUserService.getUserInfo(any)).thenAnswer(
          (_) async => MResult.error('Không tìm thấy thông tin người dùng'),
        );
        return userCubit;
      },
      act: (cubit) => cubit.loadUser('notfound@example.com'),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserError>().having(
              (state) => state.message,
              'message',
              'Không tìm thấy thông tin người dùng',
            ),
          ],
    );

    blocTest<UserCubit, UserState>(
      'emits [UserLoading, UserError] when service throws exception',
      build: () {
        when(mockUserService.getUserInfo(any)).thenAnswer(
          (_) async => MResult.exception(Exception('Network error')),
        );
        return userCubit;
      },
      act: (cubit) => cubit.loadUser('test@example.com'),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserError>().having(
              (state) => state.message,
              'message',
              contains('Network error'),
            ),
          ],
    );
  });

  group('loadAllUser', () {
    final testUsers = [
      testUser,
      MUser(
        id: 2,
        email: 'user2@example.com',
        fullName: 'User 2',
        phone: '0111111111',
        role: 'Admin',
        createdAt: DateTime(2024, 1, 2),
      ),
    ];

    blocTest<UserCubit, UserState>(
      'emits [UserLoading, MultiUserLoaded] when loadAllUser is successful',
      build: () {
        when(
          mockUserService.getAllUsers(),
        ).thenAnswer((_) async => MResult.success(testUsers));
        return userCubit;
      },
      act: (cubit) => cubit.loadAllUser(),
      expect:
          () => [
            isA<UserLoading>(),
            isA<MultiUserLoaded>()
                .having((state) => state.users.length, 'users length', 2)
                .having(
                  (state) => state.users[0].email,
                  'first user email',
                  testUsers[0].email,
                ),
          ],
      verify: (_) {
        verify(mockUserService.getAllUsers()).called(1);
      },
    );

    blocTest<UserCubit, UserState>(
      'emits [UserLoading, UserError] when loadAllUser fails',
      build: () {
        when(mockUserService.getAllUsers()).thenAnswer(
          (_) async => MResult.exception(Exception('Failed to load users')),
        );
        return userCubit;
      },
      act: (cubit) => cubit.loadAllUser(),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserError>().having(
              (state) => state.message,
              'message',
              contains('Failed to load users'),
            ),
          ],
    );
  });

  group('updateUserProfile', () {
    final updateData = {'full_name': 'Updated User', 'phone': '0987654321'};

    blocTest<UserCubit, UserState>(
      'does nothing when current state is not UserLoaded',
      build: () => userCubit,
      act: (cubit) => cubit.updateUserProfile(updateData),
      expect: () => [],
      verify: (_) {
        verifyNever(mockUserService.updateUserProfile(any, any));
      },
    );

    blocTest<UserCubit, UserState>(
      'updates profile successfully when state is UserLoaded',
      build: () {
        when(
          mockUserService.getUserInfo(any),
        ).thenAnswer((_) async => MResult.success(updatedUser));
        when(
          mockUserService.updateUserProfile(any, any),
        ).thenAnswer((_) async => MResult.success(null));
        return userCubit;
      },
      seed: () => UserLoaded(testUser),
      act: (cubit) => cubit.updateUserProfile(updateData),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserLoaded>()
                .having(
                  (state) => state.user.fullName,
                  'fullName',
                  'Updated User',
                )
                .having((state) => state.user.phone, 'phone', '0987654321'),
          ],
      verify: (_) {
        verify(
          mockUserService.updateUserProfile(testUser.email!, updateData),
        ).called(1);
        verify(mockUserService.getUserInfo(testUser.email!)).called(1);
      },
    );

    blocTest<UserCubit, UserState>(
      'emits UserError when update fails',
      build: () {
        when(mockUserService.updateUserProfile(any, any)).thenAnswer(
          (_) async => MResult.exception(Exception('Update failed')),
        );
        return userCubit;
      },
      seed: () => UserLoaded(testUser),
      act: (cubit) => cubit.updateUserProfile(updateData),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserError>().having(
              (state) => state.message,
              'message',
              contains('Update failed'),
            ),
          ],
    );

    blocTest<UserCubit, UserState>(
      'validates empty data - should still update',
      build: () {
        when(
          mockUserService.updateUserProfile(any, any),
        ).thenAnswer((_) async => MResult.success(null));
        when(
          mockUserService.getUserInfo(any),
        ).thenAnswer((_) async => MResult.success(testUser));
        return userCubit;
      },
      seed: () => UserLoaded(testUser),
      act: (cubit) => cubit.updateUserProfile({}),
      expect: () => [isA<UserLoading>(), isA<UserLoaded>()],
    );

    blocTest<UserCubit, UserState>(
      'handles null email - throws error',
      build: () => userCubit,
      seed:
          () => UserLoaded(
            MUser(id: 1, fullName: 'Test User', role: 'Khách hàng'),
          ),
      act: (cubit) => cubit.updateUserProfile(updateData),
      expect: () => [isA<UserLoading>(), isA<UserError>()],
    );
  });

  group('uploadAvatar', () {
    final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    const newAvatarUrl = 'https://example.com/new-avatar.jpg';

    blocTest<UserCubit, UserState>(
      'does nothing when current state is not UserLoaded',
      build: () => userCubit,
      act: (cubit) => cubit.uploadAvatar(imageBytes),
      expect: () => [],
      verify: (_) {
        verifyNever(mockUserService.uploadAvatar(any, any));
      },
    );

    blocTest<UserCubit, UserState>(
      'uploads avatar successfully - calls loadUser after upload',
      build: () {
        when(
          mockUserService.uploadAvatar(any, any),
        ).thenAnswer((_) async => MResult.success(newAvatarUrl));
        when(mockUserService.getUserInfo(any)).thenAnswer(
          (_) async =>
              MResult.success(testUser.copyWith(avatarUrl: newAvatarUrl)),
        );
        return userCubit;
      },
      seed: () => UserLoaded(testUser),
      act: (cubit) => cubit.uploadAvatar(imageBytes),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserLoading>(),
            isA<UserLoaded>().having(
              (state) => state.user.avatarUrl,
              'avatarUrl',
              newAvatarUrl,
            ),
          ],
      verify: (_) {
        verify(
          mockUserService.uploadAvatar(testUser.email!, imageBytes),
        ).called(1);
        verify(mockUserService.getUserInfo(testUser.email!)).called(1);
      },
    );

    blocTest<UserCubit, UserState>(
      'emits error then reloads user when upload fails',
      build: () {
        when(mockUserService.uploadAvatar(any, any)).thenAnswer(
          (_) async => MResult.exception(Exception('Upload failed')),
        );
        when(
          mockUserService.getUserInfo(any),
        ).thenAnswer((_) async => MResult.success(testUser));
        return userCubit;
      },
      seed: () => UserLoaded(testUser),
      act: (cubit) => cubit.uploadAvatar(imageBytes),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserError>().having(
              (state) => state.message,
              'message',
              contains('Upload failed'),
            ),
            isA<UserLoading>(),
            isA<UserLoaded>(),
          ],
      verify: (_) {
        verify(mockUserService.getUserInfo(testUser.email!)).called(1);
      },
    );

    blocTest<UserCubit, UserState>(
      'emits specific error when both upload and reload fail',
      build: () {
        when(mockUserService.uploadAvatar(any, any)).thenAnswer(
          (_) async => MResult.exception(Exception('Upload failed')),
        );
        when(mockUserService.getUserInfo(any)).thenAnswer(
          (_) async => MResult.exception(Exception('Reload failed')),
        );
        return userCubit;
      },
      seed: () => UserLoaded(testUser),
      act: (cubit) => cubit.uploadAvatar(imageBytes),
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserError>().having(
              (state) => state.message,
              'message',
              contains('Upload failed'),
            ),
            isA<UserLoading>(),
            isA<UserError>().having(
              (state) => state.message,
              'message',
              contains('Reload failed'),
            ),
          ],
    );
  });

  group('Edge cases and validations', () {
    blocTest<UserCubit, UserState>(
      'handles multiple sequential loadUser calls',
      build: () {
        when(
          mockUserService.getUserInfo(any),
        ).thenAnswer((_) async => MResult.success(testUser));
        return userCubit;
      },
      act: (cubit) async {
        await cubit.loadUser('test@example.com');
        await cubit.loadUser('test@example.com');
      },
      expect:
          () => [
            isA<UserLoading>(),
            isA<UserLoaded>(),
            isA<UserLoading>(),
            isA<UserLoaded>(),
          ],
    );

    blocTest<UserCubit, UserState>(
      'handles updateUserProfile with special characters',
      build: () {
        when(
          mockUserService.updateUserProfile(any, any),
        ).thenAnswer((_) async => MResult.success(null));
        when(
          mockUserService.getUserInfo(any),
        ).thenAnswer((_) async => MResult.success(testUser));
        return userCubit;
      },
      seed: () => UserLoaded(testUser),
      act:
          (cubit) => cubit.updateUserProfile({
            'full_name': 'Nguyễn Văn Á',
            'phone': '+84-123-456-789',
          }),
      expect: () => [isA<UserLoading>(), isA<UserLoaded>()],
    );
  });
}
