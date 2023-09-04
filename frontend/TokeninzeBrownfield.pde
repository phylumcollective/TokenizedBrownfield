import http.requests.*;

String serverURL = "http://localhost:8001";
static final String getSensorsEndpoint = "/getSensors";
static final String updateSensorsEndpoint = "/updateSensors";

static final long secondsInMilli = 1000;
static final long minutesInMilli = secondsInMilli * 60;
static final long hoursInMilli = minutesInMilli * 60;
long previousMillis = 0;

// sensor data from the server
int benzoApyrene = 0; //in ppm
int arsenic = 0; //in  ppm
int pH = 0;
//int power = 0; //in millwatt hours

// to send (HTTP "POST") new sensors data to the server
String postBenzoApyrene = ""; //in ppm
String postArsenic = ""; //in  ppm
String postPH = "";
//String postPower = ""; //in millwatt hours

void setup() {
    size(720, 1280);

}

void draw {
    // attempt to mint an ERC20 token every hour
    long currentMillis = millis();
    long difference = currentMillis - previousMillis;
    long elapsedMinutes = round(difference / minutesInMilli);
    if(elapsedMinutes >= 60) {
        if(mintERC20Token()) {
            //update the amount minted, show that a token was minted...
        }
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
}

boolean getSensors() {
    try {
        JSONObject sensors = loadJSONObject(serverURL + getSensorsEndpoint);
        benzoApyrene = sensors.getInt("benzoApyrene");
        arsenic = sensors.getInt("arsenic");
        pH = sensors.getInt("pH");
        //power = sensors.getInt("power");
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
        System.out.println("Reponse Content: " + post.getContent());
        System.out.println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
        return true;
    } catch(Exception e) {
        System.out.println("Something went wrong posting the JSON data");
        e.toString();
        return false;
    }
}

boolean mintERC20Token() {
    return true;
}