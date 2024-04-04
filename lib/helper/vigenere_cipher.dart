class VigenereCipher {
  // Function for encryption
  String encrypt(String text, String key) {
    String cipherText = '';
    int keyIndex = 0;

    for (int i = 0; i < text.length; i++) {
      int shift = (key.codeUnitAt(keyIndex % key.length) - 97); // 'a'=97
      int charCode = (text.codeUnitAt(i) + shift - 97) % 26 + 97;
      cipherText += String.fromCharCode(charCode);
      keyIndex++;
    }

    return cipherText;
  }

  // Function for decryption
  String decrypt(String cipherText, String key) {
    String plainText = '';
    int keyIndex = 0;

    for (int i = 0; i < cipherText.length; i++) {
      int shift = (key.codeUnitAt(keyIndex % key.length) - 97); // 'a'=97
      int charCode = (cipherText.codeUnitAt(i) - shift - 97 + 26) % 26 + 97;
      plainText += String.fromCharCode(charCode);
      keyIndex++;
    }

    return plainText;
  }
}
