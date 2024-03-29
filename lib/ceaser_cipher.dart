class CaesarCipher {
  int shift;

  CaesarCipher(this.shift);

  // Function to encrypt a string using Caesar Cipher
  String encrypt(String text) {
    return String.fromCharCodes(text.runes.map((char) {
      if (char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0)) {
        return ((char - 'A'.codeUnitAt(0) + shift) % 26) + 'A'.codeUnitAt(0);
      } else if (char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0)) {
        return ((char - 'a'.codeUnitAt(0) + shift) % 26) + 'a'.codeUnitAt(0);
      } else {
        return char;
      }
    }));
  }

  // Function to decrypt a string using Caesar Cipher
  String decrypt(String text) {
    // Similar logic to encrypt, but subtract the shift instead
    return String.fromCharCodes(text.runes.map((char) {
      if (char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0)) {
        return ((char - 'A'.codeUnitAt(0) - shift + 26) % 26) +
            'A'.codeUnitAt(0); // Add 26 to handle negative shifts
      } else if (char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0)) {
        return ((char - 'a'.codeUnitAt(0) - shift + 26) % 26) +
            'a'.codeUnitAt(0); // Add 26 to handle negative shifts
      } else {
        return char;
      }
    }));
  }
}
