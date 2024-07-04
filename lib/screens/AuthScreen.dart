import 'dart:io';

import 'package:chatapp/screens/loading.dart';
import 'package:chatapp/widgets/UserImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() => _AuthscreenState();
}

class _AuthscreenState extends State<Authscreen> {
  bool secure = false;
  bool secureconfirm = false;
  bool login = true;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController passwordconfirm = TextEditingController();
  File? selectedImage;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    void _togglePasswordVisibility() {
      setState(() {
        secure = !secure;
      });
    }

    void _togglePasswordConfirm() {
      setState(() {
        secureconfirm = !secureconfirm;
      });
    }

    void _toggleLogin() {
      setState(() {
        login = !login;
      });
    }

    void authentication() async {
      if (!_formState.currentState!.validate()) {
        return;
      }

      try {
        setState(() {
          loading = true;
        });

        UserCredential userCredential;

        if (login) {
          userCredential = await firebase.signInWithEmailAndPassword(
            email: email.text,
            password: password.text,
          );
        } else {
          userCredential = await firebase.createUserWithEmailAndPassword(
            email: email.text,
            password: password.text,
          );

          if (selectedImage != null) {
            final Reference reference = FirebaseStorage.instance
                .ref()
                .child("users_images")
                .child("${userCredential.user!.uid}.jpg");

            await reference.putFile(selectedImage!);
            final imageUrl = await reference.getDownloadURL();

            await FirebaseFirestore.instance
                .collection("users")
                .doc(userCredential.user!.uid)
                .set({
              "email": email.text,
              "imageUrl": imageUrl,
              "username": username.text
            });
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      } finally {
        setState(() {
          loading = false;
        });
      }
    }

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );

    return loading
        ? loadingpage()
        : Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Center(
          child: Text(
            login ? "Login" : "Signup",
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
            /*  Center(
                child: Image.asset(
                  "lib/assets/chat.png",
                  width: 200,
                  height: 200,
                ),
              ),*/
              Card(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formState,
                    child: Column(
                      children: [
                        if (!login)
                          UserImagePicker(
                            onPick: (File pickedImage) {
                              setState(() {
                                selectedImage = pickedImage;
                              });
                            },
                          ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: email,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle:
                              TextStyle(color: colorScheme.onSurface),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                        if (!login)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: username,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: "Username",
                                labelStyle: TextStyle(
                                    color: colorScheme.onSurface),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            controller: password,
                            obscureText: secure,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 6) {
                                return 'Enter a password with 6 or more characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle:
                              TextStyle(color: colorScheme.onSurface),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              suffixIcon: IconButton(
                                onPressed: _togglePasswordVisibility,
                                icon: Icon(
                                  secure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!login)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              style: TextStyle(
                                color: colorScheme.onSurface,
                              ),
                              controller: passwordconfirm,
                              obscureText: secureconfirm,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                } else if (value.length < 6) {
                                  return 'Enter a password with 6 or more characters';
                                } else if (password.text !=
                                    passwordconfirm.text) {
                                  return "Passwords don't match";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Confirm Password",
                                labelStyle: TextStyle(
                                    color: colorScheme.onSurface),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(20.0),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: _togglePasswordConfirm,
                                  icon: Icon(
                                    secureconfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          child: ElevatedButton(
                            onPressed: authentication,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              login ? "Login" : "Signup",
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          child: ElevatedButton(
                            onPressed: _toggleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              login ? "Create an account?" : "Have account?",
                              style: TextStyle(
                                color: colorScheme.onSecondary,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
