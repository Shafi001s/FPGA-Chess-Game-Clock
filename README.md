# Chess Game Clock on DE1-SoC FPGA

This project implements a digital chess clock using VHDL on the **DE1-SoC Cyclone V FPGA** development board. It supports two game modes: **Classic** and **Fischer (increment)**. The design includes a user interface with 7-segment displays and button controls for countdown, player switching, time increment, and game resetting.

## Features
- Two-player countdown timer
- Two game modes:
  - **Game Mode 1 (Classic):** Fixed time (1 min to 10 mins) with no increment
  - **Game Mode 2 (Fischer):** 15-second timer with +5 seconds increment per switch
- Time displayed on HEX0–HEX5
- Player switching and reset functionality
- Debounced button inputs
- VHDL-based FSM design using Mealy machine

## Controls
| Button | Function |
|--------|----------|
| **SW0** | Select Game Mode (0 = Classic, 1 = Fischer) |
| **KEY0** | Reset game and set mode |
| **KEY1** | Start the countdown |
| **KEY2** | Switch player |
| **KEY3** | Increase initial time (Game Mode 1 only) |

## How It Works
- The countdown is triggered by a 1Hz pulse generated from the 50 MHz system clock.
- Players alternate turns by pressing the switch player button (KEY2), which pauses their own clock and activates the opponent’s.
- In Game Mode 2, each player gets a +5 second increment after switching.
- The current player's time is displayed on the 7-segment displays and updated every second.

## Display
- **HEX5:** 'P' (Player indicator)
- **HEX4:** Player number (1 or 2)
- **HEX3–HEX0:** MM:SS format of the current player's remaining time
- **LEDR0:** Indicates whether the clock is running

## Getting Started
1. Open Quartus and load the `ChessClock.vhd` file.
2. Assign pins according to your DE1-SoC board using the Pin Planner.
3. Compile the project and load `ChessClock.sof` onto the board.
4. Use the switches and buttons to start and control the game.

## File Structure
- `ChessClock.vhd` – Main VHDL file
- `README.md` – Project overview and instructions
- `State_Machine_Diagram.png` – FSM structure (optional)

## Limitations
- No pause in Game Mode 2
- No win/loss display notification
- Time setup in Game Mode 2 is fixed to 15 seconds

## Educational Scope
This project helps students explore:
- Finite State Machines (FSMs)
- FPGA design and clock management
- Debouncing techniques
- BCD encoding for 7-segment displays
- Hands-on VHDL programming

---


