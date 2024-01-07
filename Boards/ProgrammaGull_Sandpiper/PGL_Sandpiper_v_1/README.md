# ProgrammaGull Logic Sandpiper
A small development board intended for introductions to FPGA development and university FPGA labs.  
A Lattice iCE40-UP5k is at the heart of the Sandpiper, offering a plethora of hard peripheral options, as well as adequate logic cells to support somewhat large projects.  
  
## Features
- 8 character 7 segment display (serial access)
- 4 direction DPAD and an additional button
- 6 pin PMOD (or GPIO), 2 GPIO with RC low pass filter aliases allowing an on board PDM DAC output
- Optional 4 input SPI ADC (ADC084S051CIMM)
- RGB LED
- 8 SPST slide switches
- 8 single color LEDs (serial access)
- FT2232HQ interface supporting both programming and PC USB <-> FPGA UART via FTDI VCOM
  
As the UP5k has limited GPIO pins for a general purpose development board serial -> parallel and in the future  
parallel to serial interfaces are implemented for the low speed high pin count I/O (7 segment displays, LED banks, etc..), this is notated by (serial access) next to a feature.  

  
## Software Support
Once initial prototypes arrive scripts will be released to integrate the Sandpiper into the Apio ecosystem.  
This open source assembly of tools greatly simplifies lint, build, and upload on many FPGA platforms,  
and is highly recommended for introductory users (and advanced users as well.. it's very practical!)  
  
Standard icestick workflows may also be supported, though this has yet to be seen.
  
## Errata
- First run of boards had reversed LEDs on FT2232HQ, this has been fixed in schematic and PCB
