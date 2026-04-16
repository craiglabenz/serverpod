/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

/// Exception thrown when attempting to merge accounts and the merge fails.
abstract class AccountMergeFailedException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  AccountMergeFailedException._({
    required this.userToKeepId,
    required this.userToRemoveId,
  });

  factory AccountMergeFailedException({
    required _i1.UuidValue userToKeepId,
    required _i1.UuidValue userToRemoveId,
  }) = _AccountMergeFailedExceptionImpl;

  factory AccountMergeFailedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AccountMergeFailedException(
      userToKeepId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['userToKeepId'],
      ),
      userToRemoveId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['userToRemoveId'],
      ),
    );
  }

  _i1.UuidValue userToKeepId;

  _i1.UuidValue userToRemoveId;

  /// Returns a shallow copy of this [AccountMergeFailedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountMergeFailedException copyWith({
    _i1.UuidValue? userToKeepId,
    _i1.UuidValue? userToRemoveId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_idp.AccountMergeFailedException',
      'userToKeepId': userToKeepId.toJson(),
      'userToRemoveId': userToRemoveId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_auth_idp.AccountMergeFailedException',
      'userToKeepId': userToKeepId.toJson(),
      'userToRemoveId': userToRemoveId.toJson(),
    };
  }

  @override
  String toString() {
    return 'AccountMergeFailedException(userToKeepId: $userToKeepId, userToRemoveId: $userToRemoveId)';
  }
}

class _AccountMergeFailedExceptionImpl extends AccountMergeFailedException {
  _AccountMergeFailedExceptionImpl({
    required _i1.UuidValue userToKeepId,
    required _i1.UuidValue userToRemoveId,
  }) : super._(
         userToKeepId: userToKeepId,
         userToRemoveId: userToRemoveId,
       );

  /// Returns a shallow copy of this [AccountMergeFailedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountMergeFailedException copyWith({
    _i1.UuidValue? userToKeepId,
    _i1.UuidValue? userToRemoveId,
  }) {
    return AccountMergeFailedException(
      userToKeepId: userToKeepId ?? this.userToKeepId,
      userToRemoveId: userToRemoveId ?? this.userToRemoveId,
    );
  }
}
