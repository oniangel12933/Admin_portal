// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoiceninja_flutter/ui/app/app_title_bar.dart';

// Package imports:
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:invoiceninja_flutter/.env.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/redux/ui/pref_state.dart';
import 'package:invoiceninja_flutter/ui/app/buttons/elevated_button.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/alert_dialog.dart';
import 'package:invoiceninja_flutter/ui/app/form_card.dart';
import 'package:invoiceninja_flutter/ui/app/forms/app_toggle_buttons.dart';
import 'package:invoiceninja_flutter/ui/app/forms/decorated_form_field.dart';
import 'package:invoiceninja_flutter/ui/app/forms/password_field.dart';
import 'package:invoiceninja_flutter/ui/app/link_text.dart';
import 'package:invoiceninja_flutter/ui/app/scrollable_listview.dart';
import 'package:invoiceninja_flutter/ui/auth/login_vm.dart';
import 'package:invoiceninja_flutter/utils/colors.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/utils/oauth.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';

import 'package:invoiceninja_flutter/utils/web_stub.dart'
    if (dart.library.html) 'package:invoiceninja_flutter/utils/web.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final LoginVM viewModel;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_login');

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _secretController = TextEditingController();
  final _oneTimePasswordController = TextEditingController();
  final _tokenController = TextEditingController();

  final _buttonController = RoundedLoadingButtonController();

  static const String OTP_ERROR = 'OTP_REQUIRED';

  String _loginError = '';

  bool _tokenLogin = false;
  bool _emailLogin = false;
  bool _isSelfHosted = false;
  bool _createAccount = true;
  bool _hideGoogle = false;

  bool _recoverPassword = false;
  bool _autoValidate = false;
  bool _termsChecked = false;
  bool _privacyChecked = false;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      final authState = widget.viewModel.authState;
      _isSelfHosted = authState.isSelfHost;
      if (_isSelfHosted) {
        _emailLogin = true;
        _createAccount = false;
      } else if (WebUtils.getHtmlValue('login') == 'true') {
        _createAccount = false;
      }
    } else if (isApple() || !GoogleOAuth.isEnabled) {
      _emailLogin = true;
      _hideGoogle = true;
      _createAccount = false;
    } else if (isWindows() || isLinux()) {
      _emailLogin = true;
      _hideGoogle = true;
    }
  }

  @override
  void didChangeDependencies() {
    if (!kReleaseMode && Config.TEST_EMAIL.isNotEmpty) {
      _urlController.text = Config.TEST_URL;
      _secretController.text = Config.TEST_SECRET;
      _emailController.text = Config.TEST_EMAIL;
      _passwordController.text = Config.TEST_PASSWORD;
      _firstNameController.text = 'TEST';
      _lastNameController.text = 'TEST';
      _privacyChecked = true;
      _termsChecked = true;
      _emailLogin = true;
      _createAccount = false;
    }

    if (_urlController.text.isEmpty) {
      _urlController.text = widget.viewModel.authState.url;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _secretController.dispose();
    _oneTimePasswordController.dispose();
    _tokenController.dispose();

    super.dispose();
  }

  void _submitForm() {
    _buttonController.start();

    if (_createAccount) {
      _submitSignUpForm();
    } else {
      _submitLoginForm();
    }
  }

  void _submitSignUpForm() {
    final isValid = _formKey.currentState.validate();
    final localization = AppLocalization.of(context);
    final viewModel = widget.viewModel;

    setState(() {
      _autoValidate = !isValid ?? false;
      _loginError = '';
    });

    if (!isValid) {
      _buttonController.reset();
      return;
    }

    if (_createAccount && (!_termsChecked || !_privacyChecked)) {
      _buttonController.reset();
      showDialog<AlertDialog>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(!_termsChecked
                  ? localization.termsOfService
                  : localization.privacyPolicy),
              content: Text(localization.pleaseAgreeToTermsAndPrivacy),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    child: Text(AppLocalization.of(context).close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            );
          });
      return;
    }

    final Completer<Null> completer = Completer<Null>();
    completer.future.then((_) {
      setState(() {
        _loginError = '';
      });
    }).catchError((Object error) {
      setState(() {
        _buttonController.reset();
        _loginError = error.toString();
      });
    });

    if (_emailLogin) {
      viewModel.onSignUpPressed(
        context,
        completer,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      viewModel.onGoogleSignUpPressed(context, completer);
    }
  }

  void _submitLoginForm() {
    final isValid = _formKey.currentState.validate();
    final viewModel = widget.viewModel;

    setState(() {
      _autoValidate = !isValid ?? false;
      _loginError = '';
    });

    if (!isValid) {
      _buttonController.reset();
      return;
    }

    final Completer<Null> completer = Completer<Null>();
    completer.future.then((_) {
      setState(() {
        _loginError = '';
        if (_recoverPassword) {
          _recoverPassword = false;
          _buttonController.reset();
          showDialog<MessageDialog>(
              context: context,
              builder: (BuildContext context) {
                return MessageDialog(
                    AppLocalization.of(context).recoverPasswordEmailSent);
              });
        }
      });
    }).catchError((Object error) {
      setState(() {
        _buttonController.reset();
        _loginError = error.toString();
      });
    });

    final authState = widget.viewModel.authState;
    final url = _isSelfHosted
        ? _urlController.text
        : authState.isLargeTest
            ? kAppLargeTestUrl
            : authState.isStaging
                ? kAppStagingUrl
                : kAppProductionUrl;

    if (_emailLogin) {
      if (_recoverPassword) {
        viewModel.onRecoverPressed(
          context,
          completer,
          email: _emailController.text,
          url: url,
          secret: _isSelfHosted ? _secretController.text : '',
        );
      } else {
        viewModel.onLoginPressed(
          context,
          completer,
          email: _emailController.text,
          password: _passwordController.text,
          url: url,
          secret: _isSelfHosted ? _secretController.text : '',
          oneTimePassword: _oneTimePasswordController.text,
        );
      }
    } else {
      viewModel.onGoogleLoginPressed(context, completer,
          url: url,
          secret: _isSelfHosted ? _secretController.text : '',
          oneTimePassword: _oneTimePasswordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final platform = getNativePlatform();
    final viewModel = widget.viewModel;
    final state = viewModel.state;

    final ThemeData themeData = Theme.of(context);
    final TextStyle aboutTextStyle = themeData.textTheme.bodyText2;
    final TextStyle linkStyle = themeData.textTheme.bodyText2
        .copyWith(color: convertHexStringToColor(kDefaultAccentColor));

    final double horizontalPadding =
        calculateLayout(context) == AppLayout.desktop ? 40 : 16;

    return SafeArea(
      child: ScrollableListView(
        children: <Widget>[
          if (isDesktopOS())
            AppTitleBar()
          else
            Container(
              width: double.infinity,
              height: 24,
              color: state.accentColor,
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 25),
            child: Center(
              child: InkWell(
                // TODO correct this
                child: Image.asset(
                    state.prefState.enableDarkMode
                        ? 'assets/images/logo_dark.png'
                        : 'assets/images/logo_light.png',
                    height: 50),
                onTap: isApple()
                    ? null
                    : () {
                        launch(kSiteUrl,
                            forceSafariVC: false, forceWebView: false);
                      },
                onLongPress: () {
                  if (kReleaseMode) {
                    return;
                  }

                  setState(() => _tokenLogin = !_tokenLogin);
                },
              ),
            ),
          ),
          if (_tokenLogin)
            FormCard(
              forceNarrow: calculateLayout(context) != AppLayout.mobile,
              children: [
                DecoratedFormField(
                  autofocus: true,
                  label: localization.token,
                  controller: _tokenController,
                  keyboardType: TextInputType.text,
                ),
                AppButton(
                  label: localization.submit.toUpperCase(),
                  onPressed: () {
                    final Completer<Null> completer = Completer<Null>();
                    viewModel.onTokenLoginPressed(context, completer,
                        token: _tokenController.text);
                  },
                )
              ],
            ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: viewModel.authState.isAuthenticated ? 0 : 1,
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: FormCard(
                  elevation: 20,
                  forceNarrow: calculateLayout(context) != AppLayout.mobile,
                  internalPadding: const EdgeInsets.all(0),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        if (!isApple() &&
                            (!kIsWeb || !state.authState.isSelfHost))
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: _createAccount
                                      ? state.accentColor
                                      : Colors.transparent,
                                  child: InkWell(
                                    child: Center(
                                        child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        localization.signUp,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: _createAccount
                                                    ? Colors.white
                                                    : null),
                                      ),
                                    )),
                                    onTap: () {
                                      setState(() {
                                        _createAccount = true;
                                        _isSelfHosted = false;
                                        _loginError = '';
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Material(
                                  color: _createAccount
                                      ? Colors.transparent
                                      : state.accentColor,
                                  child: InkWell(
                                    child: Center(
                                        child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        localization.login,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: _createAccount
                                                    ? null
                                                    : Colors.white),
                                      ),
                                    )),
                                    onTap: () {
                                      setState(() {
                                        _createAccount = false;
                                        _loginError = '';
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 20),
                        if (!_recoverPassword) ...[
                          if (!_createAccount &&
                              (!kIsWeb || !kReleaseMode)) ...[
                            RuledText(localization.selectPlatform),
                            AppToggleButtons(
                              tabLabels: [
                                localization.hosted,
                                localization.selfhosted,
                              ],
                              selectedIndex: _isSelfHosted ? 1 : 0,
                              onTabChanged: (index) {
                                setState(() {
                                  _isSelfHosted = index == 1;
                                  _loginError = '';
                                  if (index == 1) {
                                    _emailLogin = true;
                                  }
                                });
                              },
                            ),
                          ],
                          if (!_isSelfHosted && !_hideGoogle) ...[
                            RuledText(localization.selectMethod),
                            AppToggleButtons(
                              tabLabels:
                                  calculateLayout(context) == AppLayout.mobile
                                      ? [
                                          'Google',
                                          localization.email,
                                        ]
                                      : [
                                          _createAccount
                                              ? localization.googleSignUp
                                              : localization.googleSignIn,
                                          _createAccount
                                              ? localization.emailSignUp
                                              : localization.emailSignIn,
                                        ],
                              selectedIndex: _emailLogin ? 1 : 0,
                              onTabChanged: (index) {
                                setState(() {
                                  _emailLogin = index == 1;
                                  _loginError = '';
                                });
                              },
                            ),
                          ],
                        ],
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          child: Column(
                            children: [
                              if (_emailLogin)
                                DecoratedFormField(
                                  controller: _emailController,
                                  label: localization.email,
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidate: _autoValidate,
                                  validator: (val) =>
                                      val.isEmpty || val.trim().isEmpty
                                          ? localization.pleaseEnterYourEmail
                                          : null,
                                  autofillHints: [AutofillHints.email],
                                  autofocus: true,
                                  onSavePressed: (_) => _submitForm(),
                                ),
                              if (_emailLogin && !_recoverPassword)
                                PasswordFormField(
                                  controller: _passwordController,
                                  autoValidate: false,
                                  newPassword: _createAccount,
                                  onSavePressed: (_) => _submitForm(),
                                ),
                              if (!_createAccount && !_recoverPassword)
                                DecoratedFormField(
                                  controller: _oneTimePasswordController,
                                  label:
                                      '2FA - ${localization.oneTimePassword} (${localization.optional})',
                                  onSavePressed: (_) => _submitForm(),
                                  keyboardType: TextInputType.number,
                                  autofillHints: [AutofillHints.oneTimeCode],
                                ),
                              if (_isSelfHosted && !kIsWeb)
                                DecoratedFormField(
                                  controller: _urlController,
                                  label: localization.url,
                                  validator: (val) =>
                                      val.isEmpty || val.trim().isEmpty
                                          ? localization.pleaseEnterYourUrl
                                          : null,
                                  keyboardType: TextInputType.url,
                                  onSavePressed: (_) => _submitForm(),
                                ),
                              if (_isSelfHosted && !_recoverPassword)
                                PasswordFormField(
                                  labelText:
                                      '${localization.secret} (${localization.optional})',
                                  controller: _secretController,
                                  autoValidate: _autoValidate,
                                  validate: false,
                                  onSavePressed: (_) => _submitForm(),
                                ),
                              if (_createAccount)
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: <Widget>[
                                      CheckboxListTile(
                                        onChanged: (value) => setState(
                                            () => _termsChecked = value),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        activeColor: convertHexStringToColor(
                                            kDefaultAccentColor),
                                        value: _termsChecked,
                                        title: RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                style: aboutTextStyle,
                                                text: localization.iAgreeToThe +
                                                    ' ',
                                              ),
                                              LinkTextSpan(
                                                style: linkStyle,
                                                url: kTermsOfServiceURL,
                                                text:
                                                    localization.termsOfService,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      CheckboxListTile(
                                        onChanged: (value) => setState(
                                            () => _privacyChecked = value),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        activeColor: convertHexStringToColor(
                                            kDefaultAccentColor),
                                        value: _privacyChecked,
                                        title: RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                style: aboutTextStyle,
                                                text: localization.iAgreeToThe +
                                                    ' ',
                                              ),
                                              LinkTextSpan(
                                                style: linkStyle,
                                                url: kPrivacyPolicyURL,
                                                text:
                                                    localization.privacyPolicy,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_loginError.isNotEmpty &&
                        !_loginError.contains(OTP_ERROR))
                      Container(
                        padding: EdgeInsets.only(
                            top: 20,
                            left: horizontalPadding,
                            right: horizontalPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _loginError,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            IconButton(
                                icon: Icon(Icons.content_copy),
                                tooltip: localization.copyError,
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _loginError));
                                }),
                          ],
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20, bottom: 10, left: 16, right: 16),
                      child: RoundedLoadingButton(
                        height: 50,
                        borderRadius: 4,
                        width: 430,
                        controller: _buttonController,
                        color: state.accentColor,
                        onPressed: () => _submitForm(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_emailLogin)
                              Icon(Icons.mail, color: Colors.white)
                            else
                              ClipOval(
                                child: Image.asset(
                                    'assets/images/google_logo.png',
                                    width: 30,
                                    height: 30),
                              ),
                            SizedBox(width: 10),
                            Text(
                              _recoverPassword
                                  ? localization.recoverPassword
                                  : _createAccount
                                      ? (_emailLogin
                                          ? localization.emailSignUp
                                          : localization.googleSignUp)
                                      : (_emailLogin
                                          ? localization.emailSignIn
                                          : localization.googleSignIn),
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Flex(
                      direction: calculateLayout(context) == AppLayout.desktop
                          ? Axis.horizontal
                          : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (!_createAccount && _emailLogin)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _recoverPassword = !_recoverPassword;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    if (!_recoverPassword)
                                      Icon(MdiIcons.lock, size: 16),
                                    SizedBox(width: 8),
                                    Text(_recoverPassword
                                        ? localization.cancel
                                        : localization.recoverPassword),
                                  ]),
                            ),
                          ),
                        if (!_recoverPassword && !_isSelfHosted)
                          InkWell(
                            onTap: () {
                              launch(kStatusCheckUrl);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.security, size: 16),
                                  SizedBox(width: 8),
                                  Text(localization.checkStatus)
                                ],
                              ),
                            ),
                          ),
                        if (!_recoverPassword && kIsWeb)
                          InkWell(
                            onTap: () => launch(getNativeAppUrl(platform)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(getNativeAppIcon(platform), size: 16),
                                  SizedBox(width: 8),
                                  Text('$platform ${localization.app}')
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RuledText extends StatelessWidget {
  const RuledText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding =
        calculateLayout(context) == AppLayout.desktop ? 40 : 16;

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 4,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.withOpacity(.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.withOpacity(.5),
            ),
          ),
        ],
      ),
    );
  }
}
