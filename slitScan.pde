import processing.video.*;
Movie mv;
int drawPos; 
int slitPos, slitBasePos, slitSize, slitBaseSize;
float seed;
PGraphics slit;

void setup() 
{
  size(1280, 720); // this should be equal to the frame dimensions
  mv = new Movie(this, "walking.mp4"); // reding the file
  mv.loop(); // loop or not
  drawPos = 0; // start drawing at the left corner
  randomize();
  seed = random(100);
}

void draw() 
{
  if (mv.available()) 
  {
    slitPos = slitBasePos + int(map(noise(seed), 0, 1, -min(slitBasePos, width-slitBasePos), min(slitBasePos, width-slitBasePos)));
    slitSize = slitBaseSize + int(map(noise(seed), 0, 1, -slitBaseSize, slitBaseSize)); //int(random(5, 30));
    println(drawPos, slitBasePos, slitPos, slitBaseSize, slitSize);
    mv.read();
    slit = extractSlit(mv, slitPos, slitSize);
    //blendMode(OVERLAY);
    //tint(255, 150);
    image(slit, drawPos, 0);
    drawPos += slitSize - int(0.3 * slitSize);
    //drawPos = drawPos % width;
    seed += 0.01;
    
    // stop if end of canvas is reached
    if(drawPos > width) noLoop();
  }
}

PGraphics extractSlit(Movie m, int slitPos, int slitSize)
{
  m.loadPixels();
  PGraphics s = createGraphics(slitSize, height);
  s.beginDraw();
  int randomSlitSize = int(slitSize * random(1, 2));
  randomSlitSize = (slitPos + randomSlitSize) > m.width? m.width - slitPos: randomSlitSize;
  s.copy(m, slitPos, 0, randomSlitSize, height, 0, 0, slitSize, height);
  s.endDraw();
  return s;
}

void randomize()
{
  slitBasePos = int(random(1, width)); // base position of the slit
  slitBaseSize = int(random(1, 5)); // base size of the slit
}

void mouseClicked()
{
  // redraw the canvas
  drawPos = 0;
  //randomize();
  loop();
  background(0);
}

void keyPressed()
{
  if(key == 's') saveFrame("output/####.tif");
}