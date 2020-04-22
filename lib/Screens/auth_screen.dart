import 'dart:math';
import 'package:lostofpeople/seting_screen_details/conected_with_me.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.lightBlueAccent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top:20.0,bottom: 50.0),
                    child: Plane(),
                  ),
                  Flexible(
                    child: Container(height: 80.0,
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),

                      child: Column(

                        children: <Widget>[

                          Text(
                            'Lost Of People',
                            style: TextStyle(
                              color: Theme.of(context).accentTextTheme.title.color,
                              fontSize: 30,
                              fontFamily: 'Anton',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _SlideAnimation;
  Animation<double> _opacityAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 300,
        ));
    _SlideAnimation = Tween<Offset>(
            begin: Offset(0, -1.5), end: Offset(0,0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    //_heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrordialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('ok'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).singup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authenticate failed.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'this email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL ')) {
        errorMessage = 'this IS not a valid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'this password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID PASSWORD.';
      }
      _showErrordialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you . Please try again later.';
      _showErrordialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: AnimatedBuilder(
          animation: _SlideAnimation,
          builder: (ctx, ch) => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInSine,
            height: _authMode == AuthMode.Signup ? 320 : 260,
            // height: _heightAnimation.value.height,
            constraints: BoxConstraints(
                minHeight: _authMode == AuthMode.Signup ? 320 : 260),
            width: deviceSize.width * 0.75,
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Invalid email!';
                        }
                      },
                      onSaved: (value) {
                        _authData['email'] = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value.isEmpty || value.length < 5) {
                          return 'Password is too short!';
                        }
                      },
                      onSaved: (value) {
                        _authData['password'] = value;
                      },
                    ),
                    if (_authMode == AuthMode.Signup)
                      AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          constraints: BoxConstraints(
                            minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                            maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                          ),
                          child: FadeTransition(
                              opacity: _opacityAnimation,
                              child: SlideTransition(
                                position: _SlideAnimation,
                                child: TextFormField(
                                  enabled: _authMode == AuthMode.Signup,
                                  decoration: InputDecoration(
                                      labelText: 'Confirm Password'),
                                  obscureText: true,
                                  validator: _authMode == AuthMode.Signup
                                      ? (value) {
                                          if (value != _passwordController.text) {
                                            return 'Passwords do not match!';
                                          }
                                        }
                                      : null,
                                ),
                              ))),
                    SizedBox(
                      height: 20,
                    ),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      RaisedButton(
                        child: Text(
                            _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                        onPressed: _submit,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        color: Theme.of(context).primaryColor,
                        textColor:
                            Theme.of(context).primaryTextTheme.button.color,
                      ),
                    FlatButton(
                      child: Text(
                          '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                      onPressed: _switchAuthMode,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
