class Hatalar {
  static String goster(String exceptionCode) {
    switch (exceptionCode) {
      case "email-already-in-use":
        return "Bu mail zaten kayıtlı. Lütfen farklı bir mail adresi ile tekrar deneyin.";
        break;
      case "wrong-password":
        return "Email veya Şifre Hatalı. Lütfen Tekrar Dene.";
        break;
      case "user-not-found":
        return "Email veya Şifre Hatalı. Lütfen Tekrar Dene.";
        break;
      default:
        return "Beklenmedik bir hata oluştu.";
    }
  }
}
