import processing.video.*;

Capture cam;
int interval = 32;
int diameter = 32;
int xsteps;
int ysteps;
int drawSteps = 8;

color[][] colors;
int motionDiameter = 128;
int motionDrawSteps = 32;

int drawType = 0;

void setup()
{
  size(1024, 768);
  colorMode(HSB, 360, 100, 100);
  background(0);
  noStroke();
  
  xsteps = width/interval;
  ysteps = height/interval;
  
  colors = new color[xsteps][ysteps];
  
  cam = new Capture(this, width, height);
  cam.start();
}

void draw()
{
  if(cam.available())
  {
    cam.read();
  }
  
  if(drawType == 0)
  {
    drawMixedColor();
  }
  else
  {
    drawMotion();
  }
}

void keyPressed()
{
  drawType = 1 - drawType;
  background(0);
}

void drawMixedColor()
{
  for(int x=0; x<xsteps; x++)
  {
    for(int y=0; y<ysteps; y++)
    {
      int srcX = (int)((x + 0.5)/xsteps * cam.width);
      int srcY = (int)((y + 0.5)/ysteps * cam.height);
      color newCol = cam.get(srcX, srcY);
      int destX = (int)((x + 0.5)/xsteps * width);
      int destY = (int)((y + 0.5)/ysteps * height);
      color prevCol = get(destX, destY);

      for(int i=0; i<drawSteps; i++)
      {
        float r = (float)i/drawSteps;
        
        float h = hue(newCol) * r + hue(prevCol) * (1-r);
        float s = saturation(newCol) * r + saturation(prevCol) * (1-r);
        float b = brightness(newCol) * r + brightness(prevCol) * (1-r);
        fill(color(h, s, b), 255 * (1-r));
        
        if(i == 0)
        {
          stroke(0);
          strokeWeight(2);
        }
        else
        {
          noStroke();
        }
        
        float d = diameter * (1-r);
        ellipse(destX, destY, d, d);
      }
    }
  }
}

void drawMotion()
{
  background(0);
  
  for(int x=0; x<xsteps; x++)
  {
    for(int y=0; y<ysteps; y++)
    {
      int srcX = (int)((x + 0.5)/xsteps * cam.width);
      int srcY = (int)((y + 0.5)/ysteps * cam.height);
      color newCol = cam.get(srcX, srcY);
      int destX = (int)((x + 0.5)/xsteps * width);
      int destY = (int)((y + 0.5)/ysteps * height);
      color prevCol = colors[x][y];
      if(brightness(prevCol) == 0)
      {
        prevCol = newCol;
      }
      
      float motion = abs(brightness(newCol) - brightness(prevCol)) / 100;
      
      float r = (float)1/motionDrawSteps;

      float h = (hue(newCol) * r + hue(prevCol) * (1-r));
      float s = (saturation(newCol) * r + saturation(prevCol) * (1-r));
      float b = (brightness(newCol) * r + brightness(prevCol) * (1-r));
      colors[x][y] = color(h, s, b);
      fill(colors[x][y], 255);

      noStroke();

      float d = motionDiameter * motion;
      ellipse(destX, destY, d, d);
    }
  }
}