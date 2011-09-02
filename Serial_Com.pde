// CONSTANTS: message sizes
#define MSG_LEN_realtime     24
#define MSG_LEN_color        3
#define MSG_LEN_scroll       2
#define MSG_LEN_strobe       1

// CONSTANTS: message header types
#define MODE_MSG_realtime    255
#define SET_MSG_rgb          128
#define SET_MSG_hsb          129
#define MODE_MSG_color_hsb   192
#define MODE_MSG_scroll      193
#define MODE_MSG_strobe      194

byte msg_type;
byte serial_msg[MSG_LEN_realtime];
int byte_count = 0;
bool reading_msg_flag = false;

void handle_serial() {
    if (Serial.available()){
        while(Serial.available()) {          
            byte new_byte = Serial.read();
            
            // check if current byte is a header byte
            if (int(new_byte) > 127) {
                msg_type = new_byte;
                reading_msg_flag = true;
                byte_count = 0;
//                parse_mode_from_header(msg_type);
            } 
            
            // if a reading_msg_flag is set to true, and the byte count is smaller than 
            // the longest possible message, and the value of the byte is lower than 128 
            // (all message bytes have a value that is less than 127).
            else if (reading_msg_flag && (byte_count < MSG_LEN_realtime) && (int(new_byte) < 128)) {

                // if msg_type is a realtime message the route appropriately
                if (msg_type == MODE_MSG_realtime) {
                    serial_msg[byte_count] = new_byte;  
                    byte_count++;
                    if (byte_count == MSG_LEN_realtime) {
                        parse_serial_msg(msg_type, serial_msg);
                        byte_count = 0;
                        reading_msg_flag = false;
                    }
                }

                // if msg type equals any of the other msg types then route them appropriately
                else if (msg_type == SET_MSG_rgb || msg_type == SET_MSG_hsb || msg_type == MODE_MSG_color_hsb) {
                    serial_msg[byte_count] = new_byte;  
                    byte_count++;
                    if (byte_count == MSG_LEN_color) {
                        parse_serial_msg(msg_type, serial_msg);
                        byte_count = 0;
                        reading_msg_flag = false;
                    }
                }                

                // if msg type equals any of the other msg types then route them appropriately
                else if (msg_type == MODE_MSG_strobe) {
                    serial_msg[byte_count] = new_byte;  
                    byte_count++;
                    if (byte_count == MSG_LEN_strobe) {
                        parse_serial_msg(msg_type, serial_msg);
                        byte_count = 0;
                        reading_msg_flag = false;
                    }
                }                
            }
        } 
    }
}

void parse_serial_msg(byte msg_header, byte* msg_body) {
    switch(msg_header) {
        case MODE_MSG_realtime:
            active_mode = MODE_realtime;
            lights_on_realtime(msg_body);
            break;
        case SET_MSG_rgb:
            color_mode = RGB;
            for (int i = 0; i < 3; i++) set_rgb_color(i, int(msg_body[i]), 0, 127);
//            process_rgb_msg(msg_body, 0, 127);
            break;
        case SET_MSG_hsb:
            color_mode = HSB;
            for (int i = 0; i < 3; i++) {
                set_hsb_color(i, int(msg_body[i]), 0, 127);
            }
            break;
        case MODE_MSG_color_hsb:
            if (active_mode != MODE_color) new_mode = true;
            active_mode = MODE_color;
            color_mode = HSB;
            for (int i = 0; i < 3; i++) set_hsb_color(i, int(msg_body[i]), 0, 127);
//            process_hsb_msg(msg_body, 0, 127);
            break;
        case MODE_MSG_scroll:
            if (active_mode != MODE_fun || fun_mode_active != FUN_scroll) new_mode = true;
            active_mode = MODE_fun;
            fun_mode_active = FUN_scroll;
            set_scroll(int(msg_body[0]), 0, 127);
            break;
        case MODE_MSG_strobe:
            if (active_mode != MODE_fun || fun_mode_active != FUN_strobe) new_mode = true;
            active_mode = MODE_fun;
            fun_mode_active = FUN_strobe;
            set_strobe(int(msg_body[0]), 0, 127);
            break;
        default:
            break;    
    }  
}

void process_rgb_msg(byte* new_msg, int min_val, int max_val) {
  for (int i = 0; i < 3; i++) set_rgb_color(0, int(new_msg[0]), min_val, max_val);
//  rgb_vals[0] = map(int(new_msg[0]), min_val, max_val, 0, LED_max_level);
//  rgb_vals[1] = map(int(new_msg[1]), min_val, max_val, 0, LED_max_level);
//  rgb_vals[2] = map(int(new_msg[2]), min_val, max_val, 0, LED_max_level);
}

void process_hsb_msg(byte* new_msg, int min_val, int max_val) {
  for (int i = 0; i < 3; i++) set_hsb_color(0, int(new_msg[0]), min_val, max_val);
//  hsb_vals[0] = map(int(new_msg[0]), min_val, max_val, 0, 255);
//  hsb_vals[1] = map(int(new_msg[1]), min_val, max_val, 0, 255);
//  hsb_vals[2] = map(int(new_msg[2]), min_val, max_val, 0, 255);
  convertHSB();
}

void serial_print(char* string_print) {
    Serial.println(string_print);
    blueSerial.println(string_print);
}

void clear_msg(char* process_string) {
    int msg_size = strlen(process_string);
    for (int i = 0; i < msg_size; i ++) {
        process_string[i] = '\0';   
    }
}


