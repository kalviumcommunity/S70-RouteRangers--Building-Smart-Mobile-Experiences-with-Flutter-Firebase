import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _errorMessage = null);

    // Validate fields
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.signIn(email, password);
      
      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          setState(() {
            _errorMessage = 'Login failed. Please check your credentials.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() => _errorMessage = null);

    // Validate fields
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.signUp(email, password);
      
      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          setState(() {
            _errorMessage = 'Sign Up failed. Email might already be in use.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFFBF0)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text('🐝', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(_isLogin ? 'Welcome Back!' : 'Create an Account', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 6),
                Text(_isLogin ? 'Sign in to continue your journey' : 'Sign up to start your journey', style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(children: [
                            Icon(Icons.error_outline, color: Colors.red[400], size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 13))),
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],

                      const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'you@example.com', prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          filled: true, fillColor: const Color(0xFFF8F6F3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (_) { if (_errorMessage != null) setState(() => _errorMessage = null); },
                      ),
                      const SizedBox(height: 16),
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: '••••••••', prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                          filled: true, fillColor: const Color(0xFFF8F6F3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (_) { if (_errorMessage != null) setState(() => _errorMessage = null); },
                        onSubmitted: (_) => _isLogin ? _signIn() : _signUp(),
                      ),
                      const SizedBox(height: 8),
                      if (_isLogin) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _isLoading ? null : () {}, child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w600)))),
                      if (!_isLogin) const SizedBox(height: 35), // Spacer to balance when there is no forgot password
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), foregroundColor: const Color(0xFF1A1A2E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 4, shadowColor: const Color(0xFFFFC107).withAlpha(80)),
                          onPressed: _isLoading ? null : (_isLogin ? _signIn : _signUp),
                          child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1A1A2E)))
                            : Text(_isLogin ? 'Sign In' : 'Sign Up', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_isLogin ? "Don't have an account? " : "Already have an account? ", style: const TextStyle(color: Color(0xFF999999))),
                        TextButton(
                          onPressed: _isLoading ? null : () => setState(() { _isLogin = !_isLogin; _errorMessage = null; _emailController.clear(); _passwordController.clear(); }), 
                          child: Text(_isLogin ? 'Sign Up' : 'Sign In', style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w700))
                        ),
                      ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
