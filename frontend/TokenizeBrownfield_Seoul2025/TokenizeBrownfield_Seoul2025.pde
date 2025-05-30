import http.requests.*;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.ParseException;

import java.util.TimeZone;
import processing.video.*;


// --- OG BlockChain Code - May 2025 ---

// urls
static final String serverURL = "http://localhost:8001";
static final String getSensorsEndpoint = "/getSensors";
static final String updateSensorsEndpoint = "/updateSensors";
static final String mintERC20Endpoint = "/mintERC20"; // cryptocurrency 
static final String mintERC721Endpoint = "/mintERC721"; // NFT
String tokenURI = "/"; // URI/path of the NFT image

// time/countdown stuff
//static final long secondsInMilli = 1000;
//static final long minutesInMilli = secondsInMilli * 60;
//static final long hoursInMilli = minutesInMilli * 60;
//long previousMillis = 0;
int startTime; // Variable to store the starting time
//static final int countdownDuration = 40;
static final int countdownDuration = 3600;// 3600 seconds = 1 hour

// sensor data from the server
float benzoApyrene = 0.0; //in ppm
float arsenic = 0.0; //in  ppm
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

boolean cursorOn=true;

int theSeed = 1983;


// --- Data Viz Addons - for certificate ---

float nftPx = 1320;
float nftBx = 1320;
float nftAx = 1320;

float nftPy = 390;
float nftBy = 530;
float nftAy = 670;

int nftCount = 168;

// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
ControlP5 cp5;
ControlP5 cp5Two;

ControlFrame cFrame;

float bMinR, bFactor, pMinR, pFactor, aMinR, aFactor, nftMap;

float benzoData = benzoApyrene;
float arsenicData = arsenic;

Mesh theMesh;
Mesh theBMesh;

int form = Mesh.DATAPLANE;
float meshAlpha = 100;
float meshSpecular = 100;
float meshScale = 100;

boolean drawTriangles = true;
boolean drawQuads = false;
boolean drawNoStrip = false;
boolean drawStrip = true;
boolean useNoBlend = true;
boolean useBlendWhite = false;
boolean useBlendBlack = true;


//TWO_PI = 6.283185307179586
//EACH uCount Increment amount of Range (TWO_PI/40): 0.15707963267949
//TWO_PI / 10: 0.62831853
int uCount = 10;
float uCenter = 0;
float uRange = TWO_PI/40;

int vCount = 1;
float vCenter = 0;
float vRange = PI/6;

int prevUCount = uCount;

float paramExtra = 1;

float meshDistortion = 0.0;

//HUE: Started at 190-295..
float minHue = 0;
float maxHue = 70;
float minSaturation = 95;
float maxSaturation = 100;
float minBrightness = 60;
float maxBrightness = 65;


// ------ mouse interaction ------

int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0.85, rotationY = -0.4, targetRotationX = 0.0, targetRotationY = 0.0, clickRotationX, clickRotationY; 

color activeColor = color(179,179,125);
color backColor = color(170, 170, 170);
color frontColor = color(0, 80, 99);

color mainTxtCol = color(125, 179, 167);

// ------ image output ------

boolean saveOneFrame = false;
int qualityFactor = 3;
TileSaver tiler;
TileSaver tilerTwo;


// ------ NEW: DATA Inputs -----

float[] theData;

int ii = 0;


int dataPoint = 0;
boolean changeData = false;

PFont theFont;
static final String theTxt = "Soil Analysis";

color aColor = color(0, 90, 255);

float demoData = 0;

float sliderTwo = 0;
float slider = 0;

PImage theLogo;


static final String erc20 = "ERC-20 Contract Address: ";
static final String erc20Address = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

static final String erc721 = "ERC-721 Contract Address: ";
static final String erc721Address = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

static final String certificateTtl = "Brownfield Certificate";

String[] certificateTxt = new String[6];

String remediation = "Contamination averages: 23%";
static final String creditsCount = "TerraRete credits minted: ";
static final String certCount = "Brownfield certificates minted: ";

static final String countDownTxt = "Time until next transaction: ";

color phTxtColor = color(150, 180, 255);
color benzoTxtColor = color(180, 255, 215);
color arTxtColor = color(200, 180, 215);
PFont certFont; 
PFont certFontTwo;
PFont certTtlFont;
PFont erc721CountFont;
PFont addressFont;
PFont countFont;
PFont labelFont;



// --- Multi Channel Displays ---
MultiDisplay displayTwo;


PImage bacteria;
Movie theMovie;

TargetGraphic artistTag;
float meshTagX, meshTagY;
float meshTagW = 300;
float meshTagH = 200;
float meshOffsetX = meshTagW/2;
float meshOffsetY = meshTagH/2;
float newTargetX, newTargetY;





void setup() {
  // --- OG Setup Code ---
  //size(720, 1280);
  cal = Calendar.getInstance(); // calendar to get day of week
  startTime = millis(); // get the current time in milliseconds
  
  // --- Data Viz ---
  fullScreen(P3D, 1);
  
  theMovie = new Movie(this, "TR_Soil_Dig_02_opt.mp4");
  theMovie.loop();
  
  meshTagX = width*0.7;
  meshTagY = height*0.5;
  artistTag = new TargetGraphic(meshTagX-meshOffsetX, meshTagY-meshOffsetY, meshTagW, meshTagH);
  newTargetX = artistTag.tx;
  newTargetY = artistTag.ty;
  
  certificateTxt[0] = "Time: Fri, 06 Oct 2023 11:44:23 GMT";
  certificateTxt[1] = "pH: 8.20";
  certificateTxt[2] = "Benzo(a)pyrene: 0.05 PPM";
  certificateTxt[3] = "Arsenic: 13.83 PPM";
  certificateTxt[4] = "Soil Source:";
  certificateTxt[5] = "37.183877, 126.860259 (Hwaseong-si Industrial Zone)";
  
  
  // load fonts and set font sizes
  certFont = createFont("SourceCodePro-Light.ttf", 24);
  certFontTwo = createFont("SourceCodePro-Regular.ttf", 20);
  addressFont = createFont("SourceCodePro-Light.ttf", 24);
  countFont = createFont("SourceCodePro-Light.ttf", 24);
  certTtlFont = createFont("SourceCodePro-Regular.ttf", 34);
  erc721CountFont = createFont("SourceCodePro-Regular.ttf", 24);
  theFont = createFont("SourceCodePro-ExtraLight.ttf", 34);

  labelFont = createFont("SourceCodePro-Regular.ttf", 14); // turn anti-aliasing off
  
  
  theLogo = loadImage("Phylum_Logo_light.png");
  
  cp5 = new ControlP5(this);
  cp5.addSlider("slider").setPosition(70,205).setSize(600,50).setRange(0.0,14.0).setValue(0.0).setFont(labelFont);
  cp5.getController("slider").setLabel("pH");
  cp5.setColorActive(activeColor);
  cp5.setColorBackground(backColor);
  cp5.setColorForeground(frontColor);
  cp5.setColorCaptionLabel(color(194,194,194));
  
  cp5.addSlider("sliderTwo").setPosition(70,275).setSize(600,50).setRange(0.0,1.0).setValue(0.00).setFont(labelFont);
  cp5.getController("sliderTwo").setLabel("Benzo(a)pyrene");
  cp5.setColorCaptionLabel(color(194,194,194));
  
  cp5Two = new ControlP5(this);
  cp5Two.addSlider("sliderThree").setPosition(70, 345).setSize(600, 50).setRange(0.0, 20.0).setValue(0.00).setFont(labelFont);
  cp5Two.getController("sliderThree").setLabel("Arsenic");
  cp5Two.setColorCaptionLabel(color(194,194,194));
  
  cFrame = new ControlFrame(this, 400, 400, "Controls");
  
  noStroke();
  
  theMesh = new Mesh(form, uCount, vCount);
  theData = new float[(uCount+1)*(1+vCount)];
  
  tiler = new TileSaver(this);
  
  benzoData = map(benzoApyrene, 0,20, 0.05,0.9);
  changeData = true;
  if (changeData) {
    for (int iu = 0; iu <= uCount; iu++) {
      for (int iv = 0; iv <= vCount; iv++) {
        theData[ii] = random(0.51);
        ii++;
      }
    }
    //changeData = !changeData;
  }
  theMesh.updateData(theData);
  

  //cal = Calendar.getInstance(); // calendar to get day of week
  //startTime = millis(); // get the current time in milliseconds
  
  bacteria = loadImage("bacteria_graphic.png");
  
  displayTwo = new MultiDisplay(this, 2, "ERC721 Cert Window");
  displayTwo.openFrame();

}

void draw() {
  //background(255);
  background(0);
  hint(ENABLE_DEPTH_TEST);
  
  

  // for high quality output
  if (tiler==null) return; 
  tiler.pre();
  
  // --- OG Blockchain Loop ---
  // ONLY Additions: uCount of Mesh based on ERC20Count & Certificate Txt

  // Calculate the elapsed time in seconds
  int elapsedTime = (millis() - startTime) / 1000;
  // Calculate remaining time
  int remainingTime = countdownDuration - elapsedTime;
  // Display the remaining time
  displayTime(remainingTime);

  // long currentMillis = millis();
  // long difference = currentMillis - previousMillis;
  // long elapsedMinutes = round(difference / minutesInMilli);

  // attempt to mint an ERC20 and ERC721 token every hour
  if(remainingTime <= 0) {
      randomSeed(theSeed++);
      // --- mint ERC-20 (currency) ---
      if(mintERC20Token()) {
        if (ERC20Count % 24 == 0) {
          uCount = 1;
          vCount = (ERC20Count/24)+1;
          vRange = ((ERC20Count/24)+1)*(PI/6);
        }
        else {
          uCount = ERC20Count % 24;
          uRange = (ERC20Count % 24) * (TWO_PI/24);
        }
          //update the amount minted, show that a token was minted...
          println("show that an ERC-20 token was minted");
          println();
          
      }
      // --- mint ERC-721 (NFT) ---
      int dow = cal.get(Calendar.DAY_OF_WEEK);
      // set up date format
      SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
      Date d = cal.getTime();
      String currTimeStr = formatter.format(d);
      try {
          Date currTime = formatter.parse(currTimeStr);
          //cal.setTime(currTime);

          // check the time ranges
          Date time1 = new SimpleDateFormat("HH:mm:ss").parse("10:00:00");
          Date time2 = new SimpleDateFormat("HH:mm:ss").parse("18:00:00");
          if(currTime.after(time1) && currTime.before(time2)) {
              if(mintERC721Token(tokenURI)) {
                certificateTxt[0] = timestamp();
                certificateTxt[1] = "pH: " + str(pH);
                certificateTxt[2] = "Benzo(a)pyrene: " + str(benzoApyrene) + " PPM";
                certificateTxt[3] = "Arsenic: " + str(arsenic) + " PPM";
                //update the amount minted, show that a token was minted...
                println("show that an ERC-721 token was minted");
                println();
              }

          }

      } catch(ParseException pe) {
          println("Error parsing the date/time!");
          println(pe.toString());
      }

      //previousMillis = currentMillis;

      startTime = millis(); // reset the timer
  }


  // if new sensor data input
  //update sensors

  //getSensors
  
  // Display the soil moisture value and token balance
  /*
  textSize(20);
  textAlign(CENTER);
  text("benzoApyrene: " + benzoApyrene, width/2, height/4);
  text("arsenic: " + arsenic, width/2, height/3);
  text("pH: " + pH, width/2, height/2);
  //text("powerH: " + power, width/2, height/2 + 100);
  */
  
  // --- Data Viz Code Additions ---
  image(theLogo, 70, 50, 288, 103);
  drawMainText();
  //drawCircleViz();
  //drawText();

  // Set lights
  lightSpecular(255, 255, 255);
  directionalLight(255, 255, 255, 1, 1, -1);
  specular(meshSpecular, meshSpecular, meshSpecular);
  shininess(5.0);
  
  // ------ set view ------
  pushMatrix();
  //translate(width*0.5, height*0.5);
  translate(width*0.7, height*0.5);

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
  ii = 0;
  
  theMesh.setMeshDistortion(meshDistortion);
  
  
  //benzoData = 0.8;
  
  if (changeData) {
    theData = new float[(uCount+1)*(vCount+1)];
    ii = 0;
    for (int iu = 0; iu <= uCount; iu++) {
      for (int iv = 0; iv <= vCount; iv++) {
        meshDistortion = arsenicData;
        meshDistortion += 0.01;
        theData[ii] = arsenicData + random(0.051);
        ii++;
      }
    }
    theMesh.updateData(theData);
  }
  else {
    theMesh.update();
  }
  
  theMesh.update();
  colorMode(HSB, 360, 100, 100, 100);
  strokeWeight(0.01);
  stroke(60,100,100,60);
  
  theMesh.draw();
  
  colorMode(RGB, 255, 255, 255, 100);
  
  popMatrix();
  targetRotationY += 0.01;
  
  // ------ image output and gui ------

  // image output
  if (saveOneFrame) {
    saveFrame(timestamp()+".png");
  }
  
  image(theMovie, 70, 500, 672, 378);

  // draw next tile for high quality output
  tiler.post();
  
  
  //---------- Viz / Mesh Draw ---------------
  if (uCount <= 15 && prevUCount != uCount) {
    meshTagW = 300;
    meshOffsetX = meshTagW/2;
    newTargetX = meshTagX - meshOffsetX;
    artistTag.setTheX(newTargetX);
    artistTag.setTheWidth(meshTagW);
    prevUCount = uCount;
  }
  else if (uCount > 15 && uCount <= 20 && prevUCount != uCount) {
    meshTagW = 400;
    meshOffsetX = meshTagW/2;
    newTargetX = meshTagX - meshOffsetX;
    artistTag.setTheX(newTargetX);
    artistTag.setTheWidth(meshTagW);
    prevUCount = uCount;
  }
  else if (uCount > 20 && uCount <= 25 && prevUCount != uCount) {
    meshTagW = 500;
    meshOffsetX = meshTagW/2;
    newTargetX = meshTagX - meshOffsetX;
    artistTag.setTheX(newTargetX);
    artistTag.setTheWidth(meshTagW);
    prevUCount = uCount;
  }
  else if (uCount > 25 && uCount <= 30 && prevUCount != uCount) {
    meshTagW = 600;
    meshOffsetX = meshTagW/2;
    newTargetX = meshTagX - meshOffsetX;
    artistTag.setTheX(newTargetX);
    artistTag.setTheWidth(meshTagW);
    prevUCount = uCount;
  }
  
  artistTag.drawTarget();
}

boolean getSensors() {
    try {
        JSONObject sensors = loadJSONObject(serverURL + getSensorsEndpoint);
        benzoApyrene = sensors.getInt("benzoApyrene") / 100.0; // 100.0; convert value to float (with proper decimal place)
        arsenic = sensors.getInt("arsenic") / 100.0; // 100.0; convert value to float (with proper decimal place)
        pH = sensors.getInt("pH") / 100.0; // convert value to float (with proper decimal place)
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
        GetRequest get = new GetRequest(serverURL + mintERC721Endpoint +"?tokenURI="+filepath);
        get.send();
        String numMintedStr = get.getContent();
        println("mintERC721Token():");
        System.out.println("Reponse Content: " + numMintedStr);
        System.out.println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
        
        // check if token was actually minted
        int numERC721TokensMinted = Integer.parseInt(numMintedStr);
        println("number of ERC-721 tokens minted so far: " + numERC721TokensMinted);
        if(numERC721TokensMinted > ERC721Count) {
            ERC721Count = numERC721TokensMinted;
            saveFrame(timestamp() + "_viz.png");
            tiler.init(timestamp()+".png", qualityFactor);
            //saveFrame(timestamp() + "_viz.png");
            tilerTwo.init(timestamp()+".png", qualityFactor);
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

void displayTime(int timeInSeconds) {
    int minutes = timeInSeconds / 60;
    int seconds = timeInSeconds % 60;
    
    String timeString = nf(minutes, 2) + ":" + nf(seconds, 2); // Format the time string
  
    //textAlign(CENTER, CENTER);
    //textSize(48);
    if(timeInSeconds < 60) {
        fill(208, 0, 27);
    } else {
        fill(0, 255, 255);
    }
    //text(timeString, width/2, height/2);
    textFont(countFont);
    text(timeString, 1130, 1020);
}

// rounds a number to 2 decimal places
// example: round(3.14159) -> 3.14
float round2(float value) {
   return (int(value * 100 + 0.5)) / 100.0;
}

void keyPressed() {
  if (key == 'u') {
    updateSensors();
  }
  if (key == 'g') {
    getSensors();
  }
  
  if (key == 'm' || key == 'M') {
    cFrame.openFrame();
  }
  
  if (key == 'p' || key == 'P') {
    saveFrame(timestamp() + "_viz.png");
    tiler.init(timestamp()+".png", qualityFactor);
  }
  
  if (key == 'c') {
    if(cursorOn) {
      noCursor();
      cursorOn=false;
    } else {
      cursor();
      cursorOn=true;
    }
    
  }
}

// --- New Viz Functions ---


void slider(float theValue) {
  println("Slider value incoming event. the value: " + theValue);
  //meshDistortion = (theValue * 0.001);
  //theMesh.setMeshDistortion(meshDistortion);
}

void sliderTwo(float theValue) {
  println("Slider value incoming event. the value: " + theValue);
  // The UPDATE To the Benzo Data Point and the Mesh Distortion going here temporarily - this needs to get mvoed to the Minting Functions
  benzoData = map(benzoApyrene, 0,20, 0.05,0.9);
  println("New Benzo Data came through and the Benzo Data point was remapped for mesh distortion: " + benzoData + " was the mapped Benzo Data.");
}


void sliderThree(float theValue) {
  arsenicData = map(arsenic, 0,20, 0.05,0.9);
  println("Slider value incoming event. the value: " + theValue);
  //meshDistortion = (theValue * 0.001);
  //theMesh.setMeshDistortion(meshDistortion);
}

void controlEvent(ControlEvent theEvent) {
  println("Control Event occured: " + theEvent);
  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller " + theEvent.getName() + ":" + theEvent.getStringValue());
  }
}



void drawMainText() {
  textFont(erc721CountFont);
  fill(mainTxtCol, 100);
  //text(nf(ERC721Count, 3), 1776, 220);
  
  //theTxt.toUpperCase();
  fill(activeColor, 100);
  textFont(theFont);
  text(theTxt, 70, 445);
  
  fill(activeColor, 100);
  textFont(addressFont);
  text(erc20, 816, 80);
  text(erc20Address, 1201, 80);
  text(erc721, 816, 120);
  text(erc721Address, 1201, 120);
  
  
  fill(mainTxtCol, 100);
  textFont(countFont);
  //text(remediation, 70, 940);
  //text(creditsCount + ERC20Count, 70, 900);
  text(creditsCount + ERC20Count, 70, 940);
  text(certCount + ERC721Count + "/56", 1280, 940);
  text(countDownTxt, 700, 1020);
}


void movieEvent(Movie m) {
  m.read();
}


class TargetGraphic {
  float tw = 0;
  float th = 0;
  float tx = 0;
  float ty = 0;
  float x1,x2,x3,x4, y1,y2,y3,y4;
  color targetColor = color(255);
  String labelTtl = "Item Name";
  String labelInfo = "description for item.";
  
  TargetGraphic(float theX, float theY, float theW, float theH) {
    tx = theX;
    ty = theY;
    tw = theW;
    th = theH;
    x1 = tx;
    y1 = ty;
    x2 = x1 + (tw/3);
    y2 = y1 + (th/3);
    x3 = (x1 + tw) - (tw/3);
    y3 = (y1 + th) - (th/3);
    x4 = x1 + tw;
    y4 = y1 + th;
  }
  
  void drawTarget() {
    strokeWeight(1.5);
    stroke(targetColor);
    // Top Left Corner
    line(x1, y1, x2, y1);
    line(x1, y1, x1, y2);
    // Top Right Corner
    line(x4, y1, x3, y1);
    line(x4, y1, x4, y2);
    // Bottom Left Corner
    line(x1, y4, x1, y3);
    line(x1, y4, x2, y4);
    // Bottom Right Corner
    line(x4, y4, x4, y3);
    line(x4, y4, x3, y4);
  }
  
  void setTheWidth(float theValue) {
    tw = theValue;
    x1 = tx;
    y1 = ty;
    x2 = x1 + (tw/3);
    y2 = y1 + (th/3);
    x3 = (x1 + tw) - (tw/3);
    y3 = (y1 + th) - (th/3);
    x4 = x1 + tw;
    y4 = y1 + th;
  }
  
  void setTheX(float theValue) {
    tx = theValue;
    x1 = tx;
    y1 = ty;
    x2 = x1 + (tw/3);
    y2 = y1 + (th/3);
    x3 = (x1 + tw) - (tw/3);
    y3 = (y1 + th) - (th/3);
    x4 = x1 + tw;
    y4 = y1 + th;
  }
}




// --- MultiDisplay Class ---
class MultiDisplay extends PApplet {
  int w, h;
  int display;
  PApplet parent;
  
  public MultiDisplay(PApplet theParent, int theDisplay, String theName) {
    super();
    parent = theParent;
    display = theDisplay;
  }
  
  public void settings() {
    fullScreen(P3D, display);
  }
  
  public void setup() {
    background(0);
    tilerTwo = new TileSaver(this);
    println("The width of the second display is: " + this.width);
    println("The height of the second display is: " + this.height);
  }
  
  public void openFrame() {
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  
  void draw() {
    background(0);
    randomSeed(theSeed);
    // for high quality output
    if (tilerTwo==null) return; 
    tilerTwo.pre();
    //image(bacteria, 700, 300, 400, 429);
    
    drawCircleViz();
    
    drawText();
    pushMatrix();
    translate(-850, 50);
    drawNFTViz(nftCount);
    popMatrix();
    
    pushMatrix();
    translate(-350, 50);
    drawNFTViz(nftCount);
    popMatrix();
    
    // draw next tile for high quality output
    tilerTwo.post();
  }
  
  
  //----------Viz functions---------

  public void drawCircleViz() {
    strokeWeight(0.75);
    noFill();
    stroke(255, 255, 0);
    rect(150, 150, 1620, 817);
    noStroke();
    fill(255, 255, 0);
    text("ERC 721 Certificate of Authenticity", 475, 200);
  
    
    float phRadius = map(pH, 0.0, 14.0, 20.0, 120.0);
    float benzoRadius = map(benzoApyrene, 0.0, 20.0, 20.0, 150.0);
    float arsenicRadius = map(arsenic, 0.0, 50.0, 20.0, 150.0);
    
    /*
    pushMatrix();
    fill(190, 205, 255, 70);
    drawNFTp(300, 520, 100);
    fill(150, 180, 255, 70);
    drawNFTp(330, 520, 100);
    popMatrix();
    
    pushMatrix();
    fill(180, 255, 215, 70);
    drawNFTb(300, 650, 100);
    fill(150, 255, 205, 70);
    drawNFTb(330, 650, 100);
    popMatrix();
    
    pushMatrix();
    fill(200, 180, 215, 70);
    drawNFTa(300, 780, 100);
    fill(225, 150, 255, 70);
    drawNFTa(330, 780, 100);
    popMatrix();
    */
  }
  
  public void drawNFTViz(int theCount) {
    float pMap = map(pH, 0,14, 18,24);
    float bMap = map(benzoApyrene, 0,1, 16,22);
    float aMap = map(arsenic, 0,20, 18,24);
    float pCol = map(pH, 0,9, 150,255);
    for (int i = 0; i < theCount; i++) {
      float colDiff = random(1);
      //colDiff /= theCount;
      pCol *= colDiff;
      fill(150, 180, 255, 80);
      //fill(150, 180, pCol, 80);
      //drawNFTData(nftPx+(i*22), nftPy, pMap, 2);
      //fill(180, 255, 215, 80);
      //drawNFTData(nftBx+(i*22), nftBy, bMap, 2);
      //fill(200, 180, 215, 80);
      //drawNFTData(nftAx+(i*22), nftAy, aMap, 2);
      drawNFTData(nftPx+(i*random(-1,21)), nftPy+random(-1,1), pMap, 2);
      fill(180, 255, 215, 80);
      drawNFTData(nftBx+(i*random(-1,21)), nftBy+random(-1,1), bMap, 2);
      fill(200, 180, 215, 80);
      drawNFTData(nftAx+(i*random(-1,21)), nftAy+random(-1,1), aMap, 2);
    }
  }


  public void drawNFTData(float theX, float theY, float theRadius, float theFactor) {
    float x = theX;
    float y = theY;
    float distribution = 0;
    if (x <= 1800) {
      distribution = randomGaussian() * 12;
      x += distribution;
    }
    else if (x > 1800 && x < 2280) {
      distribution = randomGaussian() * 12;
      x += distribution;
      x = x - 485;
      y += 20;
    }
    else if (x >= 2280 && x < 2760) {
      distribution = randomGaussian() * 12;
      x += distribution;
      x = x - 970;
      y += 40;
    }
    else if (x >= 2760 && x < 3240) {
      distribution = randomGaussian() * 12;
      x += distribution;
      x = x - 1455;
      y += 60;
    }
    else if (x >= 3240 && x < 3720) {
      distribution = randomGaussian() * 12;
      x += distribution;
      x = x - 1940;
      y += 80;
    }
    else if (x >= 3720 && x < 4220) {
      distribution = randomGaussian() * 12;
      x += distribution;
      x = x - 2425;
      y += 100;
    }
    else if (x >= 4220 && x < 4730) {
      distribution = randomGaussian() * 12;
      x += distribution;
      x = x - 2910;
      y += 120;
    }
    ellipse(x, y, theRadius, theRadius);
    float x2 = x+theRadius/2;
    ellipse(x+theRadius/2, y, theRadius/theFactor, theRadius/theFactor);
    float x3 = x2+(theRadius/theFactor)/2;
    ellipse(x3, y, (theRadius/theFactor)/2, (theRadius/theFactor)/2);
  }


  public void drawText() {
    fill(255, 255, 0);
    textFont(certTtlFont);
    text(certificateTtl, 475, 280);
    
    fill(255);
    for (int i = 0; i < certificateTxt.length; i++) {
      if (i < 4) {
        if (i == 1) fill(phTxtColor);
        else if (i == 2) fill(benzoTxtColor);
        else if (i == 3) fill(arTxtColor);
        else fill(255, 255, 0);
        textFont(certFont);
        text(certificateTxt[i], 475, (i*30)+320);
      }
      else {
        textFont(certFontTwo);
        text(certificateTxt[i], 475, (i*30)+758);
      } 
    }
  }

  public void drawNFTp(float x, float y, float radius) {
    ellipse(x, y, radius, radius);
    /* if (radius > pMinR) {
      drawNFTp(x + radius/pFactor, y, radius/pFactor);
      drawNFTp(x - radius/pFactor, y, radius/pFactor);
    } */
  }
  
  public void drawNFTb(float x2, float y2, float radiusTwo) {
    ellipse(x2, y2, radiusTwo, radiusTwo);
    /* if (radiusTwo > bMinR) {
      drawNFTb(x2 + radiusTwo/bFactor, y2, radiusTwo/bFactor);
      drawNFTb(x2 - radiusTwo/bFactor, y2, radiusTwo/bFactor);
    } */
  }

  public void drawNFTa(float x3, float y3, float radiusThree) {
    ellipse(x3, y3, radiusThree, radiusThree);
    //randomnessThree = random(3);
    //rFactor3 *= randomnessThree;
    /* if (radiusThree > aMinR) {
      drawNFTa(x3 + radiusThree/aFactor, y3, radiusThree/aFactor);
      drawNFTa(x3 - radiusThree/aFactor, y3, radiusThree/aFactor);
    } */
  }


}




String timestamp() {
  // create an instance of the SimpleDateFormat class  
  SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss");
  // set UTC time zone by using SimpleDateFormat class  
  sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
  
  return sdf.format(new Date()) + " GMT";
  
  //return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}
