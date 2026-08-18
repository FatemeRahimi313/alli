import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const LockScreen({super.key, required this.onAuthenticated});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  bool _showPinPad = false;
  String? _error;
  bool _loading = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final settings = ref.read(settingsProvider);
    if (!settings.biometricEnabled) {
      setState(() => _showPinPad = true);
      return;
    }

    setState(() => _loading = true);
    final auth = ref.read(authServiceProvider);
    final success = await auth.authenticate();
    setState(() => _loading = false);

    if (success) {
      HapticFeedback.mediumImpact();
      widget.onAuthenticated();
    } else {
      setState(() {
        _showPinPad = true;
        _error = 'بیومتریک ناموفق. پین وارد کنید.';
      });
    }
  }

  Future<void> _submitPin() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'پین حداقل ۴ رقم باشد');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = ref.read(authServiceProvider);
    final hasPin = await auth.hasPin();

    if (!hasPin) {
      // first time setup
      await auth.setPin(pin);
      HapticFeedback.mediumImpact();
      widget.onAuthenticated();
      return;
    }

    final ok = await auth.verifyPin(pin);
    setState(() => _loading = false);

    if (ok) {
      HapticFeedback.mediumImpact();
      widget.onAuthenticated();
    } else {
      _attempts++;
      _pinController.clear();
      setState(() {
        _error = _attempts >= 3
            ? 'تلاش‌های متعدد ناموفق. کمی صبر کنید.'
            : 'پین اشتباه است';
      });
      if (_attempts >= 3) {
        await Future.delayed(const Duration(seconds: 5));
        _attempts = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.militaryBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 72, color: AppColors.militaryGreen),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'چله‌بان',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.militaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'برای ادامه احراز هویت کنید',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (_loading)
                  const CircularProgressIndicator(color: AppColors.militaryGreen)
                else if (!_showPinPad)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _tryBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('اثر انگشت / چهره'),
                    ),
                  )
                else ...[
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 12,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '••••',
                    ),
                    onSubmitted: (_) => _submitPin(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitPin,
                      child: const Text('تأیید'),
                    ),
                  ),
                  TextButton(
                    onPressed: _tryBiometric,
                    child: const Text('تلاش مجدد بیومتریک'),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.alertRed),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
