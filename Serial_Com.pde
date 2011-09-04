// CONSTANTS: message sizes
#define MSG_LEN_realtime     24
#define MSG_LEN_color        3
#define MSG_LEN_scroll       2
#define MSG_LEN_strobe       1
#define MSG_LEN_longest      MSG_LEN_realtime

// CONSTANTS: message header types
#define MODE_MSG_realtime    255
#define SET_MSG_hsb          129
#define MODE_MSG_color_hsb   192
#define MODE_MSG_strobe      194
#define MODE_MSG_scroll      193

#define END_MSG              128


byte msg_type;
byte serial_msg[MSG_LEN_realtime];
int byte_count = 0;
bool reading_msg_flag = false;


// CONSIDER USING END BYTE TO SIMPLIFY THIS METHOD. 
// then I can just read until the end byte is received, and then send the message to the parse
// message method to sort out what actions to take in response.
void handle_serial() {
    if (Serial.available()){
        while(Serial.available()) {          
            byte new_byte = Serial.read();
            
            // check if current byte is a header byte
            if (int(new_byte) >= 129) {
                msg_type = new_byte;
                reading_msg_flag = true;
                byte_count = 0;
//                parse_mode_from_header(msg_type);
            } 
            
            // if a reading_msg_flag is set to true, and the byte count is smaller than longest possible message, 
            // and the value of the byte is lower than 128 (all message bytes have a value that is less than 127).
            else if (reading_msg_flag && (byte_count < MSG_LEN_longest) && (int(new_byte) < 128)) {
                serial_msg[byte_count] = new_byte;  
                byte_count++;
            }
            else if (int(new_byte) == 128) {
                parse_serial_msg(msg_type, serial_msg);
                byte_count = 0;
                reading_msg_flag = false;
            }
            else if (byte_count >= MSG_LEN_longest) {
                byte_count = 0;
                reading_msg_flag = false;
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
//        case SET_MSG_rgb:
//            color_mode = RGB;
//            for (int i = 0; i < 3; i++) set_rgb_color(i, int(msg_body[i]), 0, 127);
//            process_rgb_msg(msg_body, 0, 127);
//            break;
        case SET_MSG_hsb:
            color_mode = HSB;
            for (int i = 0; i < 3; i++){
                set_hsb_color(i, int(msg_body[i]), 0, 127);
            }
            break;
        case MODE_MSG_color_hsb:
            if (active_mode != MODE_color) new_mode = true;
            active_mode = MODE_color;
            color_mode = HSB;
            for (int i = 0; i < 3; i++){
                set_hsb_color(i, int(msg_body[i]), 0, 127);
            }
            break;
        case MODE_MSG_scroll:
            if (active_mode != MODE_fun || fun_mode_active != FUN_scroll) new_mode = true;
            active_mode = MODE_fun;
            fun_mode_active = FUN_scroll;
            set_scroll_speed(int(msg_body[0]), 0, 127);
            set_scroll_direction(int(msg_body[1]), 0, 4);
            set_scroll_width(int(msg_body[1]), 0, 127);
            break;
        case MODE_MSG_strobe:
            if (active_mode != MODE_fun || fun_mode_active != FUN_strobe) new_mode = true;
            active_mode = MODE_fun;
            fun_mode_active = FUN_strobe;
            set_strobe_speed(int(msg_body[0]), 0, 127);
            break;
        default:
            break;    
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


