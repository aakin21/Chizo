import 'package:flutter/material.dart';

class WinRateColors {
  /// Progress bar için gradient renkleri döndürür
  static List<Color> getProgressBarColors(double winRate) {
    final progress = winRate;
    
    // Tamamen smooth renk geçişi - sadece 2 aralık
    if (progress <= 0.0) {
      return [Colors.yellow[300]!, Colors.yellow[300]!];
    } else if (progress <= 0.65) {
      // 0-65% arası aynı turuncu ton
      return [Colors.yellow[300]!, Colors.orange[700]!];
    } else {
      // 65%+ kırmızı
      return [Colors.yellow[300]!, Colors.red[600]!];
    }
  }

  /// Progress bar için gradient renkleri döndürür (winRate 0-100 arası)
  static List<Color> getProgressBarColorsFromPercentage(double winRate) {
    return getProgressBarColors(winRate / 100.0);
  }

  /// Avatar çerçevesi için tek renk döndürür (progress bar'ın son rengi)
  static Color getBorderColor(double winRate) {
    final colors = getProgressBarColors(winRate);
    return colors.last; // Gradient'in son rengi
  }

  /// Avatar çerçevesi için tek renk döndürür (winRate 0-100 arası)
  static Color getBorderColorFromPercentage(double winRate) {
    return getBorderColor(winRate / 100.0);
  }

  /// Yeni fotoğraflar için özel renk (henüz maç yapmamış)
  static Color getNewPhotoColor() {
    return Colors.blue[500]!;
  }
}
