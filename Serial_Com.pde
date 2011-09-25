// CONSTANTS: message sizes
#define MSG_LEN_realtime     NUM_RGB_LED*3
#define MSG_LEN_color        9
#define MSG_LEN_scroll       3
#define MSG_LEN_strobe       1
#define MSG_LEN_longest      MSG_LEN_realtime

// CONSTANTS: message header types
#define CONNECT_MSG_confirm  255
#define STATUS_MSG_request   254
#define MODE_MSG_realtime    253
#define MODE_MSG_off         252
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
    if (Serial.available()  || blueSerial.available()){
        while(Serial.available() || blueSerial.available()) {    
            byte new_byte;     
            if (Serial.available()){ new_byte = Serial.read();}
            if (blueSerial.available()){ new_byte = blueSerial.read(); }
            
            // STATUS REQUEST: check if current byte is equal to 255 then we know this is a status request message
            if (int(new_byte) == STATUS_MSG_request) {
                send_status_message();
            }

            // NEW MESSAGE START: if this byte is equal to or greater then 129 then we know that this is the start of a new message
            else if (int(new_byte) == MODE_MSG_off) {
                active_mode = MODE_off;
            }
            
            // NEW MESSAGE START: if this byte is equal to or greater then 129 then we know that this is the start of a new message
            else if (int(new_byte) >= 129) {
                msg_type = new_byte;
                reading_msg_flag = true;
                byte_count = 0;
                
            } 

            // MESSAGE END: if this byte is equal to 128 then we know that this is end of a message
            else if (reading_msg_flag) {
                if (int(new_byte) == END_MSG) {
                    parse_serial_msg(msg_type, serial_msg);
                    byte_count = 0;
                    reading_msg_flag = false;
                }
            
                // MESSAGE BODY: if a reading_msg_flag is set to true, and the byte count is smaller than longest possible message, 
                // and the value of the byte is lower than 128 (all message bytes have a value that is less than 127).
                else if ((byte_count < MSG_LEN_longest) && (int(new_byte) <= 128)) {
                    serial_msg[byte_count] = new_byte;  
                    byte_count++;
                }

                // CHECK MESSAGE LENGTH: check to make sure that the length of current message has not exceeded the maximum lenght
                else if (byte_count >= MSG_LEN_longest) {
                    byte_count = 0;
                    reading_msg_flag = false;
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

        case SET_MSG_hsb:
            // go through the message and convert the bites to integers
            for (int i = 0; i < 3; i++){ 
                byte temp_byte_array[] = {0,0,0};
                int index_offset = i * 3;
                for (int j = 0; j < 3; j++){ temp_byte_array[j] = msg_body[index_offset + j]; } 
                set_hsb_color(i, bytes2int_127(temp_byte_array), 0, 1000); 
            }
            break;

        case MODE_MSG_color_hsb:
            // set the active_mode to color mode
            if (active_mode != MODE_color) {
                new_mode = true;
            }
            active_mode = MODE_color;
            // go through the message and convert the bites to integers
            for (int i = 0; i < 3; i++){ 
                byte temp_byte_array[] = {0,0,0};
                int index_offset = i * 3;
                for (int j = 0; j < 3; j++){ temp_byte_array[j] = msg_body[index_offset + j]; } 
                set_hsb_color(i, bytes2int_127(temp_byte_array), 0, 1000); 
            }
            break;

        case MODE_MSG_scroll:
            if (active_mode != MODE_scroll) {
                new_mode = true;
                active_mode = MODE_scroll;
            }
            set_scroll_speed(int(msg_body[0]), 0, 127);
            set_scroll_direction(int(msg_body[1]), 0, 4);
            set_scroll_width(int(msg_body[2]), 0, 127);
            break;

        case MODE_MSG_strobe:
            if (active_mode != MODE_strobe) {
                new_mode = true;
                active_mode = MODE_strobe;
            }
            set_strobe_speed(int(msg_body[0]), 0, 127);
            break;
        default:
            break;    
    }  
}

//void serial_println(char* string_print) {
//    blueSerial.println(string_print);
//    Serial.println(string_print);
//}

void serial_write(byte send_byte) {
    blueSerial.print(send_byte, BYTE);
    Serial.print(send_byte, BYTE);
}

void send_status_message() {
    // initialize byte array that will hold converted integers  
    byte converted_int[] = {0,0,0};    

    load_data();
    
    // send HEADER BYTE
    serial_write(STATUS_MSG_request);  

      // send MESSAGE BODY - start with active mode
      serial_write(byte(active_mode));  
  
      // send serial message with color HSB header and status
      int2bytes_127(map(hsb_vals[0], 0, 360, REMOTE_output_min, REMOTE_output_max), converted_int);
      for (int i = 0; i < 3; i++) serial_write(converted_int[i]);  
      int2bytes_127(hsb_vals[1]*10, converted_int);
      for (int i = 0; i < 3; i++) serial_write(converted_int[i]);  
      int2bytes_127(hsb_vals[2]*10, converted_int);    
      for (int i = 0; i < 3; i++) serial_write(converted_int[i]);  
  
      // send serial message with strobe header and status
      int2bytes_127(map(strobe_speed, STROBE_inter_min, STROBE_inter_max, 0, 127), converted_int);    
      for (int i = 0; i < 3; i++) serial_write(converted_int[i]);  
  
      // send serial message with scroll header and status
      int2bytes_127(map(scroll_speed, SCROLL_inter_min, SCROLL_inter_max, 0, 127), converted_int);    
      for (int i = 0; i < 3; i++) serial_write(converted_int[i]);  
      serial_write(byte(scroll_direction));  
      int2bytes_127(map(scroll_width, 0,  (NUM_RGB_LED-1), 0, 127), converted_int);    
      for (int i = 0; i < 3; i++) serial_write(converted_int[i]);  
    // send END BYTE
    serial_write(END_MSG);  
}
