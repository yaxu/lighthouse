PImage backgroundMap;

// bounding box of England
float mapGeoLeft   = -9.37988;
float mapGeoRight  =  4;
float mapGeoTop    =   60.811741;
float mapGeoBottom =  49;

float mapScreenWidth, mapScreenHeight;  // Dimension of map in pixels.
var synth = new Tone.SimpleSynth().toMaster();

//create a distortion effect
var distortion = new Tone.Distortion(0.4).toMaster();

int maxDist = 100;

PImage lhon = loadImage("johnny-automatic-lighthouse WHITE.png");
PImage lhoff = loadImage("johnny-automatic-lighthouse BLACK.png");

ArrayList<Lighthouse> lighthouses = new ArrayList<Lighthouse>();

void setup()
{
  size(600,800);
  smooth();

  mapScreenWidth  = width;
  mapScreenHeight = height;

}

void draw()
{
  background(32,32,96);
  //image(backgroundMap,0,0,mapScreenWidth,mapScreenHeight);
  //  ellipse(10,10,5,10);
  noStroke();

  fill(255,255,255,10)
  ellipse(mouseX, mouseY, maxDist*2,maxDist*2)
  noStroke();

  for(int i=0; i < lighthouses.size(); i++) {
    lighthouses.get(i).update(millis(), mouseX, mouseY);
  }
}

void addLighthouse(int x, int y, string sequence, string character) {
  PVector p1 = geoToPixel(new PVector(x,y));  // London

  Lighthouse lighthouse = new Lighthouse(p1.x,p1.y,sequence,character == "Oc");
  lighthouse.freq = random(110, 1200);
    lighthouses.add(lighthouse);
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
// Events.
// The occulting parameter denotes if the lighthouse is an occulting one,
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
  ArrayList[] pattern;
  int next_time;
  int index;
  int x;
  int y;
  int freq;
  float amp;
  string sequence;

  Lighthouse (int in_x, int in_y, String raw_pattern, boolean occulting) {  
    pattern = parse_pattern(raw_pattern);
    next_time = 0;
    x = in_x;
    y = in_y;
    index = 0;
    freq = 440;
    amp = 0.1;
  }

  void update (int millis, int mx, int my) {
    if(millis > next_time) {
      index = (index + 1) % pattern.size();
      next_time = int(millis + (pattern.get(index).length * 1000));
      if(pattern.get(index).on) {
        int d = dist(x,y,mx,my);
        if(d < maxDist) {
          amp = 1.0 - (d/maxDist);
          synth.triggerAttackRelease(freq, pattern.get(index).length);
        }
      }
    }

    if(pattern.get(index).on) { 
      image(lhon,x,y,10,10);
    }
    else {
      image(lhoff,x,y,10,10);
    }
  }
}

