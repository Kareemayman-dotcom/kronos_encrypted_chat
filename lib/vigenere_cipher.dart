class VigenereCipher {
  String _key;

  VigenereCipher(this._key);

  String encrypt(String plainText) {
    plainText = plainText.toUpperCase();
    _key = _key.toUpperCase();

    String cipherText = "";
    int keyIndex = 0;

    for (int i = 0; i < plainText.length; i++) {
      int charCode = plainText.codeUnitAt(i);
      if (charCode >= 'A'.codeUnitAt(0) && charCode <= 'Z'.codeUnitAt(0)) {
        int shift = _key.codeUnitAt(keyIndex % _key.length) - 'A'.codeUnitAt(0);
        charCode =
            ((charCode - 'A'.codeUnitAt(0) + shift) % 26) + 'A'.codeUnitAt(0);
        keyIndex++;
      }
      cipherText += String.fromCharCode(charCode);
    }
    return cipherText;
  }

  String decrypt(String cipherText) {
    cipherText = cipherText.toUpperCase();
    _key = _key.toUpperCase();

    String plainText = "";
    int keyIndex = 0;

    for (int i = 0; i < cipherText.length; i++) {
      int charCode = cipherText.codeUnitAt(i);
      if (charCode >= 'A'.codeUnitAt(0) && charCode <= 'Z'.codeUnitAt(0)) {
        int shift = _key.codeUnitAt(keyIndex % _key.length) - 'A'.codeUnitAt(0);
        charCode = ((charCode - 'A'.codeUnitAt(0) - shift + 26) % 26) +
            'A'.codeUnitAt(0);
        keyIndex++;
      }
      plainText += String.fromCharCode(charCode);
    }
    return plainText;
  }
}
