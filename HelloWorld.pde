// Include the libraries:
#include <SD.h>
#include "Wire.h"
#include "LiquidCrystal_I2C.h"
#include <RtcDS1302.h>


// ARDUINO - BREADBOARD
// GND = -
// 5V = +

// MODULES TO BREADBOARD
// GND = -
// VCC = +

// RTC
// DAT = 8
// CLK = 9
// RST = 10
ThreeWire myWire(8, 9, 10); 
RtcDS1302<ThreeWire> Rtc(myWire);

// ULTRASONIC 
#define trigPin 2 // TRIG = 2
#define echoPin 3 // ECHO = 3

// LCD
#define SDAPin A4 // SDA = A4
#define SCLPin A5 // SCL = A5

// BUZZER
#define buzzerPin 5 // I/O = 5

// LED
#define led1Pin 7  // yellow led = 7
#define led2Pin 6  // green led = 6
#define led3Pin 1  // red led = 1

// LCD
// SDA = A4
// SCL = A5
LiquidCrystal_I2C lcd = LiquidCrystal_I2C(0x27, 20, 4); //Change to (0x27,16,2) for 1602 LCD

File dataFile; // Create a file object for writing to the SD card

// Define variables for distance computation 
// FORMULA : distance = duration * 0.034 / 2;

long duration;
int distance;

#define chipSelect 4

void setup() {
  // Define inputs and outputs:
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzerPin, OUTPUT); // Set Buzzer pin as output

  // Initialize the DS1302 module:
  Rtc.Begin();

  // Initiate the LCD:
  lcd.init();
  lcd.backlight();

    // Initialize Serial communication for debugging
  Serial.begin(9600);

  // Initialize the SD card
  if (!SD.begin(chipSelect)) {
    Serial.println("SD card initialization failed!");
    return;
  }
  Serial.println("SD card initialized successfully");
}

void loop() {
  // Clear the trigPin by setting it LOW:
  digitalWrite(trigPin, LOW);
  delayMicroseconds(5);

  // Trigger the sensor by setting the trigPin high for 10 microseconds:
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Read the echoPin. This returns the duration (length of the pulse) in microseconds:
  duration = pulseIn(echoPin, HIGH);

  // Calculate the distance:
  distance = duration * 0.034 / 2; 

  // Display the distance on the LCD:
  lcd.setCursor(0, 0); // Set the cursor to column 1, line 1 (counting starts at zero)
  lcd.print("Distance = "); // Prints string "Display = " on the LCD
  lcd.print(distance); // Prints the measured distance
  lcd.print("cm  "); // Prints "cm" on the LCD, extra spaces are needed to clear previously displayed characters

  if (distance < 10) {
    digitalWrite(buzzerPin, HIGH); // Turn on the buzzer and red led light
    digitalWrite(led1Pin, LOW); // turn off 
    digitalWrite(led2Pin, LOW);
  } else if(distance < 40){
    digitalWrite(buzzerPin, LOW);  // Turn off the buzzer
    digitalWrite(led1Pin, HIGH);
    digitalWrite(led2Pin, LOW);
  }else{
    digitalWrite(buzzerPin, LOW);
    digitalWrite(led1Pin, LOW);
    digitalWrite(led2Pin, HIGH);
  }

  // Read current time from DS1302 and display it on LCD (example):
  RtcDateTime now = Rtc.GetDateTime();
  lcd.setCursor(0, 1); // Set cursor to second line
  lcd.print("Time: ");
  lcd.print(now.Hour(), DEC);
  lcd.print(":");
  lcd.print(now.Minute(), DEC);
  lcd.print(":");
  lcd.print(now.Second(), DEC);

  // Check if it's time to record data to the SD card
  static unsigned long previousMillis = 0;
  const unsigned long interval = 900000; // Record data every 20 seconds
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    // It's time to record data

    // Open the data file in append mode
    dataFile = SD.open("data.txt", FILE_WRITE);

    // Check if the file opened successfully
    if (dataFile) {
      // Write the distance data to the file
       dataFile.print(now.Hour(), DEC);
      dataFile.print(":");
      dataFile.print(now.Minute(), DEC);
      dataFile.print(":");
      dataFile.print(now.Second(), DEC);
      dataFile.print(" - Distance: ");
      dataFile.print(distance);
      dataFile.println(" cm");

      // Close the file
      dataFile.close();

      Serial.println("Data recorded to SD card");
    } else {
      // If the file couldn't be opened, print an error:
      Serial.println("Error opening data file");
    }

    // Update the previousMillis variable for the next interval
    previousMillis = currentMillis;
  }

  delay(100);
}
