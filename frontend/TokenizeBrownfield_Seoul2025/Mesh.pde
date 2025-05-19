


class Mesh {
  final static int PLANE = CUSTOM;
  final static int SPHERE = 1;
  final static int SINE = 2;
  final static int TORUS = 3;
  final static int ELLIPTICTORUS = 4;
  final static int FIGURE8TORUS = 5;
  final static int BOHEMIANDOME = 6;
  final static int DATAPLANE = 7;
  
  //-----------------Mesh Properties - Parameters -----------------------
  int form = SPHERE;
  float uMin = -PI;
  float uMax = PI;
  int uCount = 50;
  
  float vMin = -PI;
  float vMax = PI;
  int vCount = 50;
  
  float[] params = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1        };
  
  int drawMode = TRIANGLE_STRIP;
  float minHue = 0;
  float maxHue = 0;
  float minSaturation = 0;
  float maxSaturation = 0;
  float minBrightness = 50;
  float maxBrightness = 50;
  float meshAlpha = 100;
  
  float meshDistortion = 0;
  
  PVector[][] points;
  
  //-----------------Mesh CONSTRUCTORS-----------------------------------
  Mesh() {
    form = CUSTOM;
    update();
  }

  Mesh(int theForm) {
    if (theForm >=0) {
      form = theForm;
    }
    update();
  }
  
  Mesh(int theForm, int theUNum, int theVNum) {
    if (theForm >= 0) {
      form = theForm;
    }
    uCount = max(theUNum, 1);
    vCount = max(theVNum, 1);
    update();
  }
  
  Mesh(int theForm, float theUMin, float theUMax, float theVMin, float theVMax) {
    if (theForm >= 0) {
      form = theForm;
    }
    uMin = theUMin;
    uMax = theUMax;
    vMin = theVMin;
    vMax = theVMax;
    update();
  }
  
  Mesh(int theForm, int theUNum, int theVNum, float theUMin, float theUMax, float theVMin, float theVMax) {
    if (theForm >= 0) {
      form = theForm;
    }
    uCount = max(theUNum, 1);
    vCount = max(theVNum, 1);
    uMin = theUMin;
    uMax = theUMax;
    vMin = theVMin;
    vMax = theVMax;
    update();
  }
  
  //-----------------------METHODS------------------------------------
  //------------ UPDATE Method: Calculates the Points ----------
  /* ARRAY to hold the grid points
  Going to STORE all POINTS in a 2D ARRAY - a PVector Array - 
  because PVectors have x,y,z coords AS COMPONENTS of position

  'points[i1][i2]' 2D Array
  Initialize the 2-Dimensional Array. The Number of POINTS is always
  ONE MORE than the # of Tiles ('u' and 'v' - represent those tiles)
  */
  void update() {
    points = new PVector[vCount+1][uCount+1];
    
    float u, v;
    for (int iv = 0; iv <= vCount; iv++) {
      for (int iu = 0; iu <= uCount; iu++) {
        u = map(iu, 0,uCount, uMin,uMax);
        v = map(iv, 0,vCount, vMin,vMax);
        
        switch(form) {
          case CUSTOM:
            points[iv][iu] = calculatePoints(u, v);
            break;
          case SPHERE:
            points[iv][iu] = Sphere(u, v);
            break;
          case TORUS:
            points[iv][iu] = Torus(u, v);
            break;
          case SINE: 
            points[iv][iu] = Sine(u, v);
            break;
          case FIGURE8TORUS: 
            points[iv][iu] = Figure8Torus(u, v);
            break;
          case ELLIPTICTORUS: 
            points[iv][iu] = EllipticTorus(u, v);
            break;
          case BOHEMIANDOME: 
            points[iv][iu] = BohemianDome(u, v);
            break;
          case DATAPLANE: 
            //float theW = random(-2, 2);
            float theW = 0;
            points[iv][iu] = DataPlane(u, v, theW);
            break;
          default:
            points[iv][iu] = calculatePoints(u, v);
            break;
        }
      }
    }
  }
  
  void updateData(float[] theData) {
    points = new PVector[vCount+1][uCount+1];
    float u, v, zVal;
    int i = 0;
    for (int iv = 0; iv <= vCount; iv++) {
      for (int iu = 0; iu <= uCount; iu++) {
        u = map(iu, 0,uCount, uMin,uMax);
        v = map(iv, 0,vCount, vMin,vMax);
        zVal = theData[i];
        
        points[iv][iu] = DataPlane(u, v, zVal);
        i++;
      }
    }
  }
  
  //--------------- Getters and Setters---------------
  
  int getForm() {
    return form;
  }
  void setForm(int theValue) {
    form = theValue;
  }
  
  String getFormName() {
    switch(form) {
      case CUSTOM: 
      return "Custom";
    case SPHERE: 
      return "Sphere";
    case TORUS: 
      return "Torus";
    case SINE: 
      return "Sine";
    case FIGURE8TORUS: 
      return "Figure 8 Torus";
    case ELLIPTICTORUS: 
      return "Elliptic Torus";
    case BOHEMIANDOME: 
      return "Bohemian Dome";
    }
    return "";
  }
  
  float getUMin() {
    return uMin;
  }
  void setUMin(float theValue) {
    uMin = theValue;
  }
  
  float getUMax() {
    return uMax;
  }
  void setUMax(float theValue) {
    uMax = theValue;
  }
  
  int getUCount() {
    return uCount;
  }
  void setUCount(int theValue) {
    uCount = theValue;
  }
  
  float getVMin() {
    return vMin;
  }
  void setVMin(float theValue) {
    vMin = theValue;
  }
  
  float getVMax() {
    return vMax;
  }
  void setVMax(float theValue) {
    vMax = theValue;
  }
  
  int getVCount() {
    return vCount;
  }
  void setVCount(int theValue) {
    vCount = theValue;
  }
  
  float[] getParams() {
    return params;
  }
  void setParams(float[] theValues) {
    params = theValues;
  }
  
  float getParam(int theIndex) {
    return params[theIndex];
  }
  void setParam(int theIndex, float theValue) {
    params[theIndex] = theValue;
  }
  
  int getDrawMode() {
    return drawMode;
  }
  void setDrawMode(int theMode) {
    drawMode = theMode;
  }
  
  float getMeshDistortion() {
    return meshDistortion;
  }
  void setMeshDistortion(float theValue) {
    meshDistortion = theValue;
  }
  
  void setColorRange(float theMinHue, float theMaxHue, float theMinSaturation, float theMaxSaturation, float theMinBrightness, float theMaxBrightness, float theMeshAlpha) {
    minHue = theMinHue;
    maxHue = theMaxHue;
    minSaturation = theMinSaturation;
    maxSaturation = theMaxSaturation;
    minBrightness = theMinBrightness;
    maxBrightness = theMaxBrightness;
    meshAlpha = theMeshAlpha;
  }
  
  float getMinHue() {
    return minHue;
  }
  void setMinHue(float minHue) {
    this.minHue = minHue;
  }
  
  float getMaxHue() {
    return maxHue;
  }
  void setMaxHue(float maxHue) {
    this.maxHue = maxHue;
  }
  
  float getMinSaturation() {
    return minSaturation;
  }
  void setMinSaturation(float minSaturation) {
    this.minSaturation = minSaturation;
  }

  float getMaxSaturation() {
    return maxSaturation;
  }
  void setMaxSaturation(float maxSaturation) {
    this.maxSaturation = maxSaturation;
  }

  float getMinBrightness() {
    return minBrightness;
  }
  void setMinBrightness(float minBrightness) {
    this.minBrightness = minBrightness;
  }

  float getMaxBrightness() {
    return maxBrightness;
  }
  void setMaxBrightness(float maxBrightness) {
    this.maxBrightness = maxBrightness;
  }

  float getMeshAlpha() {
    return meshAlpha;
  }
  void setMeshAlpha(float meshAlpha) {
    this.meshAlpha = meshAlpha;
  }
  
  //-------PVector Functions for Calculating Mesh Points--------
  //These are Called Above in the Update Method when the PVector
  //'points[iv][iu]' is being looped thru
  PVector calculatePoints(float u, float v) {
    float x = u;
    float y = v;
    float z = 0;
    
    return new PVector(x, y, z);
  }
  
  PVector DataPlane(float u, float v, float zVal) {
    float x = u;
    float y = v;
    float z = zVal;
    
    return new PVector(x, y, z);
  }
  
  PVector defaultForm(float u, float v) {
    float x = u;
    float y = v;
    float z = 0;
    
    return new PVector(x, y, z);
  }
  
  PVector Sphere(float u, float v) {
    v /= 2;
    v += HALF_PI;
    float x = 2 * (sin(v) * sin(u));
    float y = 2 * (params[0] * cos(v));
    float z = 2 * (sin(v) * cos(u));
    
    return new PVector(x, y, z);
  }
  
  PVector Torus(float u, float v) {
    float x = 1 * ((params[1] + 1 + params[0] * cos(v)) * sin(u));
    float y = 1 * (params[0] * sin(v));
    float z = 1 * ((params[1] + 1 + params[0] * cos(v)) * cos(u));

    return new PVector(x, y, z);
  }

  
  PVector Sine(float u, float v) {
    float x = 2 * sin(u);
    float y = 2 * sin(params[0] * v);
    float z = 2 * sin(u+v);

    return new PVector(x, y, z);
  }


  PVector Figure8Torus(float u, float v) {
    float x = 1.5 * cos(u) * (params[0] + sin(v) * cos(u) - sin(2*v) * sin(u) / 2);
    float y = 1.5 * sin(u) * (params[0] + sin(v) * cos(u) - sin(2*v) * sin(u) / 2) ;
    float z = 1.5 * sin(u) * sin(v) + cos(u) * sin(2*v) / 2;

    return new PVector(x, y, z);
  }

  PVector EllipticTorus(float u, float v) {
    float x = 1.5 * (params[0] + cos(v)) * cos(u);
    float y = 1.5 * (params[0] + cos(v)) * sin(u) ;
    float z = 1.5 * sin(v) + cos(v);

    return new PVector(x, y, z);
  }

  PVector BohemianDome(float u, float v) {
    float x = 2 * cos(u);
    float y = 2 * sin(u) + params[0] * cos(v);
    float z = 2 * sin(v);

    return new PVector(x, y, z);
  }

  
  
  // ------ definition of some mathematical functions ------

  // the processing-function pow works a bit differently for negative bases
  float power(float b, float e) {
    if (b >= 0 || int(e) == e) {
      return pow(b, e);
    } 
    else {
      return -pow(-b, e);
    }
  }

  float logE(float v) {
    if (v >= 0) {
      return log(v);
    } 
    else{
      return -log(-v);
    }
  }

  float sinh(float a) {
    return (sin(HALF_PI/2-a));
  }

  float cosh(float a) {
    return (cos(HALF_PI/2-a));
  }

  float tanh(float a) {
    return (tan(HALF_PI/2-a));
  }
  
  //----------DRAW Method - draw the Mesh----------
  void draw() {
    randomSeed(123);
    int iuMax; int ivMax;
    
    if (drawMode == QUADS || drawMode == TRIANGLES) {
      iuMax = uCount-1;
      ivMax = vCount-1;
    }
    else {
      iuMax = uCount;
      ivMax = vCount-1;
    }
    
    pushStyle();
    colorMode(HSB, 360, 100, 100, 100);
    
    float minH = minHue;
    float maxH = maxHue;
    if (abs(maxH-minH) < 20) maxH = minH;
    float minS = minSaturation;
    float maxS = maxSaturation;
    if (abs(maxS-minS) < 10) maxS = minS;
    float minB = minBrightness;
    float maxB = maxBrightness;
    if (abs(maxB-minB) < 10) maxB = minB;
    for (int iv = 0; iv <= ivMax; iv++) {
      if (drawMode == TRIANGLES) {
        for (int iu = 0; iu <= iuMax; iu++) {
          fill(random(minH,maxH), random(minS,maxS), random(minB,maxB), meshAlpha);
          beginShape(drawMode);
          float r1 = meshDistortion * random(-1, 1);
          float r2 = meshDistortion * random(-1, 1);
          float r3 = meshDistortion * random(-1, 1);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
          endShape();
          
          fill(random(minH,maxH), random(minS,maxS), random(minB,maxB), meshAlpha);
          beginShape(drawMode);
          r1 = meshDistortion * random(-1, 1);
          r2 = meshDistortion * random(-1, 1);
          r3 = meshDistortion * random(-1, 1);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv][iu+1].x+r1, points[iv][iu+1].y+r2, points[iv][iu+1].z+r3);
          endShape();
        }
      }
      else if (drawMode == QUADS) {
        for (int iu = 0; iu <= iuMax; iu++) {
          fill(random(minH,maxH), random(minS,maxS), random(minB,maxB), meshAlpha);
          beginShape(drawMode);
          float r1 = meshDistortion * random(-1, 1);
          float r2 = meshDistortion * random(-1, 1);
          float r3 = meshDistortion * random(-1, 1);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv][iu+1].x+r1, points[iv][iu+1].y+r2, points[iv][iu+1].z+r3);
          endShape();
        }
      }
      else {
        float theHue = map(iv, 0,ivMax, minH,maxH);
        fill(theHue, random(minS,maxS), random(minB,maxB), meshAlpha);
        beginShape(drawMode);
        for (int iu = 0; iu <= iuMax; iu++) {
          float r1 = meshDistortion * random(-1, 1);
          float r2 = meshDistortion * random(-1, 1);
          float r3 = meshDistortion * random(-1, 1);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
        }
        //One Shape or STRIP is one COMPLETE iteration thru a Row or 'iu':
        endShape();
      }
    }
    popStyle();
  }
}
