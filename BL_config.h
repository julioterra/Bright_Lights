/*
 Bright Lights Config, configration file for Bright Lights project.
 Created by Julio Terra, September 23, 2011.
   
 File name: BL_config.h 
 
 */

#ifndef config_h
#define BL_config_h

#include "WProgram.h"

/** \file
 Configuration for AMUP sketches. This file holds constants that define variables that are used across multiple.  
 */

// switch states
#define OFF     0    // equivalent to LOW
#define ON      1    // equivalent to HIGH

// LED Related Constants
#define RGB_COUNT                   3   // holds the number of led pins associated to each light (set to three as default)
#define R                           0
#define G                           1
#define B                           2

// LED TLC Constants
#define LED_MAX_BRIGHT_TLC          1000
#define LED_MAX_BRIGHT_MATRIX       1

// Switch Debounce Constants
#define TOGGLE_MAX                  10        // maximum number of toggle states supported by RGB Buttons
#define DIGITAL_SWITCH_DEBOUNCE     50       // interval of time that new input will be ignored via digital sensors

// Midi Output Range - 
#define OUTPUT_MIN                  0
#define OUTPUT_MAX                  127
#define OUTPUT_RANGE                OUTPUT_MAX - OUTPUT_MIN

#endif
