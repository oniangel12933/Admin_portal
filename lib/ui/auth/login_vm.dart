// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/token_model.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/auth/auth_actions.dart';
import 'package:invoiceninja_flutter/redux/auth/auth_state.dart';
import 'package:invoiceninja_flutter/redux/dashboard/dashboard_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/pref_state.dart';
import 'package:invoiceninja_flutter/ui/app/app_builder.dart';
import 'package:invoiceninja_flutter/ui/auth/login_view.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/utils/oauth.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key key}) : super(key: key);

  static const String route = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, LoginVM>(
        converter: LoginVM.fromStore,
        builder: (context, viewModel) {
          return LoginView(
            viewModel: viewModel,
          );
        },
      ),
    );
  }
}

class LoginVM {
  LoginVM({
    @required this.state,
    @required this.isLoading,
    @required this.authState,
    @required this.onLoginPressed,
    @required this.onRecoverPressed,
    @required this.onSignUpPressed,
    @required this.onGoogleLoginPressed,
    @required this.onGoogleSignUpPressed,
    @required this.onTokenLoginPressed,
  });

  AppState state;
  bool isLoading;
  AuthState authState;

  final Function(
    BuildContext,
    Completer<Null> completer, {
    @required String email,
    @required String password,
    @required String url,
    @required String secret,
    @required String oneTimePassword,
  }) onLoginPressed;

  final Function(
    BuildContext,
    Completer<Null> completer, {
    @required String email,
    @required String url,
    @required String secret,
  }) onRecoverPressed;

  final Function(
    BuildContext,
    Completer<Null> completer, {
    @required String email,
    @required String password,
  }) onSignUpPressed;

  final Function(
    BuildContext,
    Completer<Null> completer, {
    @required String token,
  }) onTokenLoginPressed;

  final Function(BuildContext, Completer<Null> completer,
      {String url, String secret, String oneTimePassword}) onGoogleLoginPressed;
  final Function(BuildContext, Completer<Null> completer) onGoogleSignUpPressed;

  static LoginVM fromStore(Store<AppState> store) {
    void _handleLogin({BuildContext context, bool isSignUp = false}) {
      final layout = calculateLayout(context);
      final moduleLayout =
          layout == AppLayout.desktop ? ModuleLayout.table : ModuleLayout.list;
      store.dispatch(UpdateUserPreferences(
        appLayout: layout,
        moduleLayout: isSignUp ? moduleLayout : null,
      ));
      AppBuilder.of(context).rebuild();

      WidgetsBinding.instance.addPostFrameCallback((duration) {
        if (layout == AppLayout.mobile) {
          if (isSignUp) {
            store.dispatch(
                UpdateUserPreferences(moduleLayout: ModuleLayout.list));
          }
          store.dispatch(ViewDashboard());
        } else {
          store.dispatch(ViewMainScreen());
        }
      });
    }

    String _formatApiUrl(String url) {
      url = url.trim();

      if (url.isEmpty) {
        url = kAppProductionUrl;
      } else if (!url.startsWith('http')) {
        url = 'https://' + url;
      }

      return formatApiUrl(url);
    }

    return LoginVM(
      state: store.state,
      isLoading: store.state.isLoading,
      authState: store.state.authState,
      onGoogleLoginPressed: (
        BuildContext context,
        Completer<Null> completer, {
        @required String url,
        @required String secret,
        @required String oneTimePassword,
      }) async {
        try {
          await GoogleOAuth.signOut();
          final signedIn = await GoogleOAuth.signIn((idToken, accessToken) {
            if (idToken.isEmpty || accessToken.isEmpty) {
              GoogleOAuth.signOut();
              completer.completeError(
                  AppLocalization.of(context).anErrorOccurredTryAgain);
            } else {
              store.dispatch(OAuthLoginRequest(
                completer: completer,
                idToken: idToken,
                accessToken: accessToken,
                url: _formatApiUrl(url),
                secret: secret.trim(),
                platform: getPlatform(context),
                oneTimePassword: oneTimePassword,
              ));
              completer.future.then((_) => _handleLogin(context: context));
            }
          });
          if (!signedIn) {
            completer.completeError(
                AppLocalization.of(context).anErrorOccurredTryAgain);
          }
        } catch (error) {
          completer.completeError(error);
          print('## onGoogleLoginPressed: $error');
        }
      },
      onGoogleSignUpPressed:
          (BuildContext context, Completer<Null> completer) async {
        try {
          await GoogleOAuth.signOut();
          final signedIn = await GoogleOAuth.signUp((idToken, accessToken) {
            if (idToken.isEmpty || accessToken.isEmpty) {
              GoogleOAuth.signOut();
              completer.completeError(
                  AppLocalization.of(context).anErrorOccurredTryAgain);
            } else {
              store.dispatch(OAuthSignUpRequest(
                completer: completer,
                idToken: idToken,
                accessToken: accessToken,
              ));
              completer.future
                  .then((_) => _handleLogin(context: context, isSignUp: true));
            }
          });
          if (!signedIn) {
            completer.completeError(
                AppLocalization.of(context).anErrorOccurredTryAgain);
          }
        } catch (error) {
          completer.completeError(error);
          print('## onGoogleSignUpPressed: $error');
        }
      },
      onSignUpPressed: (
        BuildContext context,
        Completer<Null> completer, {
        @required String email,
        @required String password,
      }) async {
        if (store.state.isLoading) {
          return;
        }

        store.dispatch(UserSignUpRequest(
          completer: completer,
          email: email.trim(),
          password: password.trim(),
        ));
        completer.future
            .then((_) => _handleLogin(context: context, isSignUp: true));
      },
      onRecoverPressed: (
        BuildContext context,
        Completer<Null> completer, {
        @required String email,
        @required String url,
        @required String secret,
      }) async {
        if (store.state.isLoading) {
          return;
        }

        store.dispatch(RecoverPasswordRequest(
          completer: completer,
          email: email.trim(),
          url: _formatApiUrl(url),
          secret: secret.trim(),
        ));
      },
      onLoginPressed: (
        BuildContext context,
        Completer<Null> completer, {
        @required String email,
        @required String password,
        @required String url,
        @required String secret,
        @required String oneTimePassword,
      }) async {
        if (store.state.isLoading) {
          return;
        }

        store.dispatch(UserLoginRequest(
          completer: completer,
          email: email.trim(),
          password: password.trim(),
          url: _formatApiUrl(url),
          secret: secret.trim(),
          platform: getPlatform(context),
          oneTimePassword: oneTimePassword.trim(),
        ));
        completer.future.then((_) => _handleLogin(context: context));
      },
      onTokenLoginPressed: (BuildContext context, Completer<Null> completer,
          {@required String token}) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(kSharedPrefToken, TokenEntity.obscureToken(token));
        prefs.setString(kSharedPrefUrl, kAppProductionUrl);
      },
    );
  }
}
