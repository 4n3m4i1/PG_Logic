# ProgrammaGull Sandpiper
The Sandpiper is a complete educational development platform based on the Lattice UP5K.  
Designed for students in introductory FPGA labs and other interested parties.  
A plethora of user I/O options are integrated, allowing a complete system that can  
be used anywhere with minimal setup.
  
  
  
  
  
## Todo
v. Alpha
- Cleanup Layout
- Assess switching PSU
- Serialize Switch Inputs (Par -> Ser)
- Swap GPIO header to manufacturable part
- No ADC Version with 2x6 PMOD
- Add encoder, maybe bring back center DPAD button?
- Consolidate BOM (3x HCS595, discrete PNP and NPN driver for 7 seg)
  
## Errata
v. Alpha
- First board run has reversed UART TX/RX LED orientation (Fixed in KiCad files)
- First board run 7 segment common anode driver transistor bases leak through 74HCS596 input protection diode, all digits are always on.

