class ErrorHandler {
  // Kullanıcı dostu hata mesajları
  static String getUserFriendlyErrorMessage(String error) {
    // E-posta ile ilgili hatalar
    if (error.contains('Invalid email')) {
      return '❌ Geçersiz e-posta adresi! Lütfen doğru formatta e-posta girin.';
    }
    if (error.contains('User not found')) {
      return '❌ Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı!';
    }
    if (error.contains('User already registered')) {
      return '❌ Bu e-posta adresi zaten kayıtlı! Giriş yapmayı deneyin.';
    }
    
    // Şifre ile ilgili hatalar
    if (error.contains('Invalid password')) {
      return '❌ Yanlış şifre! Lütfen şifrenizi kontrol edin.';
    }
    if (error.contains('Password should be at least')) {
      return '❌ Şifre en az 6 karakter olmalıdır!';
    }
    if (error.contains('Password is too weak')) {
      return '❌ Şifre çok zayıf! Daha güçlü bir şifre seçin.';
    }
    
    // Kullanıcı adı ile ilgili hatalar
    if (error.contains('Username already taken')) {
      return '❌ Bu kullanıcı adı zaten alınmış! Başka bir kullanıcı adı seçin.';
    }
    if (error.contains('Username too short')) {
      return '❌ Kullanıcı adı en az 3 karakter olmalıdır!';
    }
    
    // Ağ bağlantısı hataları
    if (error.contains('network') || error.contains('connection')) {
      return '❌ İnternet bağlantınızı kontrol edin!';
    }
    if (error.contains('timeout')) {
      return '❌ Bağlantı zaman aşımı! Lütfen tekrar deneyin.';
    }
    
    // Hesap durumu hataları
    if (error.contains('Email not confirmed')) {
      return '❌ E-posta adresinizi onaylamanız gerekiyor!';
    }
    if (error.contains('Too many requests')) {
      return '❌ Çok fazla deneme! Lütfen birkaç dakika sonra tekrar deneyin.';
    }
    if (error.contains('Account disabled')) {
      return '❌ Hesabınız devre dışı bırakılmış!';
    }
    
    // Veritabanı hataları
    if (error.contains('duplicate key')) {
      return '❌ Bu bilgiler zaten kullanılıyor! Farklı bilgiler deneyin.';
    }
    if (error.contains('constraint')) {
      return '❌ Girdiğiniz bilgilerde hata var! Lütfen kontrol edin.';
    }
    
    // Genel hatalar
    if (error.contains('Invalid credentials')) {
      return '❌ E-posta veya şifre hatalı!';
    }
    if (error.contains('Email rate limit')) {
      return '❌ Çok fazla e-posta gönderildi! Lütfen bekleyin.';
    }
    
    // Bilinmeyen hatalar için
    return '❌ İşlem başarısız! Lütfen bilgilerinizi kontrol edin.';
  }
}
