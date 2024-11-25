class Bucket { 
  float xpos;
  float ypos;
  float targetXpos;
  float targetYpos;
  PImage img;
  float imgWidth;
  float imgHeight;

  Bucket(float tempXpos, float tempYpos, float tempWidth, float tempHeight) { 
    xpos = tempXpos;
    ypos = tempYpos;
    targetXpos = tempXpos;
    targetYpos = tempYpos;
    imgWidth = tempWidth;
    imgHeight = tempHeight;
    img = loadImage("seamoth.png"); // Load the image
  }

  void update() {
    targetXpos = mouseX - imgWidth / 2; 
    targetYpos = mouseY - imgHeight / 2; 
    xpos = lerp(xpos, targetXpos, 0.1);
    ypos = lerp(ypos, targetYpos, 0.1); 
  }

  void display() {
    image(img, xpos, ypos, imgWidth, imgHeight); 
  }

  // Collision 
  boolean catches(Trash t) {
    return (t.xpos > xpos && t.xpos < xpos + imgWidth && t.ypos + 20 > ypos && t.ypos < ypos + imgHeight);
  }
}
