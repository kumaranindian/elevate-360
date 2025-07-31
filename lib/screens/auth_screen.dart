import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/welcome_card.dart';
import '../components/login_form.dart';
import '../components/signup_form.dart';
import '../components/user_profile.dart';
import '../services/auth_service.dart';

class AuthScreen extends HookWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = useState<User?>(null);
    final isLoading = useState<bool>(false);
    final isLoginView = useState<bool>(true);
    final authService = useMemoized(() => AuthService());

    useEffect(() {
      // Listen to authentication state changes
      final subscription = FirebaseAuth.instance.authStateChanges().listen((User? currentUser) {
        user.value = currentUser;
      });
      return subscription.cancel;
    }, []);

    Future<void> handleLogin(String email, String password) async {
      isLoading.value = true;
      try {
        await authService.signInWithEmailAndPassword(email, password);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleSignUp(String email, String password) async {
      isLoading.value = true;
      try {
        await authService.registerWithEmailAndPassword(email, password);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please sign in.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        isLoginView.value = true; // Switch back to login view
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign-up failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleLogout() async {
      isLoading.value = true;
      try {
        await authService.signOut();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const WelcomeCard(),
                    const SizedBox(height: 32),
                    if (user.value == null)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: isLoginView.value
                            ? LoginForm(
                                key: const ValueKey('login'),
                                onLogin: handleLogin,
                                isLoading: isLoading.value,
                              )
                            : SignUpForm(
                                key: const ValueKey('signup'),
                                onSignUp: handleSignUp,
                                isLoading: isLoading.value,
                              ),
                      )
                    else
                      UserProfile(
                        user: user.value!,
                        onLogout: handleLogout,
                        isLoading: isLoading.value,
                      ),
                    const SizedBox(height: 24),
                    if (user.value == null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLoginView.value
                                ? "Don't have an account?"
                                : 'Already have an account?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              isLoginView.value = !isLoginView.value;
                            },
                            child: Text(
                              isLoginView.value ? 'Sign Up' : 'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
