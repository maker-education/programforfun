/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/2084*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
PImage im;
float rot=0;
float[] arr;
PFont font;
int[] speed;
void setup()
{
  
  font=loadFont("Arial-BoldMT-15.vlw");
  //font=loadFont("2.0--48.vlw");
  size(900,300);
  arr=new float[width*height];
   speed=new int[width/10];
  for(int x=0;x<width/10;x++)
  {
    speed[x]=(int)random(3,7);
  }
  textFont(font);
  pushStyle();
  textSize(100);
  background(0);
  fill(255);
  textAlign(CENTER);
  text("Welcome to CODE!",width/2,2*height/4);
  popStyle();
  loadPixels();
  for(int i=0;i<width*height;i++)
  {
    arr[i]=brightness(pixels[i]);
  }
  updatePixels();
}
int j=1;
int i=0;
void draw()
{
  background(0);
  for (int x=0;x<width;x+=10)
  for(int y=-510;y<height+510;y+=15)
  {
    
    if(y>=0 && y<height)
    {
      textSize(15+map(arr[x+y*width],0,255,0,3));
    fill(0,100+arr[x+y*width],0);
    }
    else
    {
    textSize(15);
    fill(0,100+random(0,150),0);
  }
    text((int)random(0,10),x,y+speed[x/10]*i);
  }
  if(i>60)
  i=-60;
  i+=2;
  filter(ERODE);
}






