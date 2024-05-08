// Mocks generated by Mockito 5.4.4 from annotations
// in go_social/test/widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:convert' as _i7;
import 'dart:typed_data' as _i9;

import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'
    as _i3;
import 'package:go_social/main.dart' as _i10;
import 'package:google_maps_webservice/places.dart' as _i5;
import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamedResponse_1 extends _i1.SmartFake
    implements _i2.StreamedResponse {
  _FakeStreamedResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUserMetadata_2 extends _i1.SmartFake implements _i3.UserMetadata {
  _FakeUserMetadata_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMultiFactor_3 extends _i1.SmartFake implements _i4.MultiFactor {
  _FakeMultiFactor_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeIdTokenResult_4 extends _i1.SmartFake implements _i3.IdTokenResult {
  _FakeIdTokenResult_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUserCredential_5 extends _i1.SmartFake
    implements _i4.UserCredential {
  _FakeUserCredential_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeConfirmationResult_6 extends _i1.SmartFake
    implements _i4.ConfirmationResult {
  _FakeConfirmationResult_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUser_7 extends _i1.SmartFake implements _i4.User {
  _FakeUser_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGoogleMapsPlaces_8 extends _i1.SmartFake
    implements _i5.GoogleMapsPlaces {
  _FakeGoogleMapsPlaces_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlacesDetailsResponse_9 extends _i1.SmartFake
    implements _i5.PlacesDetailsResponse {
  _FakePlacesDetailsResponse_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i2.Response> head(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #head,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #head,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> get(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #get,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #post,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #put,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #patch,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i7.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i6.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #delete,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i6.Future<_i2.Response>);

  @override
  _i6.Future<String> read(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<String>.value(_i8.dummyValue<String>(
          this,
          Invocation.method(
            #read,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i6.Future<String>);

  @override
  _i6.Future<_i9.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readBytes,
          [url],
          {#headers: headers},
        ),
        returnValue: _i6.Future<_i9.Uint8List>.value(_i9.Uint8List(0)),
      ) as _i6.Future<_i9.Uint8List>);

  @override
  _i6.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #send,
          [request],
        ),
        returnValue:
            _i6.Future<_i2.StreamedResponse>.value(_FakeStreamedResponse_1(
          this,
          Invocation.method(
            #send,
            [request],
          ),
        )),
      ) as _i6.Future<_i2.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [User].
///
/// See the documentation for Mockito's code generation for more information.
class MockUser extends _i1.Mock implements _i4.User {
  MockUser() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get emailVerified => (super.noSuchMethod(
        Invocation.getter(#emailVerified),
        returnValue: false,
      ) as bool);

  @override
  bool get isAnonymous => (super.noSuchMethod(
        Invocation.getter(#isAnonymous),
        returnValue: false,
      ) as bool);

  @override
  _i3.UserMetadata get metadata => (super.noSuchMethod(
        Invocation.getter(#metadata),
        returnValue: _FakeUserMetadata_2(
          this,
          Invocation.getter(#metadata),
        ),
      ) as _i3.UserMetadata);

  @override
  List<_i3.UserInfo> get providerData => (super.noSuchMethod(
        Invocation.getter(#providerData),
        returnValue: <_i3.UserInfo>[],
      ) as List<_i3.UserInfo>);

  @override
  String get uid => (super.noSuchMethod(
        Invocation.getter(#uid),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.getter(#uid),
        ),
      ) as String);

  @override
  _i4.MultiFactor get multiFactor => (super.noSuchMethod(
        Invocation.getter(#multiFactor),
        returnValue: _FakeMultiFactor_3(
          this,
          Invocation.getter(#multiFactor),
        ),
      ) as _i4.MultiFactor);

  @override
  _i6.Future<void> delete() => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String?> getIdToken([bool? forceRefresh = false]) =>
      (super.noSuchMethod(
        Invocation.method(
          #getIdToken,
          [forceRefresh],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i6.Future<_i3.IdTokenResult> getIdTokenResult(
          [bool? forceRefresh = false]) =>
      (super.noSuchMethod(
        Invocation.method(
          #getIdTokenResult,
          [forceRefresh],
        ),
        returnValue: _i6.Future<_i3.IdTokenResult>.value(_FakeIdTokenResult_4(
          this,
          Invocation.method(
            #getIdTokenResult,
            [forceRefresh],
          ),
        )),
      ) as _i6.Future<_i3.IdTokenResult>);

  @override
  _i6.Future<_i4.UserCredential> linkWithCredential(
          _i3.AuthCredential? credential) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithCredential,
          [credential],
        ),
        returnValue: _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_5(
          this,
          Invocation.method(
            #linkWithCredential,
            [credential],
          ),
        )),
      ) as _i6.Future<_i4.UserCredential>);

  @override
  _i6.Future<_i4.UserCredential> linkWithProvider(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithProvider,
          [provider],
        ),
        returnValue: _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_5(
          this,
          Invocation.method(
            #linkWithProvider,
            [provider],
          ),
        )),
      ) as _i6.Future<_i4.UserCredential>);

  @override
  _i6.Future<_i4.UserCredential> reauthenticateWithProvider(
          _i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithProvider,
          [provider],
        ),
        returnValue: _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_5(
          this,
          Invocation.method(
            #reauthenticateWithProvider,
            [provider],
          ),
        )),
      ) as _i6.Future<_i4.UserCredential>);

  @override
  _i6.Future<_i4.UserCredential> reauthenticateWithPopup(
          _i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithPopup,
          [provider],
        ),
        returnValue: _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_5(
          this,
          Invocation.method(
            #reauthenticateWithPopup,
            [provider],
          ),
        )),
      ) as _i6.Future<_i4.UserCredential>);

  @override
  _i6.Future<void> reauthenticateWithRedirect(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithRedirect,
          [provider],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<_i4.UserCredential> linkWithPopup(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithPopup,
          [provider],
        ),
        returnValue: _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_5(
          this,
          Invocation.method(
            #linkWithPopup,
            [provider],
          ),
        )),
      ) as _i6.Future<_i4.UserCredential>);

  @override
  _i6.Future<void> linkWithRedirect(_i3.AuthProvider? provider) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithRedirect,
          [provider],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<_i4.ConfirmationResult> linkWithPhoneNumber(
    String? phoneNumber, [
    _i4.RecaptchaVerifier? verifier,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #linkWithPhoneNumber,
          [
            phoneNumber,
            verifier,
          ],
        ),
        returnValue:
            _i6.Future<_i4.ConfirmationResult>.value(_FakeConfirmationResult_6(
          this,
          Invocation.method(
            #linkWithPhoneNumber,
            [
              phoneNumber,
              verifier,
            ],
          ),
        )),
      ) as _i6.Future<_i4.ConfirmationResult>);

  @override
  _i6.Future<_i4.UserCredential> reauthenticateWithCredential(
          _i3.AuthCredential? credential) =>
      (super.noSuchMethod(
        Invocation.method(
          #reauthenticateWithCredential,
          [credential],
        ),
        returnValue: _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_5(
          this,
          Invocation.method(
            #reauthenticateWithCredential,
            [credential],
          ),
        )),
      ) as _i6.Future<_i4.UserCredential>);

  @override
  _i6.Future<void> reload() => (super.noSuchMethod(
        Invocation.method(
          #reload,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> sendEmailVerification(
          [_i3.ActionCodeSettings? actionCodeSettings]) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendEmailVerification,
          [actionCodeSettings],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<_i4.User> unlink(String? providerId) => (super.noSuchMethod(
        Invocation.method(
          #unlink,
          [providerId],
        ),
        returnValue: _i6.Future<_i4.User>.value(_FakeUser_7(
          this,
          Invocation.method(
            #unlink,
            [providerId],
          ),
        )),
      ) as _i6.Future<_i4.User>);

  @override
  _i6.Future<void> updateEmail(String? newEmail) => (super.noSuchMethod(
        Invocation.method(
          #updateEmail,
          [newEmail],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> updatePassword(String? newPassword) => (super.noSuchMethod(
        Invocation.method(
          #updatePassword,
          [newPassword],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> updatePhoneNumber(
          _i3.PhoneAuthCredential? phoneCredential) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePhoneNumber,
          [phoneCredential],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> updateDisplayName(String? displayName) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateDisplayName,
          [displayName],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> updatePhotoURL(String? photoURL) => (super.noSuchMethod(
        Invocation.method(
          #updatePhotoURL,
          [photoURL],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateProfile,
          [],
          {
            #displayName: displayName,
            #photoURL: photoURL,
          },
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> verifyBeforeUpdateEmail(
    String? newEmail, [
    _i3.ActionCodeSettings? actionCodeSettings,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #verifyBeforeUpdateEmail,
          [
            newEmail,
            actionCodeSettings,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [SearchService].
///
/// See the documentation for Mockito's code generation for more information.
class MockSearchService extends _i1.Mock implements _i10.SearchService {
  MockSearchService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.GoogleMapsPlaces get places => (super.noSuchMethod(
        Invocation.getter(#places),
        returnValue: _FakeGoogleMapsPlaces_8(
          this,
          Invocation.getter(#places),
        ),
      ) as _i5.GoogleMapsPlaces);

  @override
  _i6.Future<List<_i5.Prediction>> fetchPlaces(String? input) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchPlaces,
          [input],
        ),
        returnValue: _i6.Future<List<_i5.Prediction>>.value(<_i5.Prediction>[]),
      ) as _i6.Future<List<_i5.Prediction>>);

  @override
  _i6.Future<_i5.PlacesDetailsResponse> fetchPlaceDetails(String? placeId) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchPlaceDetails,
          [placeId],
        ),
        returnValue: _i6.Future<_i5.PlacesDetailsResponse>.value(
            _FakePlacesDetailsResponse_9(
          this,
          Invocation.method(
            #fetchPlaceDetails,
            [placeId],
          ),
        )),
      ) as _i6.Future<_i5.PlacesDetailsResponse>);

  @override
  void fetchPredictions(String? value) => super.noSuchMethod(
        Invocation.method(
          #fetchPredictions,
          [value],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [Prediction].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrediction extends _i1.Mock implements _i5.Prediction {
  MockPrediction() {
    _i1.throwOnMissingStub(this);
  }

  @override
  List<_i5.Term> get terms => (super.noSuchMethod(
        Invocation.getter(#terms),
        returnValue: <_i5.Term>[],
      ) as List<_i5.Term>);

  @override
  List<String> get types => (super.noSuchMethod(
        Invocation.getter(#types),
        returnValue: <String>[],
      ) as List<String>);

  @override
  List<_i5.MatchedSubstring> get matchedSubstrings => (super.noSuchMethod(
        Invocation.getter(#matchedSubstrings),
        returnValue: <_i5.MatchedSubstring>[],
      ) as List<_i5.MatchedSubstring>);

  @override
  Map<String, dynamic> toJson() => (super.noSuchMethod(
        Invocation.method(
          #toJson,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}
