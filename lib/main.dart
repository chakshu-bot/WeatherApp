//import 'dart:ui';

//import 'package:flutter/cupertino.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

//import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

void main() async {
  runApp(Login());
}


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

late AnimationController _controller;
late AnimationController _fadeController;
late AnimationController _fadeInController;
late AnimationController _finalController;
late AnimationController _whiteFadeController;

late Animation<double> _animation;
late Animation<double> _fadeAnimation;
late Animation<double> _fadeInAnimation;
late Animation<double> _finalAnimation;
late Animation<double?> _whiteFadeAnimation;

TextEditingController _username = TextEditingController();
TextEditingController _password = TextEditingController();
bool countryDone = false;
bool stateDone = false;
bool cityDone = false;
bool callFinal = false;
bool show = true;
bool opacityCheck = false;
late String cityNa;
late String countryNa;
late String userName;

class _LoginState extends State<Login> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

//bool readyToNavigate = false;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _finalController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _fadeController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    _fadeInController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _whiteFadeController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: -700, end: -100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _finalAnimation = Tween<double>(begin: -100, end: 1000).animate(
        CurvedAnimation(parent: _finalController, curve: Curves.easeIn));
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn));
    _whiteFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _whiteFadeController, curve: Curves.easeIn));

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          show = false;
        });
        _controller.forward();
        _controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _fadeInController.forward();
            _fadeInController.addStatusListener((status) {
              print('no error here');
              if (status == AnimationStatus.dismissed) {
                print('working');
                setState(() {
                  callFinal = true;
                });
                _finalController.forward();
                Future.delayed(const Duration(milliseconds: 1500), () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomeScreen(
                            cityName: cityNa,
                            countryName: countryNa,
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = 0.0;
                        var end = 1.0;
                        var curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return FadeTransition(
                          opacity: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration:
                      const Duration(seconds: 2), // Adjust as needed
                    ),
                  );
                });
                //navigateToHomeWithDelay();
                _finalController.addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    // Navigator.pushReplacement(
                    //   context,
                    //   PageRouteBuilder(
                    //     pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    //       var curve = Curves.easeInOut;
                    //       var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                    //
                    //       return FadeTransition(
                    //         opacity: animation.drive(tween),
                    //         child: child,
                    //       );
                    //     },
                    //     transitionDuration: const Duration(seconds: 3),
                    //   ),
                    // );
                    // setState(() {
                    //   opacityCheck = true;
                    // });
                    // _whiteFadeController.forward();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const HomeScreen()),
                    //);
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  void activeButton() async {
    print('I entered');
    String username = _username.text;
    String password = _password.text;
    userName = username;
    setState(() {
      print('I am Here');
      if (username.isNotEmpty && password.isNotEmpty) {
        FocusScope.of(context).unfocus();
        _fadeController.forward();
      }
    });
  }

  void doneButton() async{
    if (countryDone && stateDone && cityDone) {
      _fadeInController.reverse();
    }
  }

  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _fadeInController.dispose();
    _finalController.dispose();
    _whiteFadeController.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: OverflowBox(
                maxHeight: 4000,
                child: AnimatedBuilder(
                    animation: callFinal ? _finalAnimation : _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            0,
                            callFinal
                                ? _finalAnimation.value
                                : _animation.value),
                        child: const Image(
                          image: AssetImage('assets/image.png'),
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      );
                    })),
          ),
          show
              ? FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding:
              const EdgeInsets.only(top: 300, left: 50, right: 50),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 65,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Username',labelStyle: TextStyle(color: Colors.white)),

                      controller: _username,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Password',labelStyle: TextStyle(color: Colors.white)),
                      obscureText: true,
                      controller: _password,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            print('Atleast here');
                            activeButton();
                          },
                          child: const Text('Login')),
                    ),
                  ],
                ),
              ),
            ),
          )
              : FadeTransition(
            opacity: _fadeInAnimation,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Text(
                    'Set Location',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 50, left: 50, right: 50, bottom: 20),
                  child: CSCPicker(
                    layout: Layout.vertical,
                    flagState: CountryFlag.DISABLE,
                    onCountryChanged: (country) {
                      setState(() {
                        if (country != null && country != 'Default') {
                          countryDone = true;
                        }
                        countryNa = country;
                      });
                    },
                    onStateChanged: (state) {
                      setState(() {
                        if (state != null && state != 'Default') {
                          stateDone = true;
                        }
                      });
                    },
                    onCityChanged: (city) {
                      setState(() {
                        if (city != null && city != 'Default') {
                          cityDone = true;
                        }
                        if (city != null) {
                          cityNa = city;
                        }
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('ready to go');
                    doneButton();
                  },
                  child: const Text('Done'),
                )
              ],
            ),
          ),
          // opacityCheck?
          // Opacity(
          //   opacity: _whiteFadeAnimation.value!,
          //   child: Container(
          //     color: Colors.white,
          //   ),
          // ) : Container(),
        ],
      ),
    );
  }
}
