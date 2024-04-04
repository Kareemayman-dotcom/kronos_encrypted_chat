class RailFenceCipher {
  // Function for encryption
  int rails;
  RailFenceCipher({
    required this.rails,
  });
  String encrypt(String plainText) {
    String cipherText = '';
    bool goingDown = true;
    int row = 0;
    int col = 0;

    // Create a matrix to represent the rails
    List<List<String>> matrix =
        List.generate(rails, (i) => List.filled(plainText.length, ''));
    // Fill the matrix in a zig-zag pattern
    for (int i = 0; i < plainText.length; i++) {
      matrix[row][col] = plainText[i];
      if (goingDown) {
        row++;
      } else {
        row--;
      }

      if (row == rails - 1 || row == 0) {
        goingDown = !goingDown;
      }
      col++;
    }

    // Read the cipher text from the matrix row-wise
    for (int i = 0; i < rails; i++) {
      for (int j = 0; j < plainText.length; j++) {
        if (matrix[i][j] != '') {
          cipherText += matrix[i][j];
        }
      }
    }

    return cipherText;
  }

  // Function for decryption
  String decrypt(String cipherText) {
    String plainText = '';
    bool goingDown = true;
    int row = 0;
    int col = 0;

    // Create a matrix to represent the rails
    List<List<String>> matrix =
        List.generate(rails, (i) => List.filled(cipherText.length, ''));

    // Mark the positions where letters will be placed
    for (int i = 0; i < cipherText.length; i++) {
      matrix[row][col] = '*'; 
      if (goingDown) {
        row++;
      } else {
        row--;
      }

      if (row == rails - 1 || row == 0) {
        goingDown = !goingDown;
      }
      col++;
    }

    // Fill the plain text back into the matrix
    int index = 0;
    for (int i = 0; i < rails; i++) {
      for (int j = 0; j < cipherText.length; j++) {
        if (matrix[i][j] == '*' && index < cipherText.length) {
          matrix[i][j] = cipherText[index++];
        }
      }
    }

    // Read the plain text from the matrix row-wise
    row = 0;
    col = 0;
    goingDown = true;
    for (int i = 0; i < cipherText.length; i++) {
      plainText += matrix[row][col];
      if (goingDown) {
        row++;
      } else {
        row--;
      }

      if (row == rails - 1 || row == 0) {
        goingDown = !goingDown;
      }
      col++;
    }

    return plainText;
  }
}
