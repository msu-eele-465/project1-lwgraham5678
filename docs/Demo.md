# Project 1 Heartbeat LED

## Goal

In this project The MSP430 will be programmed to Blink both LEDs at 0.5 hz with two different methods. The first method on the red LED will be to use a delay loop to wait until the LED should be toggled. The second method on the green LED will be to set a timer interrupt to toggle the LED at a given time.

## Main Loop Flowchart

![Fig1](assets/Proj1-flowchart-Main-FC.svg)

*Figure 1: Main Loop Flowchart*

## Red LED delay loop

### Code Design

![Fig2](assets/Proj1-flowchart-Flash-Red-LED-FC.svg)

*Figure 2: Flash Red LED Flowchart*

![Fig3](assets/Proj1-flowchart-Delay-FC.svg)

*Figure 3: Delay Flowchart*

Figures 2 and 3 show the logic for the code design of the red LED running on the delay loop.

## Green LED delay loop

### Code Design

![Fig4](assets/Proj1-flowchart-Timer-Interrupt-FC.svg)

*Figure 4: Flash Green LED Timer B0 Flowchart*

Figure 4 shows the logic for the code design of the green LED running on the timer interrupt.
