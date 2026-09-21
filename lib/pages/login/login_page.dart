import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';
import '../home/home_page.dart';
import '../signup/signup_page.dart';
import '../admin/admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  // LOGIN FUNCTION


  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Check empty fields
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter your email and password.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final success = await AuthService.instance.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      final role = await AuthService.instance.getUserRole();

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardPage(),
          ),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
              (route) => false,
        );
      }
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password."),
        ),
      );
    }
  }


  // BUILD


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 40),


              // LOGO


              Center(
                child: Icon(
                  Icons.window,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 30),


              // APP NAME


              Text(
                AppConstants.appName,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                "Welcome Back",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 40),


              // EMAIL


              CustomTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType:
                TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),


              // PASSWORD


              CustomTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                obscureText: isPasswordHidden,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden =
                      !isPasswordHidden;
                    });
                  },
                ),
              ),

              const SizedBox(height: 15),


              // FORGOT PASSWORD


              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Forgot password feature is not available yet.",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                  ),
                ),
              ),

              const SizedBox(height: 25),


              // LOGIN BUTTON


              isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : CustomButton(
                text: "LOGIN",
                onPressed: login,
              ),

              const SizedBox(height: 30),


              // REGISTER


              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}