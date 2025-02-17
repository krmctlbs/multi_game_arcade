import 'package:flutter/material.dart';
import 'package:multi_game_arcade/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import '../models/my_button.dart';
import '../models/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap,});


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  void signUp() async{
    if(passwordController.text != confirmPasswordController.text){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
        content: Text("Passwords do not match!"),
      ),
      );
      return;
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString(),
        ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: null,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child:Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height:50),
                  //logo
                  Icon(
                    Icons.games_outlined,
                    size: 100,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height:50),
                  const Text(
                    "Let's create an account for you:)",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height:25),
                  //email box
                  MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false),
                  const SizedBox(height:10),

                  //password box
                  MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true),
                  const SizedBox(height:25),

                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true),
                  const SizedBox(height:25),

                  MyButton(onTap: signUp, text: "Sign Up"),
                  const SizedBox(height:50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already a member?",
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),),
                      const SizedBox(width: 4,),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,

                          ),
                        ),
                      ),
                    ],
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
}