import http.requests.*;
import java.util.Calendar;
import java.text.SimpleDateFormat
import java.util.Date

static final String serverURL = "http://localhost:8001";
static final String getSensorsEndpoint = "/getSensors";
static final String updateSensorsEndpoint = "/updateSensors";
static final String mintERC20Endpoint = "/mintERC20"; // cryptocurrency 
static final String mintERC721Endpoint = "/mintERC721"; // NFT
String tokenURI = ""; // URI/path of the NFT image

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
    Calendar cal = Calendar.getInstance(); // calendar to get day of week
}

void draw() {
    // attempt to mint an ERC20 and ERC721 token every hour
    long currentMillis = millis();
    long difference = currentMillis - previousMillis;
    long elapsedMinutes = round(difference / minutesInMilli);
    if(elapsedMinutes >= 60) {
        // --- mint ERC-20 (currency) ---
        if(mintERC20Token()) {
            //update the amount minted, show that a token was minted...
        }
        // --- mint ERC-721 (NFT) ---
        // skip Mon & Tues
        int dow = cal.get(Calendar.DAY_OF_WEEK);
        if(!dow==Calendar.MONAY || !dow==Calendar.TUESDAY) {
            // set up date format
            SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
            Date d = cal.getTime();
            String currTimeStr = formatter.format(d);
            Date currTime = formatter.parse(currTimeStr);
            //cal.setTime(currTime);
            // Friday hours
            if(dow==Calendar.FRIDAY) {
                // make sure it's between 12-9pm if it's Fri
                Date time1 = new SimpleDateFormat("HH:mm:ss").parse("12:00:00");
                Date time2 = new SimpleDateFormat("HH:mm:ss").parse("21:00:00");
                if(currTime.after(time1.getTime()) && currTime.before(time2.getTime())) {
                    if(mintERC721Token(tokenURI)) {
                        //update the amount minted, show that a token was minted...
                    }

                }
            } else {
                // the rest of the days
                Date time1 = new SimpleDateFormat("HH:mm:ss").parse("12:00:00");
                Date time2 = new SimpleDateFormat("HH:mm:ss").parse("17:00:00");
                if(currTime.after(time1.getTime()) && currTime.before(time2.getTime())) {
                    if(mintERC721Token(tokenURI)) {
                        //update the amount minted, show that a token was minted...
                    }

                }
            }

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

// mint a TerraRete cryptocurrency token
boolean mintERC20Token() {
    try {
        GetRequest get = new GetRequest(serverURL + mintERC20Endpoint);
        get.send();
        println("Reponse Content: " + get.getContent());
        println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
        return true;
    } catch(Exception e) {
        System.out.println("Something went wrong with the server request");
        e.toString();
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
        System.out.println("Reponse Content: " + post.getContent());
        System.out.println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
        return true;
    } catch(Exception e) {
        System.out.println("Something went wrong posting the JSON data");
        e.toString();
        return false;
    }
}

// rounds a number to 2 decimal places
// example: round(3.14159) -> 3.14
float round2(float value) {
   return (int(value * 100 + 0.5)) / 100.0;
}