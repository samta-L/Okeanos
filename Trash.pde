class Trash {
  float xpos;
  float ypos;
  float speed;
  PImage img;
  
  Trash(float tempXpos, float tempYpos, float tempSpeed) {
    xpos = tempXpos;
    ypos = tempYpos;
    speed = tempSpeed;
    img = loadImage("trash.png"); // Load the image
  }
  
  void update() {
    ypos += speed;
  }
  
  void display() {
    image(img, xpos, ypos, 75, 75); 
  }
  
  void reset() {
    xpos = random(width);
    ypos = -20;
    speed = random(1, 3);
  }
}
