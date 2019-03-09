final int[][][] Z_STATES = {
  {{0, 0}, {-1, 0}, {0, 1}, {1, 1}},
  {{0, 0}, {1, 0}, {0, 1}, {1, -1}}
};

final int[][][] S_STATES = {
  {{0, 0}, {0, 1}, {-1, 1}, {1, 0}},
  {{0, 0}, {0, -1}, {1, 0}, {1, 1}}
};

final int[][][] L_STATES = {
  {{0, 0}, {-1, 0}, {1, 0}, {-1, 1}},
  {{0, 0}, {0, 1}, {0, -1}, {-1, -1}},
  {{0, 0}, {-1, 0}, {1, 0}, {1, -1}},
  {{0, 0}, {0, 1}, {0, -1}, {1, 1}}
};

final int[][][] J_STATES = {
  {{0, 0}, {-1, 0}, {1, 0}, {1, 1}},
  {{0, 0}, {0, 1}, {0, -1}, {-1, 1}},
  {{0, 0}, {-1, 0}, {1, 0}, {-1, -1}},
  {{0, 0}, {0, 1}, {0, -1}, {1, -1}}
};

final int[][][] O_STATES = {
  {{0, 0}, {0, 1}, {-1, 0}, {-1, 1}}
};

final int[][][] I_STATES = {
  {{0, 0}, {-1, 0}, {-2, 0}, {1, 0}},
  {{0, 0}, {0, 1}, {0, 2}, {0, -1}}
};

final int[][][] T_STATES = {
  {{0, 0}, {-1, 0}, {1, 0}, {0, 1}},
  {{0, 0}, {0, -1}, {0, 1}, {-1, 0}},
  {{0, 0}, {-1, 0}, {1, 0}, {0, -1}},
  {{0, 0}, {0, -1}, {0, 1}, {1, 0}}
};

class Piece {
  int type;
  int [][][] blocks;
  int state;
  int x;
  int y;
  boolean primed = false;

  Piece(int type) {
    this.type = type;
    this.state = 0;
    
    switch (type) {
      case CELL_PIECE_Z:
        this.blocks = Z_STATES;
        break;
      case CELL_PIECE_S:
        this.blocks = S_STATES;
        break;
      case CELL_PIECE_L:
        this.blocks = L_STATES;
        this.y = 1;
        break;
      case CELL_PIECE_J:
        this.blocks = J_STATES;
        this.y = 1;
        break;
      case CELL_PIECE_O:
        this.blocks = O_STATES;
        break;
      case CELL_PIECE_I:
        this.blocks = I_STATES;
        break;
      case CELL_PIECE_T:
        this.blocks = T_STATES;
        break;
    }
    
    this.x = BOARD_WIDTH / 2;
  }
  
  int[][] getDisplayBoard(int[][] board) {
    int[][] displayBoard = new int[BOARD_HEIGHT][BOARD_WIDTH];
    
    // copy arrays
    for (int y = 0; y < BOARD_HEIGHT; y++) {
      for (int x = 0; x < BOARD_WIDTH; x++) {
        displayBoard[y][x] = board[y][x];
      }
    }
    
    for (int b = 0; b < 4; b++) {
      final int x = this.x + this.blocks[state][b][0];
      final int y = this.y + this.blocks[state][b][1];
      
      if (x >= 0 && x < BOARD_WIDTH && y >= 0 && y < BOARD_HEIGHT) {
        displayBoard[y][x] = this.type;
      }
    }
    return displayBoard;
  }
  
  void drawAsNext() {
    fill(PIECE_COLORS[this.type]);
    final float size = height / BOARD_HEIGHT;
    for (int b = 0; b < 4; b++) {
      final int x = this.blocks[state][b][0];
      final int y = this.blocks[state][b][1];
      rect(x * size, y * size, size, size);
    }
  }
  
  boolean update(int[][] board) {

    // Check surrounding
    boolean canMoveDown = true;
    for (int b = 0; b < 4; b++) {
      final int x = this.x + this.blocks[state][b][0];
      final int y = this.y + this.blocks[state][b][1];

      if (y >= BOARD_HEIGHT - 1) {
        canMoveDown = false;
        break;
      }

      if (board[y + 1][x] != CELL_EMPTY) {
        canMoveDown = false;
        break;
      }
    }

    if (canMoveDown) {
      this.y += 1;
      this.primed = false;
    } else {
      if (this.primed) {
        lockPiece(board);
        return true;
      } else {
        this.primed = true;
      }
    }

    return false;
  }

  void lockPiece(int[][] board) {
    for (int b = 0; b < 4; b++) {
      final int x = this.x + this.blocks[state][b][0];
      final int y = this.y + this.blocks[state][b][1];
      
      if (x >= 0 && x < BOARD_WIDTH && y >= 0 && y < BOARD_HEIGHT) {
        board[y][x] = this.type;
      }
    }
  }

  void right() {
    for (int b = 0; b < 4; b++) {
      final int x = this.x + this.blocks[state][b][0];
      final int y = constrain(this.y + this.blocks[state][b][1], 0, BOARD_HEIGHT - 1);
      if (x >= BOARD_WIDTH - 1) {
        return;
      }

      if (board[y][x + 1] != CELL_EMPTY) {
        return;
      }
    }

    this.x += 1;
  }
  
  void left() {
    for (int b = 0; b < 4; b++) {
      final int x = this.x + this.blocks[state][b][0];
      final int y = constrain(this.y + this.blocks[state][b][1], 0, BOARD_HEIGHT - 1);
      if (x <= 0) {
        return;
      }

      if (board[y][x - 1] != CELL_EMPTY) {
        return;
      }
    }

    this.x -= 1;
  }
  
  void rotateLeft() {
    int next = this.state;
    if (this.state == 0) {
      next = this.blocks.length - 1;
    } else {
      next -= 1;
    }

    for (int b = 0; b < 4; b++) {
      final int x = this.x + this.blocks[next][b][0];
      int y = this.y + this.blocks[next][b][1];

      if (y < 0) {
        y = 0;
      }

      // Check if coords is out or occupied
      if (x < 0 || x > BOARD_WIDTH - 1 || y > BOARD_HEIGHT - 1) {
        return;
      }

      if (board[y][x] != CELL_EMPTY) {
        return;
      }
    }

    this.state = next;
  }
  
  void rotateRight() {
    int next = this.state;
    if (this.state == this.blocks.length - 1) {
      next = 0;
    } else {
      next += 1;
    }

    for (int b = 0; b < 4; b++) {
      final int x = this.x + this.blocks[next][b][0];
      int y = this.y + this.blocks[next][b][1];

      if (y < 0) {
        y = 0;
      }

      // Check if coords is out or occupied
      if (x < 0 || x > BOARD_WIDTH - 1 || y > BOARD_HEIGHT - 1) {
        return;
      }

      if (board[y][x] != CELL_EMPTY) {
        return;
      }
    }

    this.state = next;
  }
}
