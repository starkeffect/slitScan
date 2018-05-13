import processing.video.*;
import controlP5.*;


ControlP5 cp5;
Movie mv;
Capture cam;
int drawPos; 
int slitPos, slitBasePos, slitSize, slitBaseSize;
float seed;
PGraphics slit, frame, drawFrame;
boolean useCam;
float slit_pos_frac, slit_size_frac;

void setup() 
{
  size(1280, 1080); // this should be equal to the frame dimensions
  drawPos = 0; // start drawing at the left corner
  //randomize(); // choosing a random slit position and size
  seed = random(100); // seed for noise generator
  frame = createGraphics(width, height); // hold the invidual frames
  drawFrame = createGraphics(width, height); // hold the display frame
  cp5 = new ControlP5(this); // initializing control interface
  
  useCam = false;
  
  if(useCam)
  {
    String[] cameras = Capture.list();
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  else
  {
    mv = new Movie(this, "walking.mp4"); // reding the file
    mv.loop(); // loop or not
  }
  
  // adding sliders to the interface
  cp5.addSlider("slit_pos_frac")
     .setRange(0,1)
     .setValue(1)
     .setPosition(20,20)
     .setSize(200,20)
     .setCaptionLabel("Slit Position Range");
     
  cp5.addSlider("slit_size_frac")
     .setRange(0,0.5)
     .setValue(0.1)
     .setPosition(20,50)
     .setSize(200,20)
     .setCaptionLabel("Slit Size Range");
  
}

void draw() 
{
  slitPos = (slitBasePos + frameCount) % width; //int(map(noise(seed), 0, 1, -min(slitBasePos, width-slitBasePos), min(slitBasePos, width-slitBasePos)));
  slitSize = slitBaseSize + int(map(noise(seed), 0, 1, -slitBaseSize, slitBaseSize)); //int(random(5, 30));
  //println(drawPos, slitBasePos, slitPos, slitBaseSize, slitSize);
  
  frame.beginDraw();
  if (useCam == false && mv.available()) 
  {  
    
    mv.read();
    mv.loadPixels();
    frame.copy(mv, 0, 0, width, height, 0, 0, width, height);
    
    // randomize if end of movie is reached
    //if(mv.time() == mv.duration()) randomize(); 

  }
  
  if (useCam == true && cam.available())
  {
    cam.read();
    cam.loadPixels();
    frame.copy(cam, 0, 0, width, height, 0, 0, width, height);
  }
  frame.endDraw();
  
  slit = extractSlit(frame, slitPos, slitSize);
  image(slit, drawPos, 0);
  
  drawFrame.beginDraw();
  drawFrame.copy(slit.get(), 0, 0, slitSize, height, slitPos, 0, slitSize, height);
  drawFrame.endDraw();
  
  drawPos += slitSize - int(0.3 * slitSize);
  //drawPos = drawPos % width;
  seed += 0.01;
  
  // stop if end of canvas is reached
  if(drawPos > width) noLoop();
  
}

// extracting the slit from the current video frame
PGraphics extractSlit(PGraphics frame_, int slitPos, int slitSize)
{
  PGraphics s = createGraphics(slitSize, height);
  s.beginDraw();
  int randomSlitSize = int(slitSize * random(1, 2));
  randomSlitSize = (slitPos + randomSlitSize) > frame_.width? frame_.width - slitPos: randomSlitSize;
  s.copy(frame_.get(), slitPos, 0, randomSlitSize, height, 0, 0, slitSize, height);
  s.endDraw();
  return s;
}

void slit_pos_frac()
{
  slitBasePos = int(random(1, slit_pos_frac * width)); // base position of the slit
}


void slit_size_frac() 
{
  slitBaseSize = int(random(1, slit_size_frac * width)); // base size of the slit
}

void keyPressed()
{
  // save frame
  if(key == 's') 
  {
    //saveFrame("output/####.tif");
    drawFrame.get().save("output/" + str(frameCount) + ".tif");
  }
  
  // referesh
  if(key == 'r')
  {
    drawPos = 0;
    loop();
  }
}