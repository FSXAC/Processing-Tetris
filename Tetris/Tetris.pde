int[][] board;

final int BOARD_HEIGHT = 20;
final int BOARD_WIDTH = 10;

final int CELL_EMPTY = 0;
final int CELL_PIECE_Z = 1;
final int CELL_PIECE_S = 2;
final int CELL_PIECE_L = 3;
final int CELL_PIECE_J = 4;
final int CELL_PIECE_O = 5;
final int CELL_PIECE_I = 6;
final int CELL_PIECE_T = 7;

final int level = 6;
final int[] LINE_SCORING = {40 * (level + 1), 100 * (level + 1), 300 * (level + 1), 1200 * (level + 1) };

final color[] PIECE_COLORS = {
 color(0),
 color(0, 0, 255),
 color(0, 255, 0),
 color(255, 0, 0),
 color(0, 255, 255),
 color(255, 0, 255),
 color(255, 255, 0),
 color(255, 255, 255)
};
// final color[] PIECE_COLORS = {
//   color(0),
//   color(200, 0, 0),
//   color(0, 0, 200),
//   color(0, 0, 200),
//   color(200, 0, 0),
//   color(80, 80, 255),
//   color(80, 80, 255),
//   color(80, 80, 255)
// };

Piece currentPiece;
Piece nextPiece;

boolean paused = false;

int score;
int[] blocks = { 0, 0, 0, 0, 0, 0, 0 };
int lines = 0;
int burned = 0;
int tetris = 0;
int drought = 0;

int flashCount = 0;

void setup() {
	size(320, 240);
  surface.setResizable(true);

	// setup board array
	board = new int[BOARD_HEIGHT][BOARD_WIDTH];
	for (int j = 0; j < BOARD_HEIGHT; j++) {
		for (int i = 0; i < BOARD_WIDTH; i++) {
			board[j][i] = CELL_EMPTY;
		}
	}

  for (int j = BOARD_HEIGHT-5; j < BOARD_HEIGHT; j++) {
		for (int i = 0; i < BOARD_WIDTH - 1; i++) {
			board[j][i] = CELL_PIECE_T;
		}
	}
  board[19][4] = CELL_EMPTY;
  board[19][9] = CELL_PIECE_T;
  
  // first piece
  // int genCurrentPiece = int(random(CELL_PIECE_T)) + 1;
  int genCurrentPiece = 6;
  nextPiece = new Piece(genCurrentPiece);
  generateNewPiece();
  
  score = 0;
  for (int i = 0; i < blocks.length; i++) {
    blocks[i] = 0;
  }
  lines = 0;
  burned = 0;
  tetris = 0;
  drought = 0;
}

void generateNewPiece() {
  currentPiece = nextPiece;

  if (currentPiece.type == CELL_PIECE_I) {
    drought = 0;
  } else {
    drought += 1;
  }

  blocks[currentPiece.type - 1] += 1;
  
  int genCurrentPiece = int(random(CELL_PIECE_T)) + 1;
  nextPiece = new Piece(genCurrentPiece);
}

// TODO: das
boolean leftKeyDown = false;
boolean rightKeyDown = false;
boolean downKeyDown = false;

void keyPressed() {
  if (key == ' ') {
    generateNewPiece();
  } else if (key == 'a') {
    currentPiece.left();
    // leftKeyDown = true;
  } else if (key == 'd') {
    currentPiece.right();
    // rightKeyDown = true;
  } else if (key == 's') {
    // currentPiece.update(board);
    downKeyDown = true;
  } else if (key == 'k') {
   currentPiece.rotateLeft();
  } else if (key == 'l') {
   currentPiece.rotateRight();
  } else if (key == 'r') {
    setup();
  } else if (key == 'p') {
    paused = !paused;
  }
}

void keyReleased() {
  if (key == 'a') {
    leftKeyDown = false;
  } else if (key == 'd') {
    rightKeyDown = false;
  } else if (key == 's') {
    downKeyDown = false;
  }
}

void draw() {
  if (paused) {
    textAlign(CENTER, CENTER);
    fill(255);
    text("PAUSED", width/2, height/2);
    return;
  }
  
  if (flashCount >= 0) {
    if (flashCount % 2 == 0)
      background(255);
    else
      background(0);
      flashCount -= 1;
    return;
  }
  
  background(0);

  drawBoard();
  drawNextPiece();

  // Draw score
  textSize(30);
  text(str(score), 0.8 * width, 0.3 * height);

  // Draw stats
  text("Z: " + str(blocks[0]), 0.25 * width, 100);
  text("S: " + str(blocks[1]), 0.25 * width, 130);
  text("L: " + str(blocks[2]), 0.25 * width, 160);
  text("J: " + str(blocks[3]), 0.25 * width, 190);
  text("O: " + str(blocks[4]), 0.25 * width, 220);
  text("I: " + str(blocks[5]), 0.25 * width, 250);
  text("T: " + str(blocks[6]), 0.25 * width, 280);
  text("Lines: " + str(lines), 0.5 * width, 30);

  // Draw other stats
  if (lines != 0) {
    text("TRT: " + str(100.0 * tetris / lines) + "%", 0.8 * width, 0.7 * height);
  }
  text("BRN: " + str(burned), 0.8 * width, 0.7 * height + 40);
  text("DRT: " + str(drought), 0.8 * width, 0.7 * height + 80);
}

void drawBoard() {
  int[][] displayBoard = currentPiece.getDisplayBoard(board);
  
  // calculate size
  final float cellSize = height / BOARD_HEIGHT;
  final float gridWidth = BOARD_WIDTH * cellSize;
  final float gridLeft = (width - gridWidth) * 0.5;
  
  // Debug stroke
  strokeWeight(6);
  stroke(255);
  line(gridLeft - 3, 0, gridLeft - 3, height);
  line(gridLeft + BOARD_WIDTH * cellSize + 3, 0, gridLeft + BOARD_WIDTH * cellSize + 3, height);
  stroke(100);
  strokeWeight(1);
  
  pushMatrix();
  
  // board
  translate(gridLeft, 0);
  for (int y = 0; y < BOARD_HEIGHT; y++) {
    for (int x = 0; x < BOARD_WIDTH; x++) {
      fill(PIECE_COLORS[displayBoard[y][x]]);
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
  
  // piece control
  if (frameCount % 4 == 0) {
    if (leftKeyDown) {
      currentPiece.left();
    }

    if (rightKeyDown) {
      currentPiece.right();
    }

    if (downKeyDown) {
      currentPiece.update(board);
    }
  }


  // Piece update
  // Speed is here
  if (frameCount % 30 == 0) {
    if (currentPiece.update(board)) {
      checkAndClearBoard(board);

      generateNewPiece();
    }
  }

  popMatrix();
}

void drawNextPiece() {
  pushMatrix();
  translate(0.8 * width, 0.5 * height);
  nextPiece.drawAsNext();
  popMatrix();
}

void checkAndClearBoard(int[][] board) {

  int streak = 0;
  for (int y = 0; y < BOARD_HEIGHT; y++) {

    // check each line is empty
    boolean lineFull = true;
    for (int x = 0; x < BOARD_WIDTH; x++) {
      if (board[y][x] == CELL_EMPTY) {
        lineFull = false;

        // FIXME: add points here
        break;
      }
    }

    if (lineFull) {
      shiftdown(board, y);
      streak += 1;
    }
  }

  if (streak != 0) {
    score += LINE_SCORING[streak - 1];

    if (streak == 4) {
      flashCount = 10;
      tetris += 4;
      burned = 0;
    } else {
      burned += streak;
    }

    lines += streak;
  }
}

void shiftdown(int[][] board, int line) {
  // Shift down all the cells in the grid by one line starting from the line specified
  for (int l = line; l - 1 >= 0; l--) {
    for (int x = 0; x < BOARD_WIDTH; x++) {
      board[l][x] = board[l - 1][x];
    }
  }
  for (int x = 0; x < BOARD_WIDTH; x++) {
    board[0][x] = CELL_EMPTY;
  }
}
