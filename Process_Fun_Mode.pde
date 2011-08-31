/********************* 
  SELECT FUN MODE
     This method is called whenever the switch is toggled to the fun mode select side.
     When method is called it toggles between the strobe and scroll mode.
   */
void select_fun_mode() {
    fun_mode_control++;
    if (fun_mode_control >= NUM_fun_modes) fun_mode_control = 0;
}


/********************* 
  SET FUN MODE
    Sets the strobe or scroll speed depending on the state of the active_fun_mode variable.
  */
void set_fun_mode(int new_val, int min_val, int max_val) {
    if (fun_mode_control == FUN_strobe) {
        set_strobe(new_val, min_val, max_val);
    }
    else if (fun_mode_control == FUN_scroll) {
        set_scroll(new_val, min_val, max_val);
    }
}

void set_strobe (int new_val, int min_val, int max_val) {
   strobe_interval = map(new_val, min_val, max_val, 5, 80);  
}

void set_scroll (int new_val, int min_val, int max_val) {
   scroll_interval = map(new_val, min_val, max_val, 5, 80);  
}

void set_scroll_direction (int new_val) {
}

