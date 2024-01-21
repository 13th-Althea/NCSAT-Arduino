

// Include the libraries:
#include "Wire.h"
#include "LiquidCrystal_I2C.h"


// Define Trig and Echo pin:
#define trigPin 2
#define echoPin 3

// Define SDA and SCL pin for LCD:
#define SDAPin A4 // Data pin
#define SCLPin A5 // Clock pin

// Define Buzzer pin:
#define buzzerPin 4 

#define led1Pin 5  // Change this to the pin you connect the first LED to
#define led2Pin 6  // Change this to the pin you connect the second LED to
#define led3Pin 7 

// Connect to LCD via I2C, default address 0x27 (A0-A2 not jumpered):
LiquidCrystal_I2C lcd = LiquidCrystal_I2C(0x27,20,4); //Change to (0x27,16,2) for 1602 LCD 

// Define variables:
long duration;
int distance;

void setup() {
  // Define inputs and outputs:
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT); 
  pinMode(buzzerPin, OUTPUT); // Set Buzzer pin as output

  // Initiate the LCD:
  lcd.init();
  lcd.backlight();
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
  distance = duration*0.034/2;

  // Display the distance on the LCD:
  lcd.setCursor(0,0); // Set the cursor to column 1, line 1 (counting starts at zero)
  lcd.print("Distance = "); // Prints string "Display = " on the LCD
  lcd.print(distance); // Prints the measured distance
  lcd.print("cm  "); // Prints "cm" on the LCD, extra spaces are needed to clear previously displayed characters

  if (distance < 10) { 
    digitalWrite(buzzerPin, HIGH); // Turn on the buzzer
    digitalWrite(led1Pin, HIGH);   // Turn on the first LED
  } else {
    digitalWrite(buzzerPin, LOW);  // Turn off the buzzer
    digitalWrite(led1Pin, LOW);    // Turn off the first LED
  }

  // Additional logic for the second and third LEDs (customize as needed):
  if (distance < 20) {
    digitalWrite(led2Pin, HIGH); // Turn on the second LED
  } else {
    digitalWrite(led2Pin, LOW);  // Turn off the second LED
  }

digitalWrite(led3Pin, HIGH);
  
  delay(100);
}