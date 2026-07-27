import 'package:flutter/material.dart';

/// Paleta do design (`design_oficina_nuvem.pen`).
///
/// Espelha as variáveis de cor do arquivo de design. Nenhum widget deve
/// declarar cores literais: sempre referenciar esta classe.
abstract final class AppColors {
  static const Color accentBlue = Color(0xFF4A9FE8);
  static const Color accentBlueDark = Color(0xFF2B7DD4);
  static const Color accentBlueLight = Color(0xFFE8F4FD);

  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentGreenLight = Color(0xFFECFDF5);

  static const Color accentRed = Color(0xFFE53E3E);
  static const Color accentRedDark = Color(0xFFC53030);
  static const Color accentRedLight = Color(0xFFFEE2E2);

  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberLight = Color(0xFFFEF3C7);

  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleLight = Color(0xFFF3E8FF);

  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF4F7FA);
  static const Color bgCard = Color(0xFFF6F8FB);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray700 = Color(0xFF374151);
}
