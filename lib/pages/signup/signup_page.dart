import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/auth_service.dart';
import '../home/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }


  // SIGN UP FUNCTION


  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;

    // Check empty fields
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill in all fields.",
          ),
        ),
      );

      return;
    }

    // Check email format
    if (!email.contains("@") ||
        !email.contains(".")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid email address.",
          ),
        ),
      );

      return;
    }

    // Check password length
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 6 characters.",
          ),
        ),
      );

      return;
    }

    // Check password confirmation
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Passwords do not match.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final success =
    await AuthService.instance.signUp(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Account created successfully!",
          ),
        ),
      );

      // Go to HomePage after successful registration
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to create account.",
          ),
        ),
      );
    }
  }


  // BUILD


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Create Account"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),


              // ICON


              Center(
                child: Icon(
                  Icons.person_add,
                  size: 90,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 25),


              // TITLE


              Text(
                "Create Account",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Create your Smart Window account",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 35),


              // NAME


              CustomTextField(
                controller: nameController,
                label: "Full Name",
                icon: Icons.person,
                keyboardType:
                TextInputType.name,
              ),

              const SizedBox(height: 20),


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
                obscureText:
                isPasswordHidden,

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

              const SizedBox(height: 20),


              // CONFIRM PASSWORD


              CustomTextField(
                controller:
                confirmPasswordController,
                label: "Confirm Password",
                icon: Icons.lock_outline,
                obscureText:
                isConfirmPasswordHidden,

                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),

                  onPressed: () {
                    setState(() {
                      isConfirmPasswordHidden =
                      !isConfirmPasswordHidden;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),


              // REGISTER BUTTON


              isLoading
                  ? const Center(
                child:
                CircularProgressIndicator(),
              )
                  : CustomButton(
                text: "CREATE ACCOUNT",
                onPressed: register,
              ),

              const SizedBox(height: 25),


              // BACK TO LOGIN


              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [

                  const Text(
                    "Already have an account?",
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Login",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}