// Things to change
//    Parse serial messages to control color and fun states

#include "BL_config.h"

#include <AnalogSwitch.h>
#include <Switch.h>
#include <HSBColor.h>
#include <Int2Byte.h>

#include <Tlc5940.h>
#include <tlc_config.h>
#include <EEPROM.h>
#include <NewSoftSerial.h>

// CONSTANTS: vary that based on form-factor of led box
// count and number of switches, number of rbg leds
#define NUM_switches        2
#define NUM_RGB_LED         8
#define ID_strobe_switch    0 
#define ID_color_switch     1
#define ID_potentiometer    2

// CONSTANTS: number of color, scroll and strobe controls 
#define NUM_color_ctrls     3
#define NUM_scroll_ctrls    3
#define NUM_strobe_ctrls    1

// CONSTANTS: hold the MODE numbers
#define MODE_off            0
#define MODE_color          1
#define MODE_strobe         2
#define MODE_scroll         3
#define MODE_realtime       4

// CONSTANTS: pot output range values, and led output max value
#define POT_output_max        255
#define POT_output_min        0
#define POT_output_range      POT_output_max - POT_output_min
#define LED_max_level         4000
#define REMOTE_output_max     1000
#define REMOTE_output_min     0
#define REMOTE_output_range   REMOTE_output_max - REMOTE_output_min

// CONSTANTS: scroll and strobe min and max range values
#define STROBE_inter_min    5
#define STROBE_inter_max    80
#define SCROLL_inter_min    5
#define SCROLL_inter_max    300
#define SCROLL_width_min    1
#define SCROLL_width_max    NUM_RGB_LED-1

// CONSTANTS: saving the EEPROM location where the R, G, B color values are stored 
int const EEPROM_hsb_address[NUM_color_ctrls] = {3,5,7};          // assigns address for saving rgb color values
int const EEPROM_scroll_address[NUM_scroll_ctrls] = {9,11,13};    // assigns address for saving speed, direction, width
int const EEPROM_strobe_address[NUM_strobe_ctrls] = {15};    // assigns address for saving speed, direction, width

// CONSTANTS: arrays that hold the pin numbers of each led on the TLC5940 LED drivers
//            on the rgb_pins array the r, g, b pin for each led are grouped together 
int const rgb_pins[NUM_RGB_LED*3] = {26,25,24, 29,28,27, 0,31,30, 3,2,1, 6,5,4, 9,8,7, 12,11,10, 15,14,13};

// VARIABLES: overall mode variables
    int active_mode = MODE_off;        // holds the current mode state
    bool new_mode = false;             // holds whether the mode has changed (either active or fun)
                                       // variable used to drive the soft takeover on the potentiometer

// VARIABLES: color control state variable; active rgb or hsb parameter variables; and hsb and rgb value arrays 
    int p_control_hsb = 2;                         // holds hsb parameter currently controlled by the potentiometer
    int hsb_vals[NUM_color_ctrls] = {0,0,0};    // holds the hsb values 
    int rgb_vals[NUM_color_ctrls] = {0,0,0};    // holds the rgb values

    long last_save = 0;         // holds last time color was changed
    boolean data_saved = false;        // holds if current color has been saved
    int save_interval = 1500;


// VARIABLES: fun mode control state variable; strobe and scroll variables 
    int p_control_strobe_scroll = 0;          // holds the current fun mode (strobe or scroll)
  
    // strobe control variables
    int strobe_speed = STROBE_inter_max;
    long strobe_last_switch = 0;
    bool strobe_on = false;
    
    // scroll control variables
    int scroll_speed = SCROLL_inter_max;
    int scroll_direction = 3;
    int scroll_width = 3;
    long scroll_last_switch = 0;
    int scroll_led_pos = 0;

// OBJECTS: switch and analog switch objects corresponding to physical switches and potentiometers
Switch switches[NUM_switches] = {Switch(ID_strobe_switch, A0), Switch(ID_color_switch, A1)};
AnalogSwitch pot = AnalogSwitch(ID_potentiometer, A2);

// OBJECTS: create a soft serial port object for bluetooth connection
NewSoftSerial blueSerial = NewSoftSerial(2,4);

/********************* 
  SETUP method
     This method initializes both serial ports, the led drivers (TLC5940), and 
     the potentiometer object; and it loads the saved color
  */
void setup() {
  // initiliaze both serial ports
  Serial.begin(57600);
  blueSerial.begin(57600);
  serial_write(255);
  
  // initialized the LED driver (TLC5940)
  Tlc.init();

  // initialize the potentiometer
  pot.invert_switch(true);
  pot.set_analog_range(0, 1023);
  pot.set_output_range(POT_output_range);

  // load colors from EEPROM 
  load_data();
//  load_fun_mode();
}


/********************* 
  LOOP method
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
    save_data();
}




