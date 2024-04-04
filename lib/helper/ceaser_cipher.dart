class CaesarCipher {
  int shift;

  CaesarCipher(this.shift);

  // Helper function to encrypt/decrypt a single character within a range
  int _transformChar(int char, int base, int shift) {
    return ((char - base + shift) % 26) + base;
  }

  String encrypt(String text) {
    return String.fromCharCodes(text.runes.map((char) {
      if (char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0)) {
        return _transformChar(char, 'A'.codeUnitAt(0), shift);
      } else if (char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0)) {
        return _transformChar(char, 'a'.codeUnitAt(0), shift);
      } else if (char >= '0'.codeUnitAt(0) && char <= '9'.codeUnitAt(0)) {
        return _transformChar(char, '0'.codeUnitAt(0), shift);
      } else {
        // Assume symbols in the range '!' (33) to '/' (47):
        if (char >= 33 && char <= 47) {
          return _transformChar(char, 33, shift);
        } else {
          return char; // Leave other characters unchanged
        }
      }
    }));
  }

  String decrypt(String text) {
    return String.fromCharCodes(text.runes.map((char) {
      if (char >= 'A'.codeUnitAt(0) && char <= 'Z'.codeUnitAt(0)) {
        return _transformChar(char, 'A'.codeUnitAt(0), -shift + 26);
      } else if (char >= 'a'.codeUnitAt(0) && char <= 'z'.codeUnitAt(0)) {
        return _transformChar(char, 'a'.codeUnitAt(0), -shift + 26);
      } else if (char >= '0'.codeUnitAt(0) && char <= '9'.codeUnitAt(0)) {
        return _transformChar(char, '0'.codeUnitAt(0), -shift + 26);
      } else {
        // Assume symbols in the range '!' (33) to '/' (47):
        if (char >= 33 && char <= 47) {
          return _transformChar(char, 33, -shift + 26);
        } else {
          return char; // Leave other characters unchanged
        }
      }
    }));
  }
}
