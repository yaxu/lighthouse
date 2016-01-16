PImage backgroundMap;

// bounding box of England
float mapGeoLeft   = -6.37988;
float mapGeoRight  =  1.76696;
float mapGeoTop    =   55.811741;
float mapGeoBottom =  49.871159;

float mapScreenWidth, mapScreenHeight;  // Dimension of map in pixels.


int i = 0; 

ArrayList[] lighthouses = new ArrayList();

void setup()
{
  size(600,60);
  smooth();
  //noLoop();
  mapScreenWidth  = width;
  mapScreenHeight = height;

  PVector p1 = geoToPixel(new PVector(0.8,51.5));  // London
  Lighthouse lh1 = new Lighthouse(p1, "0.2+(2)+0.2+(2)+0.2+(5.4)", false);
  lighthouses.add(lh1);
  PVector p2 = geoToPixel(new PVector(0.9759301,50.913452));       // Dungeness
  Lighthouse lh2 = new Lighthouse(p2, "8+(2)", false);
  lighthouses.add(lh2);

  println("hello\n");
}

void draw()
{
  background(255);
  //image(backgroundMap,0,0,mapScreenWidth,mapScreenHeight);
  //  ellipse(10,10,5,10);
  noStroke();

  
  for(int i=0; i < lighthouses.size(); i++) {
    lighthouses.get(i).update(millis());
  }

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

// Converts a pattern, e.g., "0.2+(2)+0.2+(2)+0.2+(5.4)" into an ArrayList of
// ArrayLists, e.g., [[true, 0.2], [false, 2], ...]
// the occulting parameter denotes if the lighthouse is an occulting one,
// where the pattern doesn't denote on-(off), but (on)-off
ArrayList[] parse_pattern(String pattern, Boolean occulting) {
  ArrayList[] seq = new ArrayList();
  String[] fields = splitTokens(pattern, "+,");
  for(int i=0; i<fields.length(); i++) {
    Event note;
    if(trim(fields[i])[0] == "(") {
      float pause = float(fields[i].substring(1,fields[i].length()-1));
      note = new Event(pause, occulting);
    }
    else {
      float blink = float(fields[i]);
      note = new Event(blink, !occulting);
    }
    seq.add(note);
  }
  return seq;
}


class Event {
  boolean on;
  float length;

  Event (float l, boolean o) {
    length = l;
    on = o;
  }
}


class Lighthouse { 
  PVector location;
  ArrayList[] pattern;
  int next_time;
  int index;

  Lighthouse (PVector loc, String raw_pattern, boolean occulting) {  
    location = loc;
    pattern = parse_pattern(raw_pattern);
    next_time = 0;
    index = 0;
  }

  void update (int millis) {
    if(millis > next_time) {
      index = (index + 1) % pattern.size();
      next_time = int(millis + (pattern.get(index).length * 1000));
      /*if(pattern.get(index).get(0)) {
        synth.triggerAttackRelease("C4", seq.get(index).get(1));
        }*/
    }
    
    if(pattern.get(index).on) { 
      fill(255);
    }
    else {
      fill(0);
    }
    ellipse(location.x,location.y,10,10);
  }
}
