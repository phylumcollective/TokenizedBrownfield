import http.requests.*;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;
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

// time/countdown stuff
//static final long secondsInMilli = 1000;
//static final long minutesInMilli = secondsInMilli * 60;
//static final long hoursInMilli = minutesInMilli * 60;
//long previousMillis = 0;
int startTime; // Variable to store the starting time
static final int countdownDuration = 3600; // 3600 seconds = 1 hour

// sensor data from the server
float benzoApyrene = 0.0; //in ppm
float arsenic = 0.0; //in  ppm
float pH = 0.0;
//int power = 0; //in millwatt hours

// to send (HTTP "POST") new sensors data to the server
String postBenzoApyrene = "1000"; //in ppm
String postArsenic = "1000"; //in  ppm
String postPH = "700";
//String postPower = ""; //in millwatt hours

// keep track of the number of tokens minted
int ERC20Count = 0;
int ERC721Count = 0;

Calendar cal;


//-------Viz / Mesh Globals------

float pFactor = 1.95;
float bFactor = 1.75;
float aFactor = 2.125;

float pMinR = 75;
float bMinR = 75;
float aMinR = 75;

float nftMap = 1.055;


Mesh theMesh;

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
boolean useBlendBlack = false;


//DEBUG: the uCount and vCount aren't able to change DYNAMICALLY, 
//because the videoData update does NOT Change with it..
//int uCount = 40;
//float uCenter = 0;
//float uRange = TWO_PI;

//int vCount = 2;
//float vCenter = 0;
//float vRange = PI/2;


//TWO_PI = 6.283185307179586
//EACH uCount Increment amount of Range (TWO_PI/40): 0.15707963267949
//TWO_PI / 10: 0.62831853
int uCount = 1;
float uCenter = 0;
float uRange = TWO_PI/40;

int vCount = 1;
float vCenter = 0;
float vRange = PI/6;


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
float rotationX = 0.85, rotationY = -0.4, targetRotationX = 0.0, targetRotationY = 0.0, clickRotationX, clickRotationY; 



// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
ControlP5 cp5;
ControlP5 cp5Two;

ControlFrame cFrame;

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
//String minTxt = "";
//String secTxt = "";
//int minutes = 55;
//int seconds = 23;

PFont certFont; 
PFont certFontTwo;
PFont certTtlFont;
PFont erc721CountFont;
PFont addressFont;
PFont countFont;
PFont labelFont;



void setup() {
  //size(1920,1080,P3D);
  fullScreen(P3D, 2);
  
  //--------- HTTP / Comm Setup --------------


  
  //---------- Viz / Mesh Setup --------------
  //"pH: 7.73 (bottom)"
  //"Benzo(a)pyrene: 110 PPM (top)"
  //"Arsenic: 131 PPM (middle)"
  certificateTxt[0] = "Time: Fri, 06 Oct 2023 11:44:23 GMT";
  certificateTxt[1] = "pH: 0.00 (top)";
  certificateTxt[2] = "Benzo(a)pyrene: 0.00 PPM (middle)";
  certificateTxt[3] = "Arsenic: 0.00 PPM (bottom)";
  certificateTxt[4] = "Soil Source:";
  certificateTxt[5] = "43.13788, -77.62065 (Vacuum Oil Refinery)";
  
  //minTxt = str(minutes);
  //secTxt = str(seconds);
  
  
  //countDownTxt += minTxt;
  //countDownTxt += ":";
  //countDownTxt += secTxt;
  
  // load fonts and set font sizes
  certFont = createFont("SourceCodePro-Regular.ttf", 24);
  certFontTwo = createFont("SourceCodePro-Regular.ttf", 20);
  addressFont = createFont("SourceCodePro-Light.ttf", 24);
  countFont = createFont("SourceCodePro-Light.ttf", 24);
  certTtlFont = createFont("SourceCodePro-Regular.ttf", 34);
  erc721CountFont = createFont("SourceCodePro-Regular.ttf", 24);
  theFont = createFont("SourceCodePro-ExtraLight.ttf", 34);

  labelFont = createFont("SourceCodePro-Regular.ttf", 14); // turn anti-aliasing off
  
  theLogo = loadImage("phylum_logo_dark.png");
  
  cp5 = new ControlP5(this);
  cp5.addSlider("slider").setPosition(70,205).setSize(600,50).setRange(0.0,14.0).setValue(0.0).setFont(labelFont);
  cp5.getController("slider").setLabel("pH");
  cp5.setColorActive(activeColor);
  cp5.setColorBackground(backColor);
  cp5.setColorForeground(frontColor);
  cp5.setColorCaptionLabel(color(34,34,34));
  //CHANGE Label SIZE?? 
  //cp5.setSizeCaptionLabel(24);
  
  //cp5 = new ControlP5(this);
  cp5.addSlider("sliderTwo").setPosition(70,275).setSize(600,50).setRange(0.0,20.0).setValue(0.00).setFont(labelFont);
  cp5.getController("sliderTwo").setLabel("Benzo(a)pyrene");
  cp5.setColorCaptionLabel(color(34,34,34));
  
  cp5Two = new ControlP5(this);
  cp5Two.addSlider("sliderThree").setPosition(70, 345).setSize(600, 50).setRange(0.0, 50.0).setValue(0.00).setFont(labelFont);
  cp5Two.getController("sliderThree").setLabel("Arsenic");
  cp5Two.setColorCaptionLabel(color(34,34,34));
  
  cFrame = new ControlFrame(this, 400, 400, "Controls");
  
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

  cal = Calendar.getInstance(); // calendar to get day of week
  startTime = millis(); // get the current time in milliseconds

  println(timestamp());
}

void draw() {
  background(255);
  
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
                              certificateTxt[0] = timestamp();
                              certificateTxt[1] = "pH: " + str(pH) + " (top)";
                              certificateTxt[2] = "Benzo(a)pyrene: " + str(benzoApyrene) + " PPM (middle)";
                              certificateTxt[3] = "Arsenic: " + str(arsenic) + " PPM (bottom)";
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
                              certificateTxt[0] = timestamp();
                              certificateTxt[1] = "pH: " + str(pH) + " (top)";
                              certificateTxt[2] = "Benzo(a)pyrene: " + str(benzoApyrene) + " PPM (middle)";
                              certificateTxt[3] = "Arsenic: " + str(arsenic) + " PPM (bottom)";
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

      //previousMillis = currentMillis;
      startTime = millis(); // reset the timer
  }


  // if new sensor data input
  //update sensors

  //getSensors
  
 
  
  //---------- Viz / Mesh Draw ---------------
  
  //cp5Two.getController("sliderThree").setValue(arsenic);
  
  drawCircleViz();
  drawText();
  image(theLogo, 70, 50, 288, 103);

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
  targetRotationY += 0.01;
  
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
        benzoApyrene = round2(sensors.getInt("benzoApyrene") / 100.0); // 100.0; convert value to float (with proper decimal place)
        arsenic = round2(sensors.getInt("arsenic") / 100.0); // 100.0; convert value to float (with proper decimal place)
        pH = round2(sensors.getInt("pH") / 100.0); // convert value to float (with proper decimal place)
        //power = sensors.getInt("power");
        cFrame.input(str(pH));
        cFrame.inputTwo(str(benzoApyrene));
        cFrame.inputThree(str(arsenic));
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
            //Updates Mesh when Tokens are minted:
            if (ERC20Count % 40 == 0) {
              uCount = 1;
              vCount = (ERC20Count/40)+1;
              vRange = ((ERC20Count/40)+1)*(PI/6);
            }
            else {
              uCount = ERC20Count % 40;
              uRange = (ERC20Count % 40) * (TWO_PI/40);
            }
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
            /* nftMap = map(ERC721Count, 0,164, 0.925, 1.1175);
            pMinR -= 10;
            if (pMinR < 5) pMinR = 75;
            float pNftMap = map(pH, 0,14, 0.8325, 1.1825);
            pFactor *= pNftMap;
            bMinR -= 10;
            if (bMinR < 5) bMinR = 75;
            float bNftMap = map(benzoApyrene, 0,20, 0.9325,1.1055);
            bFactor *= bNftMap;
            float aNftMap = map(arsenic, 0,50, 0.975,1.0625);
            aFactor *= aNftMap;
            aMinR -= 10;
<<<<<<< Updated upstream
            if (aMinR < 5) aMinR = 50; */
=======
            if (aMinR < 5) aMinR = 75;
>>>>>>> Stashed changes
            saveFrame(timestamp() + "_viz.png");
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

  if(timeInSeconds < 60) {
    fill(208, 0, 27);
  } else {
    fill(34,34,34);
  }
  textFont(countFont);
  text(timeString, 1130, 1020);
}

// rounds a number to 2 decimal places
// example: round(3.14159) -> 3.14
float round2(float value) {
   return (int(value * 100 + 0.5)) / 100.0;
}



//----------Viz functions---------

void drawCircleViz() {
  fill(110);
  rect(1278, 175, 554, 700);

  float center = 1278 + (554 / 2);

  fill(190, 205, 255, 70);
  float phRadius = map(pH, 0.0, 14.0, 20.0, 120.0);
  ellipse(center, 460, phRadius, phRadius); // ph circle

  fill(180, 255, 215, 70);
  float benzoRadius = map(benzoApyrene, 0.0, 20.0, 20.0, 150.0);
  ellipse(center, 590, benzoRadius, benzoRadius); // benzo circle

  fill(225, 150, 100, 70);
  float arsenicRadius = map(arsenic, 0.0, 50.0, 20.0, 150.0);
  ellipse(center, 720, arsenicRadius, arsenicRadius); // arsenic circle
  
/*   pushMatrix();
  fill(190, 205, 255, 70);
  drawNFTp(1430, 460, 100);
  fill(150, 180, 255, 70);
  drawNFTp(1680, 460, 100);
  popMatrix();
  
  pushMatrix();
  fill(180, 255, 215, 70);
  drawNFTb(1430, 590, 100);
  fill(150, 255, 205, 70);
  drawNFTb(1680, 590, 100);
  popMatrix();
  
  pushMatrix();
  fill(200, 180, 215, 70);
  drawNFTa(1430, 720, 100);
  fill(225, 150, 255, 70);
  drawNFTa(1680, 720, 100);
  popMatrix(); */
}

void drawText() {
  fill(255);
  textFont(certTtlFont);
  text(certificateTtl, 1287, 220);
  textFont(erc721CountFont);
  fill(204);
  text(nf(ERC721Count, 3), 1776, 220);
  fill(255);
  for (int i = 0; i < certificateTxt.length; i++) {
    if (i < 4) {
      textFont(certFont);
      text(certificateTxt[i], 1287, (i*30)+280);
    }
    else {
      textFont(certFontTwo);
      text(certificateTxt[i], 1287, (i*30)+698);
    }
    
  }
  
  //theTxt.toUpperCase();
  fill(34, 34, 34);
  textFont(theFont);
  text(theTxt, 70, 445);
  
  fill(34, 34, 34);
  textFont(addressFont);
  text(erc20, 816, 80);
  text(erc20Address, 1201, 80);
  text(erc721, 816, 120);
  text(erc721Address, 1201, 120);
  
  
  fill(34,34,34);
  textFont(countFont);
  //text(remediation, 70, 940);
  //text(creditsCount + ERC20Count, 70, 900);
  text(creditsCount + ERC20Count, 70, 940);
  text(certCount + ERC721Count + "/164", 1280, 940);
  text(countDownTxt, 700, 1020);
}

void drawNFTp(float x, float y, float radius) {
  ellipse(x, y, radius, radius);
  /* if (radius > pMinR) {
    drawNFTp(x + radius/pFactor, y, radius/pFactor);
    drawNFTp(x - radius/pFactor, y, radius/pFactor);
  } */
}

void drawNFTb(float x2, float y2, float radiusTwo) {
  ellipse(x2, y2, radiusTwo, radiusTwo);
  /* if (radiusTwo > bMinR) {
    drawNFTb(x2 + radiusTwo/bFactor, y2, radiusTwo/bFactor);
    drawNFTb(x2 - radiusTwo/bFactor, y2, radiusTwo/bFactor);
  } */
}

void drawNFTa(float x3, float y3, float radiusThree) {
  ellipse(x3, y3, radiusThree, radiusThree);
  //randomnessThree = random(3);
  //rFactor3 *= randomnessThree;
  /* if (radiusThree > aMinR) {
    drawNFTa(x3 + radiusThree/aFactor, y3, radiusThree/aFactor);
    drawNFTa(x3 - radiusThree/aFactor, y3, radiusThree/aFactor);
  } */
}



void keyPressed() {
  //demoData++;
  //cp5.getController("sliderTwo").setValue(demoData);
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
    //drawData = !drawData;
  }
  
  if (key == 't' || key == 'T') {
    changeData = !changeData;
  }
  
  if (key == 'm' || key == 'M') {
    cFrame.openFrame();
  }

  if (key == 'u') {
    updateSensors();
  }
  if (key == 'g') {
    getSensors();
  }
}

void mousePressed() {
  clickX = mouseX;
  clickY = mouseY;
  clickRotationX = rotationX;
  clickRotationY = rotationY;
}

void mouseEntered(MouseEvent e) {
  //loop();
}

void mouseExited(MouseEvent e) {
  //noLoop();
}

void slider(float theValue) {
  println("Slider value incoming event. the value: " + theValue);
  //meshDistortion = (theValue * 0.001);
  //theMesh.setMeshDistortion(meshDistortion);
}

void sliderTwo(float theValue) {
  println("Slider value incoming event. the value: " + theValue);
  
}


void sliderThree(float theValue) {
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

boolean open = false;



class ControlFrame extends PApplet {
  int w, h;
  PApplet parent;
  ControlP5 controlP5;
  PFont frameFont;
  
  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();
    parent = _parent;
    w = _w;
    h = _h;
    //PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  
  public void settings() {
    size(w, h);
  }
  
  public void setup() {
    frameFont = createFont("arial", 20);
    controlP5 = new ControlP5(this);
    controlP5.addTextfield("input").setPosition(20, 100).setSize(200, 40).setFocus(true).setColor(color(255,255,0));
    controlP5.addTextfield("inputTwo").setPosition(20, 200).setSize(200, 40).setFocus(true).setColor(color(255,255,0));
    controlP5.addTextfield("inputThree").setPosition(20, 300).setSize(200, 40).setFocus(true).setColor(color(255,255,0));
    
    textFont(frameFont);
  }
  
  public void openFrame() {
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  
  void draw() {
    background(190);
    fill(255);
    text("Enter in Sensor Values Below.", 80, 50);
    text("pH:", 250, 100);
    text(controlP5.get(Textfield.class, "input").getText(), 250, 120);
    text("Benzopyrene:", 250, 200);
    text(controlP5.get(Textfield.class, "inputTwo").getText(), 250, 220);
    text("Arsenic:", 250, 300);
    text(controlP5.get(Textfield.class, "inputThree").getText(), 250, 320);
  }

  void controlEvent(ControlEvent theEvent) {
    //println("Control Event occured: " + theControlEvent);
    if (theEvent.isAssignableFrom(Textfield.class)) {
      println("controlEvent: accessing a string from controller " + theEvent.getName() + ":" + theEvent.getStringValue());
    }
  }
  
  public void input(String theText) {
    // automatically receives results from controller input
    println("a textfield event for controller 'input' : " + theText);
    demoData += random(1);
    if (demoData > 200) demoData = 0;
    //benzoApyrene = round(demoData);
    pH = round2(float(theText));
    cp5.getController("slider").setValue(pH);
    meshDistortion = (demoData * 0.01);
    postPH = Integer.toString(int(round2(pH) * 100)); // update the pH String repsentation to send to server
    pMinR -= 10;
    if (pMinR < 5) pMinR = 50;
    float pNftMap = map(pH, 0,14, 0.8325, 1.1825);
    pFactor *= pNftMap;
  }
  
  public void inputTwo(String theText) {
    println("Textfield event for controller 'inputTwo' " + theText);
    demoData += random(1);
    if (demoData > 200) demoData = 0;
    //benzoApyrene = round(demoData);
    benzoApyrene = round2(float(theText));
    cp5.getController("sliderTwo").setValue(benzoApyrene);
    meshDistortion = (demoData * 0.01);
    postBenzoApyrene = Integer.toString(int(round2(benzoApyrene) * 100)); // update the benzo(a)pyrene String repsentation to send to server
    bMinR -= 10;
    if (bMinR < 5) bMinR = 50;
    float bNftMap = map(benzoApyrene, 0,1, 0.9125,1.01255);
    bFactor *= (bNftMap*nftMap);
  }
  
  public void inputThree(String theText) {
    println("Testing controller events for something i called blah! what i entered: " + theText);
    demoData += random(1);
    if (demoData > 200) demoData = 0;
    //benzoApyrene = round(demoData);
    arsenic = round2(float(theText));
    cp5Two.getController("sliderThree").setValue(arsenic);
    meshDistortion = (demoData * 0.01);
    postArsenic = Integer.toString(int(round2(arsenic) * 100)); // update the arsenic String repsentation to send to server
    float aNftMap = map(arsenic, 0,20, 0.975,1.0625);
    aFactor *= aNftMap;
    aMinR -= 10;
    if (aMinR < 5) aMinR = 50;
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
