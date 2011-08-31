/********************* 
  HANDLE PHYSICAL INPUT
     This method checks the current state of the switch and potentiometer.
     If the state has changed on either of these, then the new state data
     is routed to the appropriate functions that control the current mode
     and state of the color, or fun mode.
  */
void  handle_physical_input() {
    // check current mode based on switch state
    for(int i = 0; i < NUM_switches; i ++) {
        if (switches[i].available()) {
            new_mode = true;
            int cur_state = switches[i].get_state();
            if (i == ID_strobe_switch && cur_state == HIGH) {
                active_mode = MODE_fun;
                select_fun_mode();
            } else if (i == ID_color_switch && cur_state == HIGH) {
                active_mode = MODE_color;
                select_color();
            } else if (switches[i].get_state() == LOW) {
                active_mode = MODE_off;
            }   
        }
    }
  
    // check pot state and route value to appropriate function
    if (pot.available()) {
        if (active_mode == MODE_fun) {
            set_fun_mode(pot.get_state(), POT_output_min, POT_output_max);
        }
        else if (active_mode == MODE_color) {
            set_color(pot.get_state(), POT_output_min, POT_output_max);
        }
    }
}


/********************* 
  CHECK SOFT TAKEOVER
    Enables soft takeover behavior when switching the parameter that the potentiometer is controlling. 
  */
bool soft_takeover_complete = false;
int takeover_direction = 0;

boolean check_soft_takeover(int old_val, int new_val) {

   if (new_mode) {
        soft_takeover_complete = false;
        new_mode = false;
        if (new_val > old_val) takeover_direction = 1;
        else if (new_val < old_val) takeover_direction = -1;
        else soft_takeover_complete = true;
        return false;    
    }
    
    if (!soft_takeover_complete) {
        if (takeover_direction > 0 && (new_val < old_val + 20)) soft_takeover_complete = true;
        else if (takeover_direction < 0 && new_val > old_val - 20) soft_takeover_complete = true;
    }
    
    if (soft_takeover_complete) return true;
    
    return false;
}
