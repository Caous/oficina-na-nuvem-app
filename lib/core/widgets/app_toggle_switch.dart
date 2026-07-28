import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Interruptor em pílula com botão deslizante, conforme o design.
///
/// Substitui o `Switch` do Material para manter as cores e as proporções do
/// aplicativo, e anima a troca de estado.
class AppToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Cor da trilha quando ligado.
  final Color activeColor;

  const AppToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = AppColors.accentBlue,
  });

  static const double _width = 46;
  static const double _height = 26;
  static const double _knob = 20;
  static const double _padding = 3;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;

    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: isEnabled ? () => onChanged?.call(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: value ? activeColor : AppColors.gray300,
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _padding),
              child: Container(
                width: _knob,
                height: _knob,
                decoration: const BoxDecoration(
                  color: AppColors.bgWhite,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
