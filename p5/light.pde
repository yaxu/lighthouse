PImage backgroundMap;

// bounding box of England
float mapGeoLeft   = -6.37988;
float mapGeoRight  =  1.76696;
float mapGeoTop    =   55.811741;
float mapGeoBottom =  49.871159;

float mapScreenWidth, mapScreenHeight;  // Dimension of map in pixels.

void setup()
{
  size(600,60);
  smooth();
  noLoop();
  mapScreenWidth  = width;
  mapScreenHeight = height;
}

void draw()
{
  background(255);
  //image(backgroundMap,0,0,mapScreenWidth,mapScreenHeight);
  //  ellipse(10,10,5,10);
  noStroke();

  fill(180,120,120);
  println("hello\n");
  fill(0,255,0);
  PVector p = geoToPixel(new PVector(0.8,51.5));  // London
  ellipse(p.x,p.y,10,10);
  fill(0,0,255);
  fill(255,0,0);
  p = geoToPixel(new PVector(0.9759301,50.913452));       // Dungeness
  ellipse(p.x,p.y,10,10);
}

// Converts screen coordinates into geographical coordinates. 
// Useful for interpreting mouse position.
public PVector pixelToGeo(PVector screenLocation)
{
    return new PVector(mapGeoLeft + (mapGeoRight-mapGeoLeft)*(screenLocation.x)/mapScreenWidth,
                       mapGeoTop - (mapGeoTop-mapGeoBottom)*(screenLocation.y)/mapScreenHeight);
}

// Converts geographical coordinates into screen coordinates.
// Useful for drawing geographically referenced items on screen.
public PVector geoToPixel(PVector geoLocation)
{
    return new PVector(mapScreenWidth*(geoLocation.x-mapGeoLeft)/(mapGeoRight-mapGeoLeft),
                       mapScreenHeight - mapScreenHeight*(geoLocation.y-mapGeoBottom)/(mapGeoTop-mapGeoBottom));
}
