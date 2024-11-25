import processing.sound.*;
import processing.video.*;

// FONT
PFont myFont;

// SOUND
SoundFile mySound;
SoundFile collectSound; 
SoundFile missedSound;
SoundFile winSound;
SoundFile loseSound;
SoundFile enterSound;

// IMAGES/BACKGROUND
Movie myMovie;
PImage bucketImage;
PImage trashImage; 

// FOR TITLE SCREEN
int numBubbles = 20; 
float[] bubblesX = new float[numBubbles];
float[] bubblesY = new float[numBubbles];
float[] speed = new float[numBubbles];
String state = "title";
boolean soundPlayed = false; // Sound plays once

// FOR GAME MECH
int gameStartTime; //Init timer for intrusctions to be displayed
boolean instructionsDisplayed = true;
float instructionOpacity = 255;

Bucket myCharacter;
Trash[] myTrash = new Trash[30];
boolean[] trashActive = new boolean[30];  
boolean[] trashMissed = new boolean[30];  
int score = 0;  // Init score as 0
int missed = 0; // Init missed as 0

void setup() {
  size(800, 800);
  myFont = createFont("data/PixelPowerline-11Mg.ttf", 100);
  textFont(myFont);
  noStroke();
  
// BACKGROUND MUSIC PLAY
  mySound = new SoundFile(this, "Aquatic_Amb.mp3");
  mySound.loop(); // Play the sound file in a loop
  
// LOAD IN ALL SFX
  collectSound = new SoundFile(this, "Coin.mov"); 
  missedSound = new SoundFile(this, "Trash_Floor.mov");
  winSound = new SoundFile(this, "Win.mp3");
  loseSound = new SoundFile(this, "Lose.mp3");
  enterSound = new SoundFile(this, "Enter.mp3");
  
// LOAD IN IMAGES
  bucketImage = loadImage("data/seamoth.png"); // Ensure this image is in the 'data' folder
  trashImage = loadImage("data/trash.png");    // Ensure this image is in the 'data' folder

// LOAD IN BACKGROUND
  myMovie = new Movie(this, "Okeanos_Bkg.mp4");
  myMovie.loop();
  
  float minX = 20;  // Minimum x-coordinate for trash
  float maxX = 780; // Maximum x-coordinate for trash

// TRASH INIT
  for (int i = 0; i < myTrash.length; i++) {
    myTrash[i] = new Trash(random(minX, maxX), -20, random(1, 3));  // Randomized placing each different run
    trashActive[i] = false;  
    trashMissed[i] = false;  
  }
  
// BUCKET INIT
  myCharacter = new Bucket(width / 2, height - 50, 150, 150);
  
// TITLE SCREEN BUBBLES
  for (int i = 0; i < numBubbles; i++) {
    bubblesX[i] = random(width);
    bubblesY[i] = random(height);
    speed[i] = random(0.2, 1); // Slower speeds for each bubble
  }
}

void draw() {
  if (state == "title") {
    titleScreen();
  } else if (state == "game") {
    gameScene();
  } else if (state == "win") {
    winScreen();
  } else if (state == "lose") {
    loseScreen();
  }
}

void titleScreen() {
  color color1;
  color color2;
  float transitionAmount = 0.0;
  int transitionSpeed = 4000;

// Breathing Background
  color1 = color(1, 21, 38);
  color2 = color(1, 46, 64);
  transitionAmount = (sin(millis() / float(transitionSpeed) * TWO_PI) + 1) / 2;
  color currentColor = lerpColor(color1, color2, transitionAmount);

  background(currentColor);

  textAlign(CENTER, CENTER);
  textSize(80);
  fill(156, 193, 217, 50);
  text("OKEANOS", width / 2, height / 2 - 50); 
  textSize(35);
  text("Press The ENTER Key To Start", width / 2, 450); 

  for (int i = 0; i < numBubbles; i++) {
    fill(235, 239, 242, 50);
    noStroke();
    ellipse(bubblesX[i], bubblesY[i], 10, 10);
    bubblesY[i] -= speed[i];
    
    if (bubblesY[i] < 0) {
      bubblesY[i] = height;
      bubblesX[i] = random(width); 
    }
  }
}

void gameScene() {
    image(myMovie, 0, 0);

// DISPLAY SCORE/MISSED, different colors for actual number though
    textSize(20);
    textAlign(LEFT, TOP);


    fill(255); 
    text("COLLECTED: ", 10, 10);

    fill(255, 215, 0); // Gold 
    text(score, 137, 10); 

    fill(255);
    text("MISSED: ", 10, 40);

    fill(205, 127, 50); // Bronze 
    text(missed, 100, 40); 

    // TIMER FOR INSTRUCTIONS FOR INSTRUCTIONS
    int elapsedTime = millis() - gameStartTime;

    // After 4 seconds, fade out, trash starts to fall
    if (elapsedTime < 4000) {
        instructionOpacity = map(elapsedTime, 0, 4000, 255, 0);
        fill(1, 46, 64, instructionOpacity); 
        textAlign(CENTER, CENTER);
        textSize(30);
        text("Use the cursor to catch the trash", width / 2, height / 2 - 100);
        text("Don't let the trash hit the ocean floor!", width / 2, height / 2 - 50);
    }

    // Put a delay on trash to wait for intrusctions
    if (elapsedTime > 3000) {
        myCharacter.update();       
        myCharacter.display();      

        // Activate and update trash objects
        if (frameCount % 60 == 0 && random(1) > 0.5) {
            for (int i = 0; i < myTrash.length; i++) {
                if (!trashActive[i] && !trashMissed[i]) {
                    trashActive[i] = true;
                    break;
                }
            }
        }

        for (int i = 0; i < myTrash.length; i++) {
            if (trashActive[i]) {
                myTrash[i].update();
                myTrash[i].display();
                
                // Collision between trash and bucket
                if (myCharacter.catches(myTrash[i])) {
                    trashActive[i] = false;  
                    score++;  
                    collectSound.play(); 
                    println("Score: " + score);  
                    myTrash[i].reset();  
                } else if (myTrash[i].ypos > 735) { 
                    missed++;
                    missedSound.play();
                    trashMissed[i] = true;  
                    println("Missed: " + missed);  
                    trashActive[i] = false;
                }
            }
        }

        // Let trash sit on the bottom of the screen
        for (int i = 0; i < myTrash.length; i++) {
            if (trashMissed[i]) {
                myTrash[i].display();  
            }
        }

        // Conditions for win or lose
        if (score == 15) {
            state = "win";  
            println("You Win!");
            soundPlayed = false;
        } else if (missed > 4) {
            state = "lose";  
            println("You Lose!");
            soundPlayed = false;
        }
    }
}

void winScreen() {
  if (!soundPlayed) {
    winSound.play();
    soundPlayed = true;
  }

  color color1;
  color color2;
  float transitionAmount = 0.0;
  int transitionSpeed = 4000;

  // Breathing Background
  color1 = color(1, 28, 65);
  color2 = color(0, 6, 13);
  transitionAmount = (sin(millis() / float(transitionSpeed) * TWO_PI) + 1) / 2;
  color currentColor = lerpColor(color1, color2, transitionAmount);

  background(currentColor);
  
  textAlign(CENTER, CENTER);
  textSize(50);
  fill(0, 255, 0);
  text("YOU WIN!", width / 2, height / 2 - 100);
  textSize(25);
  fill(255);
  text("Thank you for your help cleaning OUR ocean!", width / 2, height / 2);
  text("Click the button below to find out more!", width / 2, height / 2 + 50);
  
  //Hyper link button init
  fill(0); 
  rectMode(CENTER);
  stroke(255, 215, 0);
  strokeWeight(3); 
  rect(width / 2, height / 2 + 100, 250, 60, 20); 

  fill(255);
  textSize(15);
  text("Visit The Ocean Cleanup", width / 2, height / 2 + 100); 
  
  textSize(25);
  fill(255);
  text("Press the ENTER key to go back to the MENU", width / 2, height / 2 + 150);
}

void loseScreen() {
  if (!soundPlayed) {
    loseSound.play();
    soundPlayed = true;
  }

  color color1;
  color color2;
  float transitionAmount = 0.0;
  int transitionSpeed = 4000;

  // Breathing Background
  color1 = color(138, 7, 0);
  color2 = color(56, 3, 0);
  transitionAmount = (sin(millis() / float(transitionSpeed) * TWO_PI) + 1) / 2;
  color currentColor = lerpColor(color1, color2, transitionAmount);

  background(currentColor);
  
  textAlign(CENTER, CENTER);
  textSize(50);
  fill(255, 0, 0);
  text("YOU LOSE!", width / 2, height / 2 - 100);
  textSize(25);
  fill(255);
  text("Keep trash off OUR ocean floor", width / 2, height / 2);
  text("Click the button below to find out more!", width / 2, height / 2 + 50);
  
  //Hyper link button init
  fill(0); 
  rectMode(CENTER);
  stroke(205, 127, 50); 
  strokeWeight(3);
  rect(width / 2, height / 2 + 100, 250, 60, 20); 

  fill(255);
  textSize(15);
  text("Visit The Ocean Cleanup", width / 2, height / 2 + 100); 
  
  textSize(25);
  fill(255);
  text("Press the ENTER key to go back to the MENU", width / 2, height / 2 + 150);
}

// Press enter to go between states, screens
void keyPressed() {
  if (keyCode == ENTER && state.equals("title")) {
    state = "game";  
    enterSound.play();
    gameStartTime = millis(); // Added line
  } else if ((state.equals("win") || state.equals("lose")) && keyCode == ENTER) {
    enterSound.play();
    resetGame();
    state = "title";  
    soundPlayed = false; 
  }
}

// Click on square for hyper link
void mousePressed() {
  if ((state.equals("win") || state.equals("lose")) && mouseX > width / 2 - 125 && mouseX < width / 2 + 125 && mouseY > height / 2 + 70 && mouseY < height / 2 + 130) {
    link("https://theoceancleanup.com");
  }
}

void movieEvent(Movie m) {
  m.read(); // Ensure the movie frames are read correctly
}

void resetGame() {
  score = 0;
  missed = 0;
  for (int i = 0; i < myTrash.length; i++) {
    trashActive[i] = false;
    trashMissed[i] = false;  // Reset missed trash
    myTrash[i].reset();  // Reset the trash position
  }
  println("Game Reset");
}
