Row[] rows = new Row [4];
char[] binarray = new char[7];
int[] temperatures = { 10, 20, 30, 5, };
String[] daytimes = { "06:00:00", "12:00:00", "18:00:00", "00:00:00" };
int[] weatherIds = { 666, 666, 666, 666 };

int border = 5;
int boxsize = 75;
int checkFrequency = 600000;             // How often the weather data is refreshed, in milliseconds
int ypos = border;
int weatherId;
int weatherTemperature;
int timer;
String dateTomorrow = "2017-09-12";
// String getDate = year() + "-" + month() + "-" + day();
color rowColor;
JSONObject jsonData;
JSONObject weatherObj;
JSONArray weatherData;
String weatherTime;
String apiKey = "REMOVED";
String locationKey = "id=2925533";         // Frankfurt am Main
//String locationKey = "q=kolkata,in";    // Example locationKey for use without location ID
String apiQuery = "http://api.openweathermap.org/data/2.5/forecast?units=metric&" + locationKey + "&" + apiKey;

void setup() {
  size(565, 325);
  background(100);
  fill(255);

  for (int i = 0; i < rows.length; i++) {
    rows[i] = new Row();
  }
  
  weatherData = getWeatherData();        // Puts JSON data into weatherData

  /*                                     // Debug shizzle
   weatherId = getWeatherIdFromArr(0);
   println("Forecast weather code is " + weatherId);
   weatherTime = getWeatherTimeFromArr(0);
   println("Time of forecast is " + weatherTime);
   weatherTemperature = getWeatherTemperatureFromArr(0);
   println("Forecast temperature is " + weatherTemperature + "°C");
   */

  getTomorrowsWeather();                // Pulls relevant data from weatherData and sets temperatures[] and weatherIds[]
  println(temperatures);                // Prints temperatures[] for debugging purposes
  println(weatherIds);                  // Prints weatherIds[], cause why the hell not
}


/////////////// END SETUP ////////////////////////


JSONArray getWeatherData() {            // Pulls weather data as JSONArray from api.openweathermap.org
  jsonData = loadJSONObject(apiQuery);
  weatherData = jsonData.getJSONArray("list");
  return(weatherData);
}

/*
JSONObject getJsonObjectFromArr(int objectNr) {    // Are we sure we need this?
  weatherObj = weatherData.getJSONObject(objectNr);
  return(weatherObj);
}
*/

int getWeatherIdFromArr(int objectNr) {  // Gets OWM's weather condition codes from weatherData, more info here: http://openweathermap.org/weather-conditions
  JSONObject idObj = weatherData.getJSONObject(objectNr);
  JSONArray idArr = idObj.getJSONArray("weather");
  idObj = idArr.getJSONObject(0);        // Object 0 is id
  weatherId = idObj.getInt("id");
  return(weatherId);
}

String getWeatherTimeFromArr(int objectNr) { // Gets the corresponding time in the format HH:MM:SS from weatherData
  JSONObject timeObj = weatherData.getJSONObject(objectNr);
  String dttxt = timeObj.getString("dt_txt");
  return(dttxt);
}

int getWeatherTemperatureFromArr(int objectNr) {  // Gets forecast temperatures from weatherData
  JSONObject tempObj = weatherData.getJSONObject(objectNr);
  tempObj = tempObj.getJSONObject("main");
  float tempFloat = tempObj.getFloat("temp");
  int tempInt = round(tempFloat);
  return(tempInt);
}

void getTomorrowsWeather() {          // Pulls relevant data from weatherData and sets temperatures[] and weatherIds[]
  for (int i = 0; i < 16; i++) {
    String time = getWeatherTimeFromArr(i);
    for (int j = 0; j < daytimes.length; j++) {
      if (time.contains(dateTomorrow) && time.contains(daytimes[j])) {
        temperatures[j] = getWeatherTemperatureFromArr(i);
        weatherIds[j] = getWeatherIdFromArr(i);

      }
    }
  }
}
void draw() {

  for (int i = 0; i < 4; i++) {
    rows[i].setTemperature(i);
    rows[i].binarize();
    rows[i].setColor();
    rows[i].display();
    ypos = (ypos + border + boxsize);
  }
  if (millis() - timer >= checkFrequency) {   // re-check weather in the frequency set in checkFrequency
    println("pling!" + timer);        // Debug
    weatherData = getWeatherData();
    timer = millis();
  }
}

public class Row {
  int temperature;
  int weatherId;

  Row() {
  }

  void display() {
    for (int i = 0; i < 7; i++) {
      if (binarray[i] == '1') {
        fill(rowColor);
      } else {
        fill(0);
      }
      rect(border + i * (border + boxsize), ypos, boxsize, boxsize);
    }
  }

  void binarize() {      // Uses binary() to turn temperature ints into arrays containing chars of either 0 or 1
    binarray = (binary(temperature, 7)).toCharArray();
  }

  int setTemperature(int i) {
    rows[i].temperature = temperatures[i];
    return temperature;
  }

  color setColor() {    // Work in progress - colors should be kinda according to weather IDs
    rowColor = 255;
    return(255);
  }
}