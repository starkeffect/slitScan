import processing.video.*;
Movie mv;
Capture cam;
int drawPos; 
int slitPos, slitBasePos, slitSize, slitBaseSize;
float seed;
PGraphics slit, frame;
boolean useCam;

void setup() 
{
  size(1920, 1080); // this should be equal to the frame dimensions
  drawPos = 0; // start drawing at the left corner
  randomize(); // choosing a random slit position and size
  seed = random(100); // seed for noise generator
  frame = createGraphics(width, height); // hold the invidual frames
  
  useCam = false;
  
  if(useCam)
  {
    String[] cameras = Capture.list();
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  else
  {
    mv = new Movie(this, "public.mov"); // reding the file
    mv.loop(); // loop or not
  }
  
}

void draw() 
{
  slitPos = slitBasePos + int(map(noise(seed), 0, 1, -min(slitBasePos, width-slitBasePos), min(slitBasePos, width-slitBasePos)));
  slitSize = slitBaseSize + int(map(noise(seed), 0, 1, -slitBaseSize, slitBaseSize)); //int(random(5, 30));
  //println(drawPos, slitBasePos, slitPos, slitBaseSize, slitSize);
  
  if (useCam == false && mv.available()) 
  {  
    
    mv.read();
    mv.loadPixels();
    frame.copy(mv, 0, 0, width, height, 0, 0, width, height);
    
    // randomize if end of movie is reached
    if(mv.time() == mv.duration()) randomize(); 

  }
  
  if (useCam == true && cam.available())
  {
    cam.read();
    cam.loadPixels();
    frame.copy(cam, 0, 0, width, height, 0, 0, width, height);
  }
  
  slit = extractSlit(frame, slitPos, slitSize);
  image(slit, drawPos, 0);
  drawPos += slitSize - int(0.3 * slitSize);
  //drawPos = drawPos % width;
  seed += 0.01;
  
  // stop if end of canvas is reached
  if(drawPos > width) noLoop();
  
}

PGraphics extractSlit(PGraphics frame, int slitPos, int slitSize)
{
  PGraphics s = createGraphics(slitSize, height);
  s.beginDraw();
  int randomSlitSize = int(slitSize * random(1, 2));
  randomSlitSize = (slitPos + randomSlitSize) > frame.width? frame.width - slitPos: randomSlitSize;
  s.copy(frame, slitPos, 0, randomSlitSize, height, 0, 0, slitSize, height);
  s.endDraw();
  return s;
}

void randomize()
{
  slitBasePos = int(random(1, width)); // base position of the slit
  slitBaseSize = int(random(1, 10)); // base size of the slit
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