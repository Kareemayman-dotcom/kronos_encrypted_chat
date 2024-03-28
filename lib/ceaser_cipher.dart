class CaesarCipher {
  int _shift;

  CaesarCipher(this._shift);

  String encrypt(String plainText) {
    String result = '';

    for (int i = 0; i < plainText.length; i++) {
      var char = plainText.codeUnitAt(i);

      // Handle uppercase letters
      if (char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0)) {
        result += String.fromCharCode(
            ((char - 'A'.codeUnitAt(0) + _shift) % 26) + 'A'.codeUnitAt(0));

        // Handle lowercase letters
      } else if (char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0)) {
        result += String.fromCharCode(
            ((char - 'a'.codeUnitAt(0) + _shift) % 26) + 'a'.codeUnitAt(0));

        // Preserve other characters
      } else {
        result += plainText[i];
      }
    }

    return result;
  }

  String decrypt(String cipherText) {
    String result = '';

    for (int i = 0; i < cipherText.length; i++) {
      var char = cipherText.codeUnitAt(i);

      if (char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0)) {
        result += String.fromCharCode(
            ((char - 'A'.codeUnitAt(0) - _shift) % 26) + 'A'.codeUnitAt(0));
      } else if (char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0)) {
        result += String.fromCharCode(
            ((char - 'a'.codeUnitAt(0) - _shift) % 26) + 'a'.codeUnitAt(0));
      } else {
        result += cipherText[i];
      }
    }

    return result;
  }
}
