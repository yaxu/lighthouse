PImage backgroundMap;

// bounding box of England
float mapGeoLeft   = -6.37988;
float mapGeoRight  =  1.76696;
float mapGeoTop    =   55.811741;
float mapGeoBottom =  49.871159;

float mapScreenWidth, mapScreenHeight;  // Dimension of map in pixels.

ArrayList<Lighthouse> lighthouses = new ArrayList<Lighthouse>();

void setup()
{
  size(600,600);
  smooth();
  mapScreenWidth  = width;
  mapScreenHeight = height;
}

void draw()
{
  background(255);
  //image(backgroundMap,0,0,mapScreenWidth,mapScreenHeight);
  //  ellipse(10,10,5,10);
  noStroke();
  
  for (int i = 0; i < lighthouses.size(); ++i) {
    Lighthouse lighthouse = lighthouses.get(i);
    PVector p = geoToPixel(new PVector(lighthouse.x,lighthouse.y));
    fill(255,0,0);
    ellipse(p.x,p.y,10,10);
  }
    //  }
}

void addLighthouse(int x, int y, string sequence) {
    Lighthouse lighthouse = new Lighthouse();
    lighthouse.x = x;
    lighthouse.y = y;
    lighthouse.sequence = sequence;
    lighthouses.add(lighthouse);
    println(sequence);
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

class Lighthouse {
    int x;
    int y;
    string sequence;
}
