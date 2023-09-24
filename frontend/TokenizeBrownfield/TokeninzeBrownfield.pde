import http.requests.*;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.ParseException;

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
static final int countdownDuration = 3600; // 3600 seconds = 1 hour

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

void setup() {
    size(720, 1280);
    cal = Calendar.getInstance(); // calendar to get day of week
    startTime = millis(); // get the current time in milliseconds
}

void draw() {
    background(255);

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

        //previousMillis = currentMillis;

        startTime = millis(); // reset the timer
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
  
    textAlign(CENTER, CENTER);
    textSize(48);
    if(timeInSeconds < 60) {
        fill(208, 0, 27);
    } else {
        fill(0);
    }
    text(timeString, width/2, height/2);
}

// rounds a number to 2 decimal places
// example: round(3.14159) -> 3.14
float round2(float value) {
   return (int(value * 100 + 0.5)) / 100.0;
}