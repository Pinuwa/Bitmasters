import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signin.dart'; // Import the LessonPage

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() =>
      SignupPageState(); // Changed from _SignupPageState
}

class SignupPageState extends State<SignupPage> {
  // Changed from _SignupPageState
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int? _selectedRadio;
  bool _isCheckboxChecked = false; // Changed from final to non-final

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() == true &&
        _selectedRadio != null &&
        _isCheckboxChecked;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        var response = await http.post(
          Uri.parse('http://192.168.1.31:3000/signup'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'userType': _selectedRadio == 1
                ? 'Sign Language Learner'
                : 'Verbal Learner',
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SigninPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sign up: ${response.body}')),
          );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _onRadioChanged(int? value) {
    setState(() {
      _selectedRadio = value;
    });
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      _isCheckboxChecked = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(249, 221, 164, 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 171, 10, 0.23),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(300),
                        bottomRight: Radius.circular(300),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'සිංහල සංඥා භාෂා ඉගෙනුම් පද්ධතිය \n හා\n වාචික පුහුණුව',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 156, 9, 1),
                          fontFamily: '0KDNAMAL',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/interfacepng.png',
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'ලියාපදිංචි පෝරමය',
                style: TextStyle(
                  color: Color.fromRGBO(255, 156, 9, 1),
                  fontFamily: 'Yasarath',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField('පරිශීලක නම', _usernameController),
                    const SizedBox(height: 20),
                    _buildTextField('විද්‍යුත් තැපෑල', _emailController),
                    const SizedBox(height: 20),
                    _buildPasswordField('මුරපදය', _passwordController),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                        'මුරපදය තහවුරු කරන්න', _confirmPasswordController),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ඔබ :-',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'Yasarath',
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: _selectedRadio,
                    onChanged: _onRadioChanged,
                  ),
                  const Text(
                    'සංඥා පුහුණු වෙන්නා',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Yasarath',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 2,
                    groupValue: _selectedRadio,
                    onChanged: _onRadioChanged,
                  ),
                  const Text(
                    'වාචික පුහුණු වෙන්නා',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Yasarath',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isCheckboxChecked,
                    onChanged: _onCheckboxChanged,
                  ),
                  const Expanded(
                    child: Text(
                      'මෙම සේවය හා සම්බන්ධ අලුත්ම ප්‍රවෘත්ති මට ලැබේවි.',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Yasarath',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isFormValid() ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid()
                      ? const Color.fromRGBO(15, 254, 254, 1)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: const Text(
                  'ලියාපදිංචි වන්න',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Yasarath',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color.fromRGBO(0, 0, 0, 1),
            fontFamily: 'Yasarath',
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[500],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color.fromRGBO(0, 0, 0, 1),
            fontFamily: 'Yasarath',
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[500],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            if (controller == _confirmPasswordController &&
                value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
