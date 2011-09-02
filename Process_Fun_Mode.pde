
void set_strobe (int new_val, int min_val, int max_val) {
   strobe_interval = map(new_val, min_val, max_val, 5, 80);  
}

void set_scroll (int new_val, int min_val, int max_val) {
   scroll_interval = map(new_val, min_val, max_val, 5, 80);  
}

void set_scroll_direction (int new_val) {
}

