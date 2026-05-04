import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/state/app_state.dart';
import '../../core/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _passController.dispose();
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> loginWithUniversityId({
    required String universityId,
    required String password,
  }) async {
    Map<String, dynamic>? data;

    // 1. جرب تجيبه بالـ doc_id مباشرة (أسرع)
    final docSnap =
        await _firestore.collection('users').doc(universityId).get();

    if (docSnap.exists) {
      data = docSnap.data();
    } else {
      // 2. جرب بالـ field كـ string
      final q1 = await _firestore
          .collection('users')
          .where('university_id', isEqualTo: universityId)
          .limit(1)
          .get();

      if (q1.docs.isNotEmpty) {
        data = q1.docs.first.data();
      } else {
        // 3. جرب بالـ field كـ int
        final universityIdInt = int.tryParse(universityId);
        if (universityIdInt != null) {
          final q2 = await _firestore
              .collection('users')
              .where('university_id', isEqualTo: universityIdInt)
              .limit(1)
              .get();
          if (q2.docs.isNotEmpty) {
            data = q2.docs.first.data();
          }
        }
      }
    }

    if (data == null) return null;

    final storedPassword = data['password']?.toString() ?? '';
    if (storedPassword != password) return null;

    return data;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _performLogin() async {
    final appState = AppState.instance;
    final universityId = _idController.text.trim();
    final password = _passController.text.trim();

    if (universityId.isEmpty || password.isEmpty) {
      _showMessage('الرجاء إدخال الرقم الجامعي وكلمة المرور.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userData = await loginWithUniversityId(
        universityId: universityId,
        password: password,
      );

      if (!mounted) return;

      if (userData == null) {
        _showMessage('الرقم الجامعي أو كلمة المرور غير صحيحة.');
        return;
      }

      final roleStr = userData['role'] as String? ?? 'student';
      final role =
          roleStr == 'instructor' ? UserRole.supervisor : UserRole.student;

      appState.login(
        role: role,
        userId: userData['university_id']?.toString(),
        userName: userData['name']?.toString(),
      );

      if (role == UserRole.supervisor) {
        context.go(AppRouter.dashboard);
      } else {
        context.go(AppRouter.home);
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        return Scaffold(
          backgroundColor: AppColors.bgLight,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight:
                            size.height - MediaQuery.of(context).padding.top),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.fromLTRB(24, 36, 24, 28),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 88,
                                      height: 88,
                                      decoration: BoxDecoration(
                                        color: AppColors.bgWhite,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.darkNavy
                                                .withValues(alpha: 0.12),
                                            blurRadius: 24,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        'assest/logo/363331987_257713613788245_2395123892953238221_n 1.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        fontFamily: 'Zain',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'بوابة جامعة 6 أكتوبر التكنولوجية',
                                      style: TextStyle(
                                        fontFamily: 'Zain',
                                        fontSize: 14,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.bgWhite,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _RoleSelector(
                                      role: appState.role,
                                      onChanged: (r) => appState.setRole(r),
                                    ),
                                    const SizedBox(height: 24),

                                    _FieldLabel(label: 'الرقم الجامعي'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _idController,
                                      hint: 'أدخل الرقم الجامعي فقط',
                                      prefixIcon: Icons.person_outline_rounded,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'سيتم تحويل الرقم الجامعي إلى بريد @6otu.edu تلقائياً.',
                                      style: TextStyle(
                                        fontFamily: 'Zain',
                                        fontSize: 12,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Password Field
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const _FieldLabel(label: 'كلمة المرور'),
                                        TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'نسيت كلمة المرور؟',
                                            style: TextStyle(
                                              fontFamily: 'Zain',
                                              fontSize: 13,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPasswordField(),
                                    const SizedBox(height: 16),

                                    // ── Remember me
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'تذكرني على هذا الجهاز',
                                          style: TextStyle(
                                            fontFamily: 'Zain',
                                            fontSize: 14,
                                            color: AppColors.textMedium,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Switch(
                                          value: appState.rememberMe,
                                          onChanged: (v) =>
                                              appState.setRememberMe(v),
                                          activeThumbColor: AppColors.bgWhite,
                                          activeTrackColor: AppColors.primary,
                                          inactiveThumbColor: AppColors.bgWhite,
                                          inactiveTrackColor: AppColors.border,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    if (_errorMessage.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Text(
                                          _errorMessage,
                                          style: const TextStyle(
                                            fontFamily: 'Zain',
                                            fontSize: 13,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),

                                    _LoginButton(
                                      isLoading: _isLoading,
                                      onPressed: _performLogin,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'هل تواجه مشكلة في الدخول؟',
                                style: TextStyle(
                                  fontFamily: 'Zain',
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _HelpChip(
                                      icon: Icons.help_outline,
                                      label: 'الدعم الفني'),
                                  const SizedBox(width: 12),
                                  _HelpChip(
                                      icon: Icons.phone_outlined,
                                      label: 'اتصل بنا'),
                                ],
                              ),
                              const SizedBox(height: 32),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                                child: Text(
                                  '© 2024 6TH OF OCTOBER TECHNOLOGICAL UNIVERSITY | ACADEMIC ATTENDANCE SYSTEMS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Zain',
                                    fontSize: 9,
                                    color: AppColors.textGrey,
                                    letterSpacing: 0.5,
                                    height: 1.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: Icon(prefixIcon, color: AppColors.textGrey, size: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _passController,
        obscureText: _obscurePass,
        textDirection: TextDirection.rtl,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: '••••••••',
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: AppColors.textGrey, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textGrey,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
      ),
    );
  }
}

// ── Role Selector ─────────────────────────────────────────────────────────────
class _RoleSelector extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  const _RoleSelector({required this.role, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'طالب',
            isActive: role == UserRole.student,
            onTap: () => onChanged(UserRole.student),
          ),
          _Tab(
            label: 'مشرف',
            isActive: role == UserRole.supervisor,
            onTap: () => onChanged(UserRole.supervisor),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Zain',
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Field Label ────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Zain',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

// ── Login Button ─────────────────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [
                    AppColors.primary.withValues(alpha: 0.7),
                    AppColors.primaryDark.withValues(alpha: 0.7)
                  ]
                : [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textDark,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontFamily: 'Zain',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.login_rounded,
                        color: AppColors.textDark, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Help Chip ─────────────────────────────────────────────────────────────────
class _HelpChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HelpChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMedium),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Zain',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
