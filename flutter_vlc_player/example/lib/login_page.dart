import 'package:flutter/material.dart';
import 'app.dart';
import 'forgot password.dart'; 
import 'package:http/http.dart' as http;
import 'app.dart';

void main() {
  runApp(MaterialApp(
    home: App(),
  ));
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? UsernameError;
  String? PasswordError;

  Future<void> loginUser(String username, String password) async {
    final parameters = {"password": password};
    var response = await http.get(
      Uri.http("endoapi.greenorange.in", "/users/$username", parameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print('Login successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => App()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Succesful')),
      );
    } else {
      print('Login failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed!')),
      );
    }
  }

  void onLoginButtonPressed() {
    var username = usernameController.text;
    var password = passwordController.text;
    setState(() {
      UsernameError = usernameController.text.isEmpty ? 'Username cannot be empty' : null;
      PasswordError = passwordController.text.isEmpty ? 'Password cannot be empty' : null;
    });
    loginUser(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bgimage.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Align(
                alignment: Alignment(-0.9799999, -1.0),
                child: ClipOval(
                  child: Image.asset('images/cctv_logo.jpg', width: 60.0),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 16),
                  Text(
                    'CLOUD',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                    fillColor: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: Text('Forgot Password'),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Login'),
                  onPressed: onLoginButtonPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
