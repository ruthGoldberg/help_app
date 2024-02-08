import 'package:firebase_auth/firebase_auth.dart';
import 'package:help_app/pages/home_page_customer.dart';
import 'package:help_app/pages/sign_in_page.dart';
import 'package:help_app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:help_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerSignUpPage extends StatefulWidget {
  const CustomerSignUpPage({super.key});

  @override
  State<CustomerSignUpPage> createState() => _CustomerSignUpPageState();
}

List<String> categories = [
  "Housekeeping",
  "Babysitting",
  "Dog-Sitting",
  "Plumbering"
];
//String? _SelctedArea; // variable to hold the selected category

class _CustomerSignUpPageState extends State<CustomerSignUpPage> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  // create instance of firebase authenticator
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // decoration variables
  Color _emailBorderColor = Colors.black26;
  Color _passwordBorderColor = Colors.black26;

  // send user email and password to Firebase Auth
  Future<void> _signUpFunc(BuildContext context) async {
    String errorMessage = '';

    try {
      // Sign up the user
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store user data in Firestore
      if (userCredential.user != null) {
        await addUserDataToFirestore(
            _nameController.text, _emailController.text);

        // Redirect to home page after successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageCustomer()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Set border color of email field to red
        setState(() {
          _emailBorderColor = Colors.red;
          errorMessage =
              'Email is already in use. Please enter a different email.';
        });
      } else if (e.code == 'weak-password') {
        // Set border color of password field to red
        setState(() {
          _passwordBorderColor = Colors.red;
          errorMessage = 'Weak password. Please choose a stronger password.';
        });
      }
    } catch (e) {
      print("Error during sign up: $e");
    }

    // Show error message if any
    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // send user's data to Firestore db
  Future<void> addUserDataToFirestore(String name, String email) async {
    // set connection to users collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    // get userID from FirebaseAuth
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // create new doc of user. set unique ID
    await users.add({
      'userId': userId,
      'name': name,
      'email': email,
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Join our help community!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name*'),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          // Email format validation
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email*'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _emailBorderColor, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _emailBorderColor, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          // Password strength validation
                          if (value.length < 6) {
                            return 'Password should be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password*'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _passwordBorderColor, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _passwordBorderColor, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignupKey.currentState!.validate()) {
                              await _signUpFunc(context);
                            }
                          },
                          child: const Text('Sign up'),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
