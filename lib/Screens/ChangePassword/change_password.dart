import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/ChangePassword/change_password_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  @override
  void initState() {
    setupData();
    super.initState();
  }

  setupData() async {
    userController.text =
        await SharedPreferenceHelper.instance.getUserName() ?? '';
    setState(() {});
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      showLoadingDialog(context);
      try {
        var response = await ChangePasswordService.instance.changePassword(
            convertSHA256(oldPasswordController.text),
            convertSHA256(newPasswordController.text));
        if (response?.status == true) {
          if (!mounted) return;
          Navigator.pop(context);
          showSuccessToast("Password updated successfully");
          if (!mounted) return;
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: response?.error ?? 'Something went wrong');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
    }
  }

  String convertSHA256(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hashed password
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                _buildTextField(
                    userController, "Username", Icons.person, false),
                SizedBox(height: 15),
                _buildPasswordField(
                    oldPasswordController, "Old Password", _isObscureOld, () {
                  setState(() {
                    _isObscureOld = !_isObscureOld;
                  });
                }),
                SizedBox(height: 15),
                _buildPasswordField(
                    newPasswordController, "New Password", _isObscureNew, () {
                  setState(() {
                    _isObscureNew = !_isObscureNew;
                  });
                }),
                SizedBox(height: 15),
                _buildPasswordField(confirmPasswordController,
                    "Confirm New Password", _isObscureConfirm, () {
                  setState(() {
                    _isObscureConfirm = !_isObscureConfirm;
                  });
                }),
                SizedBox(height: 25),
                CommonButton(
                    text: "Change Password", onPressed: _changePassword)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      IconData icon, bool isPassword) {
    return TextFormField(
      controller: controller,
      readOnly: hint == "Username",
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? "$hint cannot be empty" : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint,
      bool isObscure, VoidCallback toggleVisibility) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value!.isEmpty) return "$hint cannot be empty";
        if (hint == "Confirm New Password" &&
            value != newPasswordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }
}
