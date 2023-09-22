import http.requests.*;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.ParseException;
import processing.opengl.*;
import processing.dxf.*;


//-----HTTP / Comm Globals------

static final String serverURL = "http://localhost:8001";
static final String getSensorsEndpoint = "/getSensors";
static final String updateSensorsEndpoint = "/updateSensors";
static final String mintERC20Endpoint = "/mintERC20"; // cryptocurrency 
static final String mintERC721Endpoint = "/mintERC721"; // NFT
String tokenURI = "/"; // URI/path of the NFT image

static final long secondsInMilli = 1000;
static final long minutesInMilli = secondsInMilli * 60;
static final long hoursInMilli = minutesInMilli * 60;
long previousMillis = 0;

// sensor data from the server
int benzoApyrene = 0; //in ppm
int arsenic = 0; //in  ppm
float pH = 0.0;
//int power = 0; //in millwatt hours

// to send (HTTP "POST") new sensors data to the server
String postBenzoApyrene = ""; //in ppm
String postArsenic = ""; //in  ppm
String postPH = "";
//String postPower = ""; //in millwatt hours

// keep track of the number of tokens minted
int ERC20Count = 0;
int ERC721Count = 0;

Calendar cal;


//-------Viz / Mesh Globals------


Mesh theMesh;

int form = Mesh.FIGURE8TORUS;
float meshAlpha = 100;
float meshSpecular = 100;
float meshScale = 100;

boolean drawTriangles = true;
boolean drawQuads = false;
boolean drawNoStrip = false;
boolean drawStrip = true;
boolean useNoBlend = true;
boolean useBlendWhite = false;
boolean useBlendBlack = false;


//DEBUG: the uCount and vCount aren't able to change DYNAMICALLY, 
//because the videoData update does NOT Change with it..
int uCount = 40;
float uCenter = 0;
float uRange = TWO_PI;

int vCount = 2;
float vCenter = 0;
float vRange = PI/2;

float paramExtra = 1;

float meshDistortion = 0;

//HUE: Started at 190-295..
float minHue = 0;
float maxHue = 70;
float minSaturation = 95;
float maxSaturation = 100;
float minBrightness = 60;
float maxBrightness = 65;


// ------ mouse interaction ------

int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0.85, rotationY = -0.4, targetRotationX = 0.85, targetRotationY = 0.0, clickRotationX, clickRotationY; 



// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
ControlP5 cp5;
ControlP5 cp5Two;

//OG Colors: Gray with blue-green Accent
//color activeColor = color(0,130,164);
//color backColor = color(170, 170, 170);
//color frontColor = color(50, 50, 50);

//color activeColor = color(0,130,164);
//A Yellow-Tanish Accent???
color activeColor = color(179,179,125);
color backColor = color(170, 170, 170);
color frontColor = color(0, 80, 99);

// ------ image output ------

boolean saveOneFrame = false;
int qualityFactor = 3;
TileSaver tiler;
boolean saveDXF = false; 


// ------ NEW: DATA Inputs -----

float[] theData;
int ii = 0;

int dataPoint = 0;
boolean changeData = false;

PFont theFont;
static final String theTxt = "Terra Rete: Sensors";

color aColor = color(0, 90, 255);

float demoData = 0;

float sliderTwo = 0;
float slider = 0;

PImage theLogo;


static final String erc20 = "ERC-20 Contact Address";
static final String erc20Address = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

static final String erc721 = "ERC-721 Contact Address";
static final String erc721Address = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

static final String certificateTtl = "Brownfield Certificate";
String certificateNum = "008";

String[] certificateTxt = new String[6];

String remediation = "Contamination averages: 23%";
String creditsCount = "TerraRete credits minted: 24";
String certCount = "Brownfield certificates minted: 9/164";

String countDownTxt = "Time until next transaction: ";
String minTxt = "";
String secTxt = "";
int minutes = 55;
int seconds = 23;

PFont certFont; 
PFont certFontTwo;
PFont certTtlFont;
PFont addressFont;
PFont countFont;

float randomness = 0;
float randomnessTwo = 0;
float randomnessThree = 0;

float rFactor3 = 0;





void setup() {
  
  size(720, 1280);
  
  //--------- HTTP / Comm Setup --------------
  
  cal = Calendar.getInstance(); // calendar to get day of week
  
  //---------- Viz / Mesh Setup --------------
  certificateTxt[0] = "Time: Mon, Sep 11 2023 11:44:23 UTC";
  certificateTxt[1] = "Benzo(a)pyrene: 110 PPM (top)";
  certificateTxt[2] = "Arsenic: 131 PPM (middle)";
  certificateTxt[3] = "pH: 7.73 (bottom)";
  certificateTxt[4] = "Soil Source:";
  certificateTxt[5] = "43.13788, -77.62065 (Vacuum Oil Refinery)";
  
  minTxt = str(minutes);
  secTxt = str(seconds);
  
  countDownTxt += minTxt;
  countDownTxt += ":";
  countDownTxt += secTxt;
  
  certFont = createFont("SourceCodePro-Regular.ttf", 28);
  certFontTwo = createFont("SourceCodePro-Regular.ttf", 23);
  addressFont = createFont("SourceCodePro-Light.ttf", 32);
  countFont = createFont("SourceCodePro-Light.ttf", 24);
  certTtlFont = createFont("SourceCodePro-Regular.ttf", 40);
  theFont = createFont("SourceCodePro-ExtraLight.ttf", 42);
  
  theLogo = loadImage("phylum_logo_dark.png");
  
  rFactor3 = random(1, 3);
  
  
  
  cp5 = new ControlP5(this);
  cp5.addSlider("slider").setPosition(50,205).setSize(600,50).setRange(0,14).setValue(2);
  cp5.getController("slider").setLabel("ph");
  cp5.setColorActive(activeColor);
  cp5.setColorBackground(backColor);
  cp5.setColorForeground(frontColor);
  cp5.setColorCaptionLabel(color(255, 0, 0));
  //CHANGE Label SIZE?? 
  //cp5.setSizeCaptionLabel(24);
  
  cp5 = new ControlP5(this);
  cp5.addSlider("sliderTwo").setPosition(50,275).setSize(600,50).setRange(0,200).setValue(128);
  cp5.getController("sliderTwo").setLabel("Benzo(a)pyrene Levels");
  cp5.setColorCaptionLabel(color(255, 0, 0));
  
  cp5Two = new ControlP5(this);
  cp5Two.addSlider("sliderThree").setPosition(50, 345).setSize(600, 50).setRange(0, 100).setValue(33);
  cp5Two.getController("sliderThree").setLabel("Arsenic Levels");
  cp5Two.setColorCaptionLabel(color(180, 0, 120));
  
  //printArray(PFont.list());
  
  noStroke();
  
  theMesh = new Mesh(form, uCount, vCount);
  theData = new float[(uCount+1)*(1+vCount)];
  
  tiler = new TileSaver(this);
  changeData = true;
  if (changeData) {
    for (int iu = 0; iu <= uCount; iu++) {
      for (int iv = 0; iv <= vCount; iv++) {
        theData[ii] = random(0.51);
        ii++;
      }
    }
  }
  theMesh.updateData(theData);
}

void draw() {
  
  hint(ENABLE_DEPTH_TEST);
  //println(sliderTwo);
  //println(slider);

  // for high quality output
  if (tiler==null) return; 
  tiler.pre();

  // dxf output
  if (saveDXF) beginRaw(DXF, timestamp()+".dxf");


  // Set general drawing mode
  if (useBlendBlack) background(0);
  else background(255);

  if (useBlendWhite || useBlendBlack) {
  }
  
  //--------- HTTP / Comm Draw ---------------
  
  // attempt to mint an ERC20 and ERC721 token every hour
  long currentMillis = millis();
  long difference = currentMillis - previousMillis;
  long elapsedMinutes = round(difference / minutesInMilli);
  if(elapsedMinutes >= 60) {
      // --- mint ERC-20 (currency) ---
      if(mintERC20Token()) {
          //update the amount minted, show that a token was minted...
          println("show that an ERC-20 token was minted");
          println();
          
      }
      // --- mint ERC-721 (NFT) ---
      // skip Mon & Tues
      int dow = cal.get(Calendar.DAY_OF_WEEK);
      if(dow!=Calendar.MONDAY || dow!=Calendar.TUESDAY) {
          // set up date format
          SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
          Date d = cal.getTime();
          String currTimeStr = formatter.format(d);
          try {
              Date currTime = formatter.parse(currTimeStr);
              //cal.setTime(currTime);
              // Friday hours
              if(dow==Calendar.FRIDAY) {
                  // make sure it's between 12-9pm if it's Fri
                  try {
                      Date time1 = new SimpleDateFormat("HH:mm:ss").parse("12:00:00");
                      Date time2 = new SimpleDateFormat("HH:mm:ss").parse("21:00:00");
                      if(currTime.after(time1) && currTime.before(time2)) {
                          if(mintERC721Token(tokenURI)) {
                              //update the amount minted, show that a token was minted...
                              println("show that an ERC-721 token was minted");
                              println();
                          }

                      }
                  } catch(ParseException pe) {
                      println("Error parsing the date/time!");
                      println(pe.toString());
                  }
              } else {
                  try {
                      // the rest of the days
                      Date time1 = new SimpleDateFormat("HH:mm:ss").parse("12:00:00");
                      Date time2 = new SimpleDateFormat("HH:mm:ss").parse("17:00:00");
                      if(currTime.after(time1) && currTime.before(time2)) {
                          if(mintERC721Token(tokenURI)) {
                              //update the amount minted, show that a token was minted...
                              println("show that an ERC-721 token was minted");
                              println();
                          }

                      }
                  } catch(ParseException pe) {
                      println("Error parsing the date/time!");
                      println(pe.toString());
                  }
              } // end else
          } catch(ParseException pe) {
              println("Error parsing the date/time!");
              println(pe.toString());
          }

      } // end if

      previousMillis = currentMillis;
  }


  // if new sensor data input
  //update sensors

  //getSensors
  
  // Display the soil moisture value and token balance
  textSize(20);
  textAlign(CENTER);
  text("benzoApyrene: " + benzoApyrene, width/2, height/4);
  text("arsenic: " + arsenic, width/2, height/3);
  text("pH: " + pH, width/2, height/2);
  //text("powerH: " + power, width/2, height/2 + 100);
  
  //---------- Viz / Mesh Draw ---------------
  demoData += random(1);
  if (demoData > 200) demoData = 0;
  benzoApyrene = round(demoData);
  cp5.getController("sliderTwo").setValue(benzoApyrene);
  meshDistortion = (demoData * 0.01);
  
  arsenic = 33;
  cp5Two.getController("sliderThree").setValue(arsenic);
  
  drawCircleViz();
  drawText();
  image(theLogo, 50, 50, 288, 103);

  // Set lights
  lightSpecular(255, 255, 255);
  directionalLight(255, 255, 255, 1, 1, -1);
  specular(meshSpecular, meshSpecular, meshSpecular);
  shininess(5.0);
  
  // ------ set view ------
  pushMatrix();
  //translate(width*0.5, height*0.5);
  translate(width*0.25, height*0.65);

  if (mousePressed && mouseButton==RIGHT) {
    offsetX = mouseX-clickX;
    offsetY = mouseY-clickY;

    targetRotationX = min(max(clickRotationX + offsetY/float(width) * TWO_PI, -HALF_PI), HALF_PI);
    targetRotationY = clickRotationY + offsetX/float(height) * TWO_PI;
  }
  rotationX += (targetRotationX-rotationX)*0.25; 
  rotationY += (targetRotationY-rotationY)*0.25;  
  //rotateX(-rotationX);
  rotateX(rotationX);
  //rotateX(0.95);
  rotateY(rotationY);
  
  scale(meshScale);
  
  // -----!! Set Parameters and DRAW Mesh !!------
  theMesh.setForm(form);
  
  surface.setTitle("Current Value: " + theMesh.getMeshDistortion());
  
  if (drawTriangles && drawNoStrip) theMesh.setDrawMode(TRIANGLES);
  else if (drawTriangles && drawStrip) theMesh.setDrawMode(TRIANGLE_STRIP);
  else if (drawQuads && drawNoStrip) theMesh.setDrawMode(QUADS);
  else if (drawQuads && drawStrip) theMesh.setDrawMode(QUAD_STRIP);
  
  theMesh.setUMin(uCenter-uRange/2);
  theMesh.setUMax(uCenter+uRange/2);
  theMesh.setUCount(uCount);
  
  theMesh.setVMin(vCenter-vRange/2);
  theMesh.setVMax(vCenter+vRange/2);
  theMesh.setVCount(vCount);
  
  theMesh.setParam(0, paramExtra);
  
  theMesh.setColorRange(minHue,maxHue, minSaturation,maxSaturation, minBrightness,maxBrightness, meshAlpha);
  theData = new float[(uCount+1)*(1+vCount)];
  ii = 0;
  
  theMesh.setMeshDistortion(meshDistortion);
  if (changeData) {
    theData = new float[(uCount+1)*(vCount+1)];
    for (int iu = 0; iu <= uCount; iu++) {
      for (int iv = 0; iv <= vCount; iv++) {
        theData[ii] = random(0.51);
        ii++;
      }
    }
    theMesh.updateData(theData);
  }
  else {
    theMesh.update();
  }
  colorMode(HSB, 360, 100, 100, 100);
  strokeWeight(0.01);
  stroke(60,100,100,60);
  
  theMesh.draw();
  
  colorMode(RGB, 255, 255, 255, 100);
  
  popMatrix();
  
  // ------ image output and gui ------

  // image output
  if (saveOneFrame) {
    saveFrame(timestamp()+".png");
  }

  if (saveDXF) {
    endRaw();
    saveDXF = false;
  }

  // draw next tile for high quality output
  tiler.post();
}

boolean getSensors() {
    try {
        JSONObject sensors = loadJSONObject(serverURL + getSensorsEndpoint);
        benzoApyrene = sensors.getInt("benzoApyrene");
        arsenic = sensors.getInt("arsenic");
        pH = sensors.getInt("pH") / 100.0; // convert pH value to float (with proper decimal place)
        //power = sensors.getInt("power");
        println("getSensors():");
        println(sensors.toString());
        return true;
    } catch(Exception e) {
        System.out.println("Something went wrong getting the JSON data");
        e.toString();
        return false;
    }
}

boolean updateSensors() {
    try {
        PostRequest post = new PostRequest(serverURL + updateSensorsEndpoint);
        post.addHeader("Content-Type", "application/json");
        post.addData("{\"benzoApyrene\":"+postBenzoApyrene+",\"arsenic\":"+postArsenic+",\"pH\":"+postPH+"}");
        post.send();
        println("updateSensors():");
        System.out.println("Reponse Content: " + post.getContent());
        System.out.println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
        return true;
    } catch(Exception e) {
        System.out.println("Something went wrong posting the JSON data");
        e.toString();
        return false;
    }
}

// mint a TerraRete cryptocurrency token
boolean mintERC20Token() {
    try {
        GetRequest get = new GetRequest(serverURL + mintERC20Endpoint);
        get.send();
        String numMintedStr = get.getContent(); // update number of tokens minted in vis
        println("mintERC20Token():");
        println("Reponse Content: " + numMintedStr);
        println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
        
        // check if token was actually minted
        int numERC20TokensMinted = Integer.parseInt(numMintedStr);
        println("number of ERC-20 tokens minted so far: " + numERC20TokensMinted);
        if(numERC20TokensMinted > ERC20Count) {
            ERC20Count = numERC20TokensMinted;
            return true;
        } else {
            return false;
        }
    } catch(Exception e) {
        System.out.println("Something went wrong with the server request");
        println(e.toString());
        return false;
    }
}

// mint an NFT
boolean mintERC721Token(String filepath) {
    try {
        PostRequest post = new PostRequest(serverURL + mintERC721Endpoint);
        post.addHeader("Content-Type", "application/json");
        post.addData("{\"TokenURI\":"+filepath+"}");
        post.send();
        String numMintedStr = post.getContent(); // update number of tokens minted in vis
        println("mintERC721Token():");
        System.out.println("Reponse Content: " + numMintedStr);
        System.out.println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
        
        // check if token was actually minted
        int numERC721TokensMinted = Integer.parseInt(numMintedStr);
        println("number of ERC-721 tokens minted so far: " + numERC721TokensMinted);
        if(numERC721TokensMinted > ERC721Count) {
            ERC721Count = numERC721TokensMinted;
            return true;
        } else {
            return false;
        }

    } catch(Exception e) {
        System.out.println("Something went wrong posting the JSON data");
        println(e.toString());
        return false;
    }
}

// rounds a number to 2 decimal places
// example: round(3.14159) -> 3.14
float round2(float value) {
   return (int(value * 100 + 0.5)) / 100.0;
}



//----------Viz functions---------

void drawCircleViz() {
  fill(90);
  rect(1000, 175, 650, 700);
  
  pushMatrix();
  float rFactor = random(0, 3);
  float rFactor2 = random(0, 5);
  
  fill(190, 205, 255, 70);
  drawCircles(1200, 460, 100, rFactor);
  fill(150, 180, 255, 70);
  drawCircles(1450, 460, 100, rFactor2);
  popMatrix();
  
  pushMatrix();
  fill(180, 255, 215, 70);
  drawCirclesTwo(1200, 590, 100);
  fill(150, 255, 205, 70);
  drawCirclesTwo(1450, 590, 100);
  popMatrix();
  
  pushMatrix();
  fill(200, 180, 215, 70);
  drawCirclesThree(1200, 720, 100);
  fill(225, 150, 255, 70);
  drawCirclesThree(1450, 720, 100);
  popMatrix();
}

void drawText() {
  fill(255);
  textFont(certTtlFont);
  text(certificateTtl, 1030, 240);
  for (int i = 0; i < certificateTxt.length; i++) {
    if (i < 4) {
      textFont(certFont);
      text(certificateTxt[i], 1030, (i*30)+280);
    }
    else {
      textFont(certFontTwo);
      text(certificateTxt[i], 1030, (i*30)+690);
    }
    
  }
  
  theTxt.toUpperCase();
  fill(0);
  textFont(theFont);
  text(theTxt, 50, 450);
  
  fill(0);
  textFont(addressFont);
  text(erc20, 470, 80);
  text(erc20Address, 900, 80);
  text(erc721, 470, 120);
  text(erc721Address, 920, 120);
  
  
  fill(0);
  textFont(countFont);
  text(remediation, 50, 940);
  text(creditsCount, 550, 940);
  text(certCount, 1050, 940);
  text(countDownTxt, 500, 980);
}


void drawCircles(float x, float y, float radius) {
  ellipse(x, y, radius, radius);
  if (radius > 5) {
    drawCircles(x + radius/2, y, radius/2);
    drawCircles(x - radius/2, y, radius/2);
  }
}

void drawCircles(float x, float y, float radius, float factor) {
  ellipse(x, y, radius, radius);
  randomness = random(0, 1);
  //println(randomness);
  factor *= randomness;
  if (radius > 5) {
    drawCircles(x + radius/2, y, radius/factor);
    drawCircles(x - radius/2, y, radius/factor);
  }
}

void drawCirclesTwo(float x2, float y2, float radiusTwo) {
  ellipse(x2, y2, radiusTwo, radiusTwo);
  if (radiusTwo > 5) {
    drawCirclesTwo(x2 + radiusTwo/1.5, y2, radiusTwo/2);
    drawCirclesTwo(x2 - radiusTwo/1.5, y2, radiusTwo/2);
  }
}

void drawCirclesTwo(float x, float y, float radius, float factor) {
  ellipse(x, y, radius, radius);
  randomnessTwo = random(0, 1);
  //println(randomness);
  factor *= randomnessTwo;
  if (radius > 5) {
    drawCirclesTwo(x + radius/2, y, radius/factor);
    drawCirclesTwo(x - radius/2, y, radius/factor);
  }
}

void drawCirclesThree(float x3, float y3, float radiusThree) {
  ellipse(x3, y3, radiusThree, radiusThree);
  //randomnessThree = random(3);
  //rFactor3 *= randomnessThree;
  if (radiusThree > 5) {
    drawCirclesThree(x3 + radiusThree/rFactor3, y3, radiusThree/2.5);
    drawCirclesThree(x3 - radiusThree/rFactor3, y3, radiusThree/2.5);
  }
}




void keyPressed() {
  demoData++;
  cp5.getController("sliderTwo").setValue(demoData);
  if (demoData > 200) demoData = 0;
  
  if (key == 's' || key == 'S') {
    saveOneFrame = true;
  }
  
  if (key == 'p' || key == 'P') {
    saveFrame(timestamp() + "_viz.png");
    tiler.init(timestamp()+".png", qualityFactor);
  }
  
  if (key == 'd' || key == 'D') {
    saveDXF = true;
  }
  
  if (key == 'r' || key == 'R') {
    drawData = !drawData;
  }
  
  if (key == 't' || key == 'T') {
    changeData = !changeData;
  }
}

void mousePressed() {
  clickX = mouseX;
  clickY = mouseY;
  clickRotationX = rotationX;
  clickRotationY = rotationY;
}

void mouseEntered(MouseEvent e) {
  loop();
}

void mouseExited(MouseEvent e) {
  noLoop();
}

void slider(float theValue) {
  //println("Slider value incoming event. the value: " + theValue);
  meshDistortion = (theValue * 0.001);
  theMesh.setMeshDistortion(meshDistortion);
}


void controlEvent(ControlEvent theControlEvent) {
  //println("Control Event occured: " + theControlEvent);
  theControlEvent = theControlEvent;
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}
