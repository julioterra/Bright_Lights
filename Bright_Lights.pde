#include "BL_config.h"

#include <AnalogSwitch.h>
#include <InputElement.h>
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
#define STROBE_speed_min    5
#define STROBE_speed_max    80
#define SCROLL_speed_min    5
#define SCROLL_speed_max    300
#define SCROLL_width_min    1
#define SCROLL_width_max    NUM_RGB_LED-1

// MESSAGE CONTANTS
#define MSG_LEN_realtime     NUM_RGB_LED*3
#define MSG_LEN_color        9
#define MSG_LEN_scroll       3
#define MSG_LEN_strobe       1
#define MSG_LEN_longest      MSG_LEN_realtime

// MESSAGE HEADERS
#define CONNECT_MSG_confirm  255
#define STATUS_MSG_request   254
#define MODE_MSG_realtime    253
#define MODE_MSG_off         252
#define SET_MSG_hsb          129
#define MODE_MSG_color_hsb   192
#define MODE_MSG_strobe      194
#define MODE_MSG_scroll      193
#define END_MSG              128


class Bright_Lights {

  private:
    int* rgb_pins;
    int* EEPROM_addresses;
    Switch* switches;
    AnalogSwitch pot;
    
//    NewSoftSerial blueSerial;
    
    int active_mode;
    bool new_mode;             
    int hsb_vals[NUM_color_ctrls];           // holds the hsb color values
    int rgb_vals[NUM_color_ctrls];           // holds the rgb color values
    int p_control_hsb;                       // current hsb parameter being controlled by physical control

    boolean data_saved;                      // holds if current data has been saved
    long last_save;                          // holds last time data was saved
    int save_interval;                       // interval between time changes being made and saved
    
    int p_control_strobe_scroll;         // holds the current fun mode (strobe or scroll)
  
    // strobe control variables
    int strobe_speed;
    long strobe_last_switch;
    bool strobe_on;
    
    // scroll control variables
    int scroll_speed;
    int scroll_direction;
    int scroll_width;
    long scroll_last_switch;
    int scroll_led_pos;

    
    bool soft_takeover_complete;
    int takeover_direction;

    byte msg_type;
    byte serial_msg[MSG_LEN_realtime];
    int byte_count;
    bool reading_msg_flag;

    void save_data();
    void load_data();
    void soft_set_hsb_color(int, int, int, int);
    void set_hsb_color(int, int, int, int);
    void set_hsb_color(int, int);
    void convertHSB();
    
    void soft_set_strobe_speed(int, int, int);
    void set_strobe_speed(int, int, int);
    void soft_set_scroll_speed(int, int, int);
    void set_scroll_speed(int, int, int);
    void set_scroll_direction(int, int, int);
    void set_scroll_width(int, int, int);
    void strobe_active();
    void scroll_active();
    void scroll_led_array(int, int*, int);
  
    void select_color_param_for_physical_ctrl();
    int select_fun_mode_for_physical_ctrl();
    bool check_soft_takeover(int, int);
    
    void lights_on_realtime(byte*);
    void lights_on_all();
    void lights_on_single_only(int);
    void lights_on_multiple(int*, int);
    void lights_on_single(int);
    void lights_off_all();
    void lights_off_single(int);
    void blink_delay(int);
    
    void parse_serial_msg(byte, byte*);
    void serial_write(byte);
    void send_status_message();

    void control_lights();
    void handle_serial();
    void handle_physical_input();
    
  public:
    Bright_Lights(int*, Switch*, int, int);
    void set_EEPROM(int*);
    void run();


};


int EEPROM_addresses[NUM_color_ctrls+NUM_scroll_ctrls+NUM_strobe_ctrls] = {3,5,7,9,11,13,15};   // assigns address for saving rgb color values
int _rgb_pins[NUM_RGB_LED*3] = {26,25,24, 29,28,27, 0,31,30, 3,2,1, 6,5,4, 9,8,7, 12,11,10, 15,14,13};
Switch switches[NUM_switches] = {Switch(ID_strobe_switch, A0), Switch(ID_color_switch, A1)};
NewSoftSerial blueSerial = NewSoftSerial(2,4);
Bright_Lights bright_lights = Bright_Lights (_rgb_pins, switches, 2, 4);

/********************* 
  SETUP method
     This method initializes both serial ports, the led drivers (TLC5940), and 
     the potentiometer object; and it loads the saved color
  */
void setup() {
    Serial.begin(57600);
    blueSerial.begin(57600);
    Tlc.init();

    bright_lights.set_EEPROM(EEPROM_addresses);
}


/********************* 
  LOOP method
     This method is responsible for handling serial input from bluetooth and USB connections;
     and physical input from the double-pole switch and potentiometer; it also controls the
     lights (via the handle_serial method when in realtime mode, and via the control_lights method
     when in any other mode.
  */
void loop() {
    bright_lights.run();
}

Bright_Lights::Bright_Lights(int* led_pin_array, Switch* switch_array, int bt_rx, int bt_tx) : pot(ID_potentiometer, A2) {
//Bright_Lights::Bright_Lights(int* led_pin_array, InputElement* switch_array, int bt_rx, int bt_tx) : blueSerial(bt_rx, bt_tx) {
   rgb_pins = led_pin_array;
   switches = switch_array;

   active_mode = MODE_off;
   new_mode = false;    
   for (int i = 0; i < NUM_color_ctrls; i++ ) { hsb_vals[i] = 0; } 
   for (int i = 0; i < NUM_color_ctrls; i++ ) { rgb_vals[i] = 0; }
   p_control_hsb = 2;  
   data_saved = 0;         
   last_save = true;
   save_interval = 1500;
   
   p_control_strobe_scroll = 0;          
   strobe_speed = STROBE_speed_max;
   strobe_last_switch = 0;
   strobe_on = false;
    
    // scroll control variables
   scroll_speed = SCROLL_speed_max;
   scroll_direction = 0;
   scroll_width = SCROLL_width_min;
   scroll_last_switch = 0;
   scroll_led_pos = 0;
   
   soft_takeover_complete = false;
   takeover_direction = 0;
  

  msg_type = 0;
  byte_count = 0;
  reading_msg_flag = false;
}

void Bright_Lights::set_EEPROM(int* addresses) {

  EEPROM_addresses = addresses;
  // load colors from EEPROM 
  load_data();
  
  // send ready to connect byte to controller 
  serial_write(CONNECT_MSG_confirm);  

}

void Bright_Lights::run() {
    handle_serial();
//    handle_physical_input();
    if (active_mode != MODE_realtime) { 
        control_lights(); 
    }
    save_data();

}


