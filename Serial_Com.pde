// CONSTANTS: message sizes
#define real_time_msg_length  24
#define color_msg_length      3
#define scroll_msg_length     2
#define strobe_msg_length     1

// CONSTANTS: message header types
#define real_time_msg_type    255
#define rgb_set_msg_type      128
#define hsb_set_msg_type      129
#define color_hsb_msg_type    192
#define scroll_msg_type       193
#define strobe_msg_type       194


byte msg_type;
byte serial_msg[real_time_msg_length];
int byte_count = 0;
bool new_msg_flag = false;

void handle_serial() {
    if (Serial.available()){
        while(Serial.available()) {          
            byte new_byte = Serial.read();
            
            // check if current byte is a header byte
            if (int(new_byte) > 127) {
                msg_type = new_byte;
                new_msg_flag = true;
                byte_count = 0;
                parse_mode_from_header(new_byte);
            } 
            
            
            else if (new_msg_flag && (byte_count < real_time_msg_length) && (int(new_byte) < 128)) {
                if (msg_type == real_time_msg_type) {
                    serial_msg[byte_count] = new_byte;  
                    byte_count++;
                    if (byte_count == real_time_msg_length) {
                        lights_on_realtime(serial_msg);
                        byte_count = 0;
                        new_msg_flag = false;
                    }
                }
                else if (msg_type == rgb_set_msg_type || msg_type == hsb_set_msg_type || msg_type == color_hsb_msg_type) {
                    serial_msg[byte_count] = new_byte;  
                    byte_count++;
                    if (byte_count == color_msg_length) {
                        parse_serial_mode(serial_msg);
                        byte_count = 0;
                        new_msg_flag = false;
                    }
                }                
            }
        } 
    }
}

void parse_serial_mode(byte* new_serial_msg) {
//  int midi_channel_number = int(new_msg[0]);
//  if (midi_channel_number == 191) route_MIDI_local(new_msg);
//  else if (midi_channel_number == 176 || midi_channel_number == 177) route_MIDI_i2c(new_msg);
}

void parse_mode_from_header(byte new_header) {

    switch(new_header) {
        case real_time_msg_type:
            active_mode = MODE_realtime;
            break;
        case rgb_set_msg_type:
            break;
        case real_time_msg_type:
            break;
        default:
            break;    
    }  

    if (new_header == real_time_msg_type) {
        active_mode = MODE_realtime;
    }
    else if (new_header == rgb_set_msg_type) { 
        color_control = 0;       // not sure if this line of code is needed
    }     
    else if (new_header == hsb_set_msg_type) { 
        color_control = 1;       // not sure if this line of code is needed
    }     
    else if (new_header == color_hsb_msg_type) {
        active_mode = MODE_color;
        color_control = 1;
    }
    else if (new_header == scroll_msg_type) {
        active_mode = MODE_fun;
        fun_mode_control = FUN_scroll;
    }
    else if (new_header == strobe_msg_type) {
        active_mode = MODE_fun;
        fun_mode_control = FUN_strobe;
    }
 
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

