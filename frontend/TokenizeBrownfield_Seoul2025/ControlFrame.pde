

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
