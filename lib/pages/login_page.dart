import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_game_arcade/models/my_button.dart';
import 'package:multi_game_arcade/models/my_text_field.dart';
import 'package:multi_game_arcade/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap,});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  void signIn() async{
    final authService = Provider.of<AuthService>(context,listen:false);
    try {
      await authService.signInWithEmailAndPassword(
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
                "Welcome back you've been missed",
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
              
              MyButton(onTap: signIn, text: "Sign In"),
                const SizedBox(height:50),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text("Not a member?",
                   style: TextStyle(
                     color: Colors.blueGrey,
                   ),),
                   const SizedBox(width: 4,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Register now!",
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
