// Things to change
//    Parse serial messages to control color and fun states

#include <AMUPconfig.h>
#include <AnalogSwitch.h>
#include <Switch.h>
#include <Tlc5940.h>
#include <tlc_config.h>
#include <HSBColor.h>
#include <EEPROM.h>
#include <NewSoftSerial.h>

// CONSTANTS: hold the count of switches, leds, hsb and rgb values, and fun modes
#define NUM_switches        2
#define NUM_RGB_LED         8
#define NUM_color_ctrls     3
#define NUM_fun_modes       2

// CONSTANTS: ids for each switch and potentiometer
#define ID_strobe_switch    0 
#define ID_color_switch     1
#define ID_potentiometer    2

// CONSTANTS: hold the numbers for each of the four main modes
#define MODE_off            0
#define MODE_color          1
#define MODE_fun            2
#define MODE_realtime       3

// CONSTANTS: hold the number for each of the two fun modes
#define FUN_strobe          0     
#define FUN_scroll          1   

// CONSTANTS: pot output range values for potentiometer
#define POT_output_max      255
#define POT_output_min      0
#define POT_output_range    POT_output_max - POT_output_min

// CONSTANTS: assigning the letter R, G, and B the value of their array location
#define R    0  
#define G    1
#define B    2

// CONSTANTS: saving the EEPROM location where the R, G, B color values are stored 
int const EEPROM_color_address[NUM_color_ctrls] = {0,1,2};    // assigns address for saving rgb color values

// CONSTANTS: arrays that hold the pin numbers of each led on the TLC5940 LED drivers
//            on the rgb_pins array the r, g, b pin for each led are grouped together 
int const redPins[NUM_RGB_LED] = {3, 6, 9, 12, 15, 26, 29, 0};
int const greenPins[NUM_RGB_LED] = {2, 5, 8, 11, 14, 25, 28, 31};
int const bluePins[NUM_RGB_LED] = {1, 4, 7, 10, 13, 24, 27, 30};
int const rgb_pins[NUM_RGB_LED*NUM_color_ctrls] = {3,2,1, 6,5,4, 9,8,7, 12,11,10, 15,14,13, 26,25,24, 29,28,27, 0,31,30};

// VARIABLES: overall mode variables
int active_mode = MODE_off;        // holds the current mode state
bool new_mode = false;             // holds whether the mode has changed (either active or fun)
                                   // variable used to drive the soft takeover on the potentiometer

// VARIABLES: color control state variable; active rgb or hsb parameter variables; and hsb and rgb value arrays 
int color_control = 1;             // holds whether the light is controlled by RGB (0) or HSB (1) mode
int active_rgb = B;                // holds rgb parameter currently controlled by the potentiometer
int active_hsb = 2;                // holds hsb parameter currently controlled by the potentiometer
int hsb_vals[NUM_color_ctrls] = {0,0,0};    // holds the hsb values 
int rgb_vals[NUM_color_ctrls] = {0,0,0};    // holds the rgb values

// VARIABLES: fund mode control state variable; strobe and scroll variables 
int fun_mode_control = 0;          // holds the current fun mode (strobe or scroll)

// strobe control variables
long strobe_interval = 18;
long strobe_last_switch = 0;
bool strobe_on = false;

// scroll control variables
long scroll_interval = 50;
long scroll_last_switch = 0;
int scroll_led_active = 0;

// OBJECTS: switch and analog switch objects corresponding to physical switches and potentiometers
Switch switches[NUM_switches] = {Switch(ID_strobe_switch, A0), Switch(ID_color_switch, A1)};
AnalogSwitch pot = AnalogSwitch(ID_potentiometer, A2);

// OBJECTS: create a soft serial port object for bluetooth connection
NewSoftSerial blueSerial = NewSoftSerial(2, 4);


/* SETUP method
     This method initializes both serial ports, the led drivers (TLC5940), and 
     the potentiometer object; and it loads the saved color
  */
void setup() {
  // initiliaze both serial ports
  Serial.begin(57600);
  blueSerial.begin(57600);
  serial_print("connection started");
  
  // initialized the LED driver (TLC5940)
  Tlc.init();

  // initialize the potentiometer
  pot.invert_switch(true);
  pot.set_analog_range(0, 1023);
  pot.set_output_range(POT_output_range);

  // load colors from EEPROM 
  load_colors();
  //  for (int i; i < NUM_color_ctrls; i++) rgb_vals[i] = EEPROM.read(EEPROM_color_address[i]);
}


/* LOOP method
     This method is responsible for handling serial input from bluetooth and USB connections;
     and physical input from the double-pole switch and potentiometer; it also controls the
     lights (via the handle_serial method when in realtime mode, and via the control_lights method
     when in any other mode.
  */
void loop() {
    handle_serial();
    handle_physical_input();
    if (active_mode != MODE_realtime) { 
        control_lights(); 
    }
}




