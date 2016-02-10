EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:eco
LIBS:IC_raspberry
LIBS:eeg-pcb-cache
EELAYER 25 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 1 1
Title "EEG Schema using ads1299"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 4200 4450 0    60   Input ~ 0
SENSOR_P1
Text GLabel 4200 4250 0    60   Input ~ 0
SENSOR_P2
Text GLabel 4200 4050 0    60   Input ~ 0
SENSOR_P3
Text GLabel 4200 3850 0    60   Input ~ 0
SENSOR_P4
Text GLabel 4200 3650 0    60   Input ~ 0
SENSOR_P5
Text GLabel 4200 3450 0    60   Input ~ 0
SENSOR_P6
Text GLabel 4200 3250 0    60   Input ~ 0
SENSOR_P7
Text GLabel 4200 3050 0    60   Input ~ 0
SENSOR_P8
Text GLabel 8900 3450 2    60   Output ~ 0
SPI_MISO
Text GLabel 8900 4350 2    60   Input ~ 0
SPI_MOSI
Text GLabel 8900 3850 2    60   Input ~ 0
CHIP_SELECT
Text GLabel 8900 3050 2    60   Output ~ 0
DATA_READY
Text Notes 10200 1750 0    60   ~ 0
Optional or HIGH (3.3v / DVDD) (Can also been done over SPI)\nPin 35 - PWDN\nPin 36 - RESET\nPin 52 - CLKSEL (selects internal/external clock) HIGH = internal\n\nActive LOW\nPin 39 - CS\nPin 47 - DRDY\nPin 36 - RESET\nPin 35 - PWDN
$Comp
L ads1299 U2
U 1 1 5664505B
P 6950 2600
F 0 "U2" H 7600 1750 60  0000 C CNN
F 1 "ads1299" H 7650 1300 60  0000 C CNN
F 2 "eco-fp:ads1299" H 7050 2450 60  0001 C CNN
F 3 "" H 7050 2450 60  0000 C CNN
	1    6950 2600
	1    0    0    -1  
$EndComp
NoConn ~ 8900 3150
NoConn ~ 8900 3250
NoConn ~ 8900 3350
NoConn ~ 8100 4800
NoConn ~ 7900 4800
NoConn ~ 8900 3550
Text GLabel 8900 3750 2    60   Input ~ 0
SPI_CLOCK
$Comp
L C_Small C13
U 1 1 5665B8D2
P 7800 5650
F 0 "C13" H 7810 5720 50  0000 L CNN
F 1 "1uf" H 7850 5550 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 7800 5650 50  0001 C CNN
F 3 "" H 7800 5650 50  0000 C CNN
	1    7800 5650
	1    0    0    -1  
$EndComp
$Comp
L C_Small C14
U 1 1 5665B920
P 8000 5650
F 0 "C14" H 8010 5720 50  0000 L CNN
F 1 "100uf" V 8100 5400 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 8000 5650 50  0001 C CNN
F 3 "" H 8000 5650 50  0000 C CNN
	1    8000 5650
	1    0    0    -1  
$EndComp
$Comp
L C_Small C15
U 1 1 5665B96B
P 8200 5650
F 0 "C15" H 8210 5720 50  0000 L CNN
F 1 "1uf" H 8250 5550 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 8200 5650 50  0001 C CNN
F 3 "" H 8200 5650 50  0000 C CNN
	1    8200 5650
	1    0    0    -1  
$EndComp
$Comp
L C_Small C12
U 1 1 5665C662
P 7600 5650
F 0 "C12" H 7610 5720 50  0000 L CNN
F 1 "10uf" H 7500 5400 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 7600 5650 50  0001 C CNN
F 3 "" H 7600 5650 50  0000 C CNN
	1    7600 5650
	1    0    0    -1  
$EndComp
$Comp
L C_Small C11
U 1 1 5665C74B
P 7400 5650
F 0 "C11" H 7410 5720 50  0000 L CNN
F 1 ".1uf" H 7410 5570 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 7400 5650 50  0001 C CNN
F 3 "" H 7400 5650 50  0000 C CNN
	1    7400 5650
	1    0    0    -1  
$EndComp
Text Notes -250 1900 0    60   ~ 0
BIAS\n\nt's purpose is to provide negative feedback from the inputs\nto the body in order to stabilize the body's common mode\nvoltage so that it is within the measurable range for the\nADC. In order for it to be effective, you have to connect the\noutput to the inverting input through a feedback network\n(i.e. the 5 MOhm and 1.5 nF). If you wanted to daisy-chain\ndevices, you'd also want to connect the BIAS_INV pins on\nall the devices that are daisy-chained so that the amplifier\ntakes inputs from other devices in the chain as well as its own.\n\nBIAS_DRV is a sensor on the body\n\nBIAS_REF\nyou can instead use an internally generated mid-supply\nvoltage by setting bit 3 of the CONFIG3 register. In that\ncase, the BIAS_REF pin will be internally disconnected\nfrom the amplifier.\n\nBIASIN\nTo reduce the numbers of electrodes you can wire this pin\nto a positive input (INxP) This will introduce a small bias into\nthe signal recorded on that channel, but this should be small\nand slow compared to the signals of interest.\nThis pin can therefore be wired to BIASOUT
$Comp
L R_Small R11
U 1 1 5665DE74
P 6850 2100
F 0 "R11" H 6880 2120 50  0000 L CNN
F 1 "1m" H 6880 2060 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 6850 2100 50  0001 C CNN
F 3 "" H 6850 2100 50  0000 C CNN
	1    6850 2100
	-1   0    0    1   
$EndComp
$Comp
L C_Small C16
U 1 1 5665DEB0
P 7000 2100
F 0 "C16" H 6850 2200 50  0000 L CNN
F 1 "1.5nf" H 6800 2000 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 7000 2100 50  0001 C CNN
F 3 "" H 7000 2100 50  0000 C CNN
	1    7000 2100
	-1   0    0    1   
$EndComp
Text GLabel 4200 2850 0    60   Output ~ 0
BIAS_DRV
NoConn ~ 7300 2450
$Comp
L C_Small C20
U 1 1 5665FE92
P 8700 1650
F 0 "C20" H 8710 1720 50  0000 L CNN
F 1 "1uf" H 8710 1570 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 8700 1650 50  0001 C CNN
F 3 "" H 8700 1650 50  0000 C CNN
	1    8700 1650
	-1   0    0    1   
$EndComp
$Comp
L C_Small C19
U 1 1 5665FF1C
P 8450 1650
F 0 "C19" H 8460 1720 50  0000 L CNN
F 1 "0.1uf" H 8460 1570 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 8450 1650 50  0001 C CNN
F 3 "" H 8450 1650 50  0000 C CNN
	1    8450 1650
	-1   0    0    1   
$EndComp
$Comp
L C_Small C17
U 1 1 566602BF
P 7700 1550
F 0 "C17" V 7650 1600 50  0000 L CNN
F 1 "0.1uf" V 7650 1300 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 7700 1550 50  0001 C CNN
F 3 "" H 7700 1550 50  0000 C CNN
	1    7700 1550
	1    0    0    -1  
$EndComp
$Comp
L C_Small C18
U 1 1 56660324
P 7900 1550
F 0 "C18" V 7950 1600 50  0000 L CNN
F 1 "1uf" V 7950 1350 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 7900 1550 50  0001 C CNN
F 3 "" H 7900 1550 50  0000 C CNN
	1    7900 1550
	1    0    0    -1  
$EndComp
NoConn ~ 6900 2450
Text Notes 850  9750 0    60   ~ 0
COMMON REFERENCE\nSRB1 has option to connect to all/none N inputs by setting\nbit 5 in the MISC1 register.\n\nSRB2 has option to be open or closed to any INDIVIDUAL\nchannel's P input. by setting bit 3 in the individual channel's\nCHnSET register. \n\n* If you use the P inputs for your electrodes, you have the\n   option to connect all of the N inputs together and use SRB1\n   as a reference electrode.\n\n* If you use the N inputs for your electrodes, you have the\n   option to connect some or all of the P inputs together and\n   use SRB2 as reference for those channels you select.\n\nNOTE: Some confusion on using mixed eeg/ecg openbci \napparently has the answer
Text GLabel 4200 4800 0    60   Input ~ 0
SRB_1
Text Notes 850  8050 0    60   ~ 0
SPI INTERFACE\nCS (chip select)  - LOW when SPI is in use (should remain low entire time)\nSCLK (SPI Clock)      - \nDIN (DATA in) MOSI (Master out slave in) - Writing register settings\nDOUT (DATA out) MISO (Master in slave out)  - Read conversion\ndata and register settings\n\nSTART    - switch from normal data capture mode to pulse data capture mode\nor handle through SPI\nDRDY     - LOW when data is available
Text Notes 6050 1200 0    60   ~ 0
POWER\nAVSS - Analog Ground\nAVDD - Analog Supply\nDGND - Digital Ground\nDVDD - Digital Supply\n\nThere are two separate supplies for analog and digital\nEvery supply has to be bypassed their own ground\nwith an .1 and 1 uf capacitor
Text Notes 850  7050 0    60   ~ 0
CLOCK\nTo use internal clock of ADS1299, the CLK_SEL pin must be HIGH.\nIt is possible to output clock through CLK pin by setting CLK_EN\nbit in the CONFIG1 register to 1. Otherwise, this bit may be set to 0,\nwhich would place the CLK pin in a 3-state status.
Text Notes 8550 5850 0    60   ~ 0
vcap{1,2,4} should be connected as close to the chip\nas possible.
$Comp
L Raspberry_Pi_GPIO U1
U 1 1 566731D6
P 14800 5200
F 0 "U1" H 14950 5000 60  0000 C CNN
F 1 "Raspberry_Pi_GPIO" V 15200 4550 60  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x20" H 14800 5200 60  0001 C CNN
F 3 "" H 14800 5200 60  0000 C CNN
	1    14800 5200
	-1   0    0    1   
$EndComp
Text GLabel 15600 4250 2    60   Output ~ 0
DIGITAL_SUPPLY
Text GLabel 12950 4950 0    60   Output ~ 0
ANALOG_SUPPLY
Text GLabel 15600 4150 2    60   Output ~ 0
SPI_MOSI
Text GLabel 15600 4050 2    60   Input ~ 0
SPI_MISO
Text GLabel 15600 3950 2    60   Output ~ 0
SPI_CLOCK
Text GLabel 13250 4050 0    60   Output ~ 0
CHIP_SELECT
Text GLabel 13250 3350 0    60   Input ~ 0
DATA_READY
Text GLabel 8900 4250 2    60   Input ~ 0
POWER_DOWN
Text GLabel 13250 4750 0    60   Input ~ 0
POWER_DOWN
Text GLabel 13250 4650 0    60   Input ~ 0
RESET
$Comp
L R_Small R2
U 1 1 5668BDDF
P 4450 3050
F 0 "R2" V 4350 3150 50  0000 L CNN
F 1 "2.2K" V 4350 2900 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 3050 50  0001 C CNN
F 3 "" H 4450 3050 50  0000 C CNN
	1    4450 3050
	0    1    1    0   
$EndComp
$Comp
L R_Small R3
U 1 1 5668BE26
P 4450 3250
F 0 "R3" V 4350 3350 50  0000 L CNN
F 1 "2.2K" V 4350 3100 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 3250 50  0001 C CNN
F 3 "" H 4450 3250 50  0000 C CNN
	1    4450 3250
	0    1    1    0   
$EndComp
$Comp
L R_Small R4
U 1 1 5668BE70
P 4450 3450
F 0 "R4" V 4350 3550 50  0000 L CNN
F 1 "2.2K" V 4350 3300 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 3450 50  0001 C CNN
F 3 "" H 4450 3450 50  0000 C CNN
	1    4450 3450
	0    1    1    0   
$EndComp
$Comp
L R_Small R5
U 1 1 5668BEBD
P 4450 3650
F 0 "R5" V 4350 3750 50  0000 L CNN
F 1 "2.2K" V 4350 3500 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 3650 50  0001 C CNN
F 3 "" H 4450 3650 50  0000 C CNN
	1    4450 3650
	0    1    1    0   
$EndComp
$Comp
L R_Small R6
U 1 1 5668BF0D
P 4450 3850
F 0 "R6" V 4350 3950 50  0000 L CNN
F 1 "2.2K" V 4350 3700 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 3850 50  0001 C CNN
F 3 "" H 4450 3850 50  0000 C CNN
	1    4450 3850
	0    1    1    0   
$EndComp
$Comp
L R_Small R7
U 1 1 5668BF60
P 4450 4050
F 0 "R7" V 4350 4150 50  0000 L CNN
F 1 "2.2K" V 4350 3900 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 4050 50  0001 C CNN
F 3 "" H 4450 4050 50  0000 C CNN
	1    4450 4050
	0    1    1    0   
$EndComp
$Comp
L R_Small R8
U 1 1 5668BFB6
P 4450 4250
F 0 "R8" V 4350 4350 50  0000 L CNN
F 1 "2.2K" V 4350 4100 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 4250 50  0001 C CNN
F 3 "" H 4450 4250 50  0000 C CNN
	1    4450 4250
	0    1    1    0   
$EndComp
$Comp
L R_Small R9
U 1 1 5668C00F
P 4450 4450
F 0 "R9" V 4350 4550 50  0000 L CNN
F 1 "2.2K" V 4350 4300 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 4450 50  0001 C CNN
F 3 "" H 4450 4450 50  0000 C CNN
	1    4450 4450
	0    1    1    0   
$EndComp
$Comp
L C_Small C9
U 1 1 5668D42B
P 6300 5600
F 0 "C9" H 6310 5670 50  0000 L CNN
F 1 "4.7nf" H 6310 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 6300 5600 50  0001 C CNN
F 3 "" H 6300 5600 50  0000 C CNN
	1    6300 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C8
U 1 1 5668D48E
P 6100 5600
F 0 "C8" H 6110 5670 50  0000 L CNN
F 1 "4.7nf" H 6110 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 6100 5600 50  0001 C CNN
F 3 "" H 6100 5600 50  0000 C CNN
	1    6100 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C7
U 1 1 5668D4EE
P 5900 5600
F 0 "C7" H 5910 5670 50  0000 L CNN
F 1 "4.7nf" H 5910 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 5900 5600 50  0001 C CNN
F 3 "" H 5900 5600 50  0000 C CNN
	1    5900 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C6
U 1 1 5668D557
P 5700 5600
F 0 "C6" H 5710 5670 50  0000 L CNN
F 1 "4.7nf" H 5710 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 5700 5600 50  0001 C CNN
F 3 "" H 5700 5600 50  0000 C CNN
	1    5700 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C5
U 1 1 5668D5BF
P 5500 5600
F 0 "C5" H 5510 5670 50  0000 L CNN
F 1 "4.7nf" H 5510 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 5500 5600 50  0001 C CNN
F 3 "" H 5500 5600 50  0000 C CNN
	1    5500 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C4
U 1 1 5668D628
P 5300 5600
F 0 "C4" H 5310 5670 50  0000 L CNN
F 1 "4.7nf" H 5310 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 5300 5600 50  0001 C CNN
F 3 "" H 5300 5600 50  0000 C CNN
	1    5300 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C3
U 1 1 5668D694
P 5100 5600
F 0 "C3" H 5110 5670 50  0000 L CNN
F 1 "4.7nf" H 5110 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 5100 5600 50  0001 C CNN
F 3 "" H 5100 5600 50  0000 C CNN
	1    5100 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C2
U 1 1 5668D705
P 4900 5600
F 0 "C2" H 4910 5670 50  0000 L CNN
F 1 "4.7nf" H 4910 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 4900 5600 50  0001 C CNN
F 3 "" H 4900 5600 50  0000 C CNN
	1    4900 5600
	1    0    0    -1  
$EndComp
$Comp
L R_Small R1
U 1 1 5668FA6C
P 4450 2850
F 0 "R1" V 4350 2950 50  0000 L CNN
F 1 "2.2K" V 4350 2700 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 2850 50  0001 C CNN
F 3 "" H 4450 2850 50  0000 C CNN
	1    4450 2850
	0    1    1    0   
$EndComp
$Comp
L C_Small C1
U 1 1 5668FD56
P 4700 5600
F 0 "C1" H 4710 5670 50  0000 L CNN
F 1 "4.7nf" H 4710 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 4700 5600 50  0001 C CNN
F 3 "" H 4700 5600 50  0000 C CNN
	1    4700 5600
	1    0    0    -1  
$EndComp
$Comp
L R_Small R10
U 1 1 5669089D
P 4450 4800
F 0 "R10" V 4350 4900 50  0000 L CNN
F 1 "2.2K" V 4350 4650 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 4450 4800 50  0001 C CNN
F 3 "" H 4450 4800 50  0000 C CNN
	1    4450 4800
	0    1    1    0   
$EndComp
$Comp
L C_Small C10
U 1 1 56690A9F
P 6500 5600
F 0 "C10" H 6510 5670 50  0000 L CNN
F 1 "4.7nf" H 6510 5520 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 6500 5600 50  0001 C CNN
F 3 "" H 6500 5600 50  0000 C CNN
	1    6500 5600
	1    0    0    -1  
$EndComp
$Comp
L C_Small C21
U 1 1 56695028
P 9800 2700
F 0 "C21" H 9810 2770 50  0000 L CNN
F 1 "0.1uf" H 9810 2620 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 9800 2700 50  0001 C CNN
F 3 "" H 9800 2700 50  0000 C CNN
	1    9800 2700
	0    -1   -1   0   
$EndComp
$Comp
L C_Small C22
U 1 1 566950AB
P 9800 2950
F 0 "C22" H 9810 3020 50  0000 L CNN
F 1 "1uf" H 9810 2870 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 9800 2950 50  0001 C CNN
F 3 "" H 9800 2950 50  0000 C CNN
	1    9800 2950
	0    -1   -1   0   
$EndComp
Text Notes 7400 1700 2    60   ~ 0
Biasin pin is connected to biasout so that\nbiasout can be redirected to one of the in[p,n][1-8] electrodes\n.Then the this electrode can be used to either drive the patient\nor measure the signal (depending on the config bits.\n(see datasheet page 48)
NoConn ~ 13250 3950
NoConn ~ 13250 3850
NoConn ~ 13250 3750
NoConn ~ 15600 3850
NoConn ~ 15600 3750
NoConn ~ 15600 3450
NoConn ~ 15600 3350
NoConn ~ 15600 3250
NoConn ~ 6400 2950
NoConn ~ 6400 3150
NoConn ~ 6400 3350
NoConn ~ 6400 3550
NoConn ~ 6400 3750
NoConn ~ 6400 3950
NoConn ~ 6400 4150
NoConn ~ 6400 4350
Text GLabel 9400 2900 1    60   Input ~ 0
DIGITAL_SUPPLY
Text GLabel 8800 1850 2    60   Input ~ 0
ANALOG_SUPPLY
NoConn ~ 8900 4050
Text GLabel 8900 4150 2    60   Input ~ 0
RESET
$Comp
L CONN_01X10 P1
U 1 1 566EEA1C
P 3350 1300
F 0 "P1" H 3350 1850 50  0000 C CNN
F 1 "SENSORS OUT" V 3450 1300 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x10" H 3350 1300 50  0001 C CNN
F 3 "" H 3350 1300 50  0000 C CNN
	1    3350 1300
	-1   0    0    1   
$EndComp
Text GLabel 3550 850  2    60   Input ~ 0
BIAS_DRV
Text GLabel 3550 1050 2    60   Output ~ 0
SENSOR_P8
Text GLabel 3550 950  2    60   Output ~ 0
SRB_1
Text GLabel 3550 1150 2    60   Output ~ 0
SENSOR_P7
Text GLabel 3550 1250 2    60   Output ~ 0
SENSOR_P6
Text GLabel 3550 1350 2    60   Output ~ 0
SENSOR_P5
Text GLabel 3550 1450 2    60   Output ~ 0
SENSOR_P4
Text GLabel 3550 1550 2    60   Output ~ 0
SENSOR_P3
Text GLabel 3550 1650 2    60   Output ~ 0
SENSOR_P2
Text GLabel 3550 1750 2    60   Output ~ 0
SENSOR_P1
NoConn ~ 7000 4800
Text GLabel 10350 2950 2    60   Input ~ 0
GND
Text GLabel 7100 5200 3    60   Input ~ 0
ANALOG_SUPPLY
NoConn ~ 3100 -300
NoConn ~ 15600 3650
NoConn ~ 15600 3550
Text GLabel 15800 4650 2    60   Input ~ 0
GND
NoConn ~ 8900 3950
$Comp
L R_Small R12
U 1 1 56767A11
P 16000 4750
F 0 "R12" V 15900 4800 50  0000 L CNN
F 1 "250" V 15800 4800 50  0000 L CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" H 16000 4750 50  0001 C CNN
F 3 "" H 16000 4750 50  0000 C CNN
	1    16000 4750
	0    -1   -1   0   
$EndComp
$Comp
L CONN_01X02 P3
U 1 1 56767DCC
P 16500 4700
F 0 "P3" H 16500 4850 50  0000 C CNN
F 1 "LED_CONNECTOR" H 16550 4500 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 16500 4700 50  0001 C CNN
F 3 "" H 16500 4700 50  0000 C CNN
	1    16500 4700
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P2
U 1 1 56768B12
P 900 5450
F 0 "P2" H 900 5600 50  0000 C CNN
F 1 "POWER CONNECTOR BATTERY" H 1550 5450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 900 5450 50  0001 C CNN
F 3 "" H 900 5450 50  0000 C CNN
	1    900  5450
	-1   0    0    1   
$EndComp
NoConn ~ 15600 4850
NoConn ~ 15600 4350
Text GLabel 12950 5050 0    60   Input ~ 0
REGULATED_SUPPLY
Text GLabel 13250 4850 0    60   Input ~ 0
GND
$Comp
L C_Small C23
U 1 1 5679294A
P 1450 5850
F 0 "C23" H 1500 5900 50  0000 L CNN
F 1 "0.33uf" H 1500 5750 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 1450 5850 50  0001 C CNN
F 3 "" H 1450 5850 50  0000 C CNN
	1    1450 5850
	1    0    0    -1  
$EndComp
$Comp
L C_Small C24
U 1 1 567929B1
P 2300 5850
F 0 "C24" H 2310 5920 50  0000 L CNN
F 1 "0.1uf" H 2310 5770 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 2300 5850 50  0001 C CNN
F 3 "" H 2300 5850 50  0000 C CNN
	1    2300 5850
	1    0    0    -1  
$EndComp
Text GLabel 2600 5400 2    60   Output ~ 0
REGULATED_SUPPLY
Text GLabel 2600 6000 2    60   Output ~ 0
GND
$Comp
L LM1085_5v_3A U3
U 1 1 567947DD
P 1850 5550
F 0 "U3" H 1850 5850 50  0000 C CNN
F 1 "LM1085_5v_3A" H 1600 5950 50  0000 L CNN
F 2 "eco-fp:LM1085" H 1850 5550 50  0001 C CNN
F 3 "" H 1850 5550 50  0000 C CNN
	1    1850 5550
	1    0    0    -1  
$EndComp
NoConn ~ 13250 3650
Wire Wire Line
	7400 2300 7400 2450
Wire Wire Line
	7400 2300 7900 2300
Wire Wire Line
	7100 5100 7400 5100
Wire Wire Line
	7400 5100 7400 4800
Wire Wire Line
	7100 4800 7100 5200
Connection ~ 7300 5100
Wire Wire Line
	7500 1150 7500 2450
Wire Wire Line
	8000 1150 8000 2450
Wire Wire Line
	8300 2450 8300 2250
Wire Wire Line
	8100 2250 9100 2250
Wire Wire Line
	9100 2250 9100 2950
Wire Wire Line
	8450 1850 8450 1750
Connection ~ 8450 1450
Connection ~ 8700 1850
Connection ~ 9100 2950
Wire Wire Line
	8200 2450 8200 2100
Wire Wire Line
	8200 2100 10150 2100
Wire Wire Line
	8400 2100 8400 2450
Connection ~ 8400 2100
Wire Wire Line
	7200 6050 7200 4800
Wire Wire Line
	8400 6050 8400 4800
Wire Wire Line
	9550 2950 9550 2700
Wire Wire Line
	9550 2700 9700 2700
Wire Wire Line
	9900 2700 10050 2700
Wire Wire Line
	10150 1150 10150 6050
Wire Wire Line
	9900 2950 10350 2950
Wire Wire Line
	9400 2950 9400 2900
Connection ~ 9400 2950
Wire Wire Line
	7600 1150 7600 2450
Wire Wire Line
	7700 4800 7700 6050
Wire Wire Line
	7800 4800 7800 5550
Wire Wire Line
	8000 4800 8000 5550
Wire Wire Line
	8200 4800 8200 5550
Wire Wire Line
	7900 1850 8800 1850
Wire Wire Line
	7700 1350 7900 1350
Wire Wire Line
	10150 4450 8900 4450
Connection ~ 8000 6050
Connection ~ 8300 2250
Wire Wire Line
	8100 2250 8100 2450
Wire Wire Line
	7700 2300 7700 2450
Wire Wire Line
	7700 1750 7900 1750
Connection ~ 7700 2300
Connection ~ 10150 2950
Connection ~ 9550 2950
Wire Wire Line
	8900 3650 10150 3650
Connection ~ 10150 4450
Connection ~ 7100 5100
Wire Wire Line
	7300 5100 7300 4800
Wire Wire Line
	7600 5500 7400 5500
Wire Wire Line
	7400 5750 7400 5800
Wire Wire Line
	7400 5800 7700 5800
Connection ~ 7800 6050
Connection ~ 7600 5800
Wire Wire Line
	7300 5350 7500 5350
Wire Wire Line
	7500 5350 7500 4800
Wire Wire Line
	7300 6050 7300 5350
Connection ~ 7300 6050
Connection ~ 7600 5500
Wire Wire Line
	7400 5500 7400 5550
Wire Wire Line
	7600 4800 7600 5550
Wire Wire Line
	7800 6050 7800 5750
Wire Wire Line
	8200 6050 8200 5750
Connection ~ 8200 6050
Connection ~ 8400 6050
Wire Wire Line
	10150 6050 4700 6050
Connection ~ 7700 6050
Connection ~ 7700 5800
Wire Wire Line
	7600 5800 7600 5750
Wire Wire Line
	4550 3050 6400 3050
Wire Wire Line
	4550 3250 6400 3250
Wire Wire Line
	4550 3450 6400 3450
Wire Wire Line
	4550 3650 6400 3650
Wire Wire Line
	4550 3850 6400 3850
Wire Wire Line
	4550 4050 6400 4050
Wire Wire Line
	4550 4250 6400 4250
Wire Wire Line
	4550 4450 6400 4450
Wire Wire Line
	4200 3050 4350 3050
Wire Wire Line
	4350 3250 4200 3250
Wire Wire Line
	4200 3450 4350 3450
Wire Wire Line
	4350 3650 4200 3650
Wire Wire Line
	4200 3850 4350 3850
Wire Wire Line
	4350 4050 4200 4050
Wire Wire Line
	4200 4250 4350 4250
Wire Wire Line
	4350 4450 4200 4450
Wire Wire Line
	4900 3050 4900 5500
Connection ~ 4900 3050
Wire Wire Line
	5100 5500 5100 3250
Connection ~ 5100 3250
Wire Wire Line
	5300 5500 5300 3450
Connection ~ 5300 3450
Wire Wire Line
	5500 5500 5500 3650
Connection ~ 5500 3650
Wire Wire Line
	5700 5500 5700 3850
Connection ~ 5700 3850
Wire Wire Line
	5900 4050 5900 5500
Connection ~ 5900 4050
Wire Wire Line
	6100 5500 6100 4250
Connection ~ 6100 4250
Wire Wire Line
	6300 4450 6300 5500
Connection ~ 6300 4450
Wire Wire Line
	6300 5700 6300 6050
Connection ~ 7200 6050
Wire Wire Line
	6100 6050 6100 5700
Connection ~ 6300 6050
Wire Wire Line
	5900 6050 5900 5700
Connection ~ 6100 6050
Wire Wire Line
	5700 6050 5700 5700
Connection ~ 5900 6050
Wire Wire Line
	5500 6050 5500 5700
Connection ~ 5700 6050
Wire Wire Line
	5300 6050 5300 5700
Connection ~ 5500 6050
Wire Wire Line
	5100 6050 5100 5700
Connection ~ 5300 6050
Wire Wire Line
	4900 6050 4900 5700
Connection ~ 5100 6050
Wire Wire Line
	4550 2850 6150 2850
Wire Wire Line
	4700 2850 4700 5500
Connection ~ 4700 2850
Wire Wire Line
	4700 6050 4700 5700
Connection ~ 4900 6050
Wire Wire Line
	4350 4800 4200 4800
Wire Wire Line
	4550 4800 6900 4800
Wire Wire Line
	6500 5500 6500 4800
Connection ~ 6500 4800
Wire Wire Line
	6500 5700 6500 6050
Connection ~ 6500 6050
Wire Wire Line
	8900 2950 9700 2950
Connection ~ 10050 2700
Wire Wire Line
	10050 2700 10050 2950
Connection ~ 10050 2950
Connection ~ 10150 3650
Wire Wire Line
	8300 4800 8300 4900
Wire Wire Line
	8300 4900 10150 4900
Connection ~ 7900 2300
Wire Wire Line
	7800 2450 7800 1750
Connection ~ 7800 1750
Wire Wire Line
	7900 1750 7900 1650
Wire Wire Line
	7900 1850 7900 2450
Connection ~ 7600 1150
Wire Wire Line
	7500 1150 10150 1150
Connection ~ 8450 1850
Connection ~ 8000 1150
Wire Wire Line
	8450 1450 8450 1550
Wire Wire Line
	7700 1350 7700 1450
Wire Wire Line
	7700 1650 7700 1750
Connection ~ 7800 1150
Connection ~ 7800 1350
Wire Wire Line
	7900 1350 7900 1450
Connection ~ 8700 1150
Wire Wire Line
	7800 1150 7800 1350
Wire Wire Line
	8450 1450 8700 1450
Connection ~ 8700 1450
Wire Wire Line
	8700 1850 8700 1750
Wire Wire Line
	6150 2850 6150 2250
Wire Wire Line
	7000 1950 7000 2000
Wire Wire Line
	6850 2000 6850 1950
Wire Wire Line
	6850 1950 7200 1950
Wire Wire Line
	7000 2200 7000 2450
Wire Wire Line
	6150 2250 7100 2250
Wire Wire Line
	6850 2250 6850 2200
Connection ~ 7000 2250
Wire Wire Line
	7100 2250 7100 2450
Wire Wire Line
	7200 1950 7200 2450
Connection ~ 7000 1950
Connection ~ 6850 2250
Wire Wire Line
	4200 2850 4350 2850
Wire Wire Line
	8000 6050 8000 5750
Wire Wire Line
	8700 1150 8700 1550
Wire Wire Line
	16100 4750 16300 4750
Wire Wire Line
	12950 4950 13250 4950
Wire Wire Line
	12950 5050 13250 5050
Wire Wire Line
	16300 4650 16300 4550
Wire Wire Line
	16300 4550 15750 4550
Wire Wire Line
	15750 4550 15750 4650
Wire Wire Line
	15600 4650 15800 4650
Connection ~ 15750 4650
Wire Wire Line
	1450 6000 1450 5950
Wire Wire Line
	1300 5500 1300 6000
Connection ~ 1450 6000
Wire Wire Line
	1450 5750 1450 5400
Connection ~ 1450 5400
Wire Wire Line
	2300 6000 2300 5950
Connection ~ 1850 6000
Wire Wire Line
	2300 5750 2300 5400
Wire Wire Line
	2250 5400 2600 5400
Connection ~ 2300 6000
Connection ~ 2300 5400
Wire Wire Line
	1300 6000 2600 6000
Wire Wire Line
	1450 5400 1300 5400
Wire Wire Line
	1850 5900 1850 6000
Connection ~ 10150 2100
Connection ~ 10150 4900
Wire Wire Line
	15600 4750 15900 4750
NoConn ~ 15600 5050
NoConn ~ 15600 4950
NoConn ~ 15600 4550
NoConn ~ 15600 4450
NoConn ~ 13250 4550
NoConn ~ 13250 4450
NoConn ~ 13250 4350
NoConn ~ 13250 4250
NoConn ~ 13250 4150
NoConn ~ 13250 3550
NoConn ~ 13250 3450
NoConn ~ 13250 3250
NoConn ~ 13250 3150
NoConn ~ 15600 3150
Wire Wire Line
	1100 5500 1300 5500
$Comp
L D_Small D1
U 1 1 567B1270
P 1200 5400
F 0 "D1" H 1150 5480 50  0000 L CNN
F 1 "D_Small" H 1050 5250 50  0000 L CNN
F 2 "eco-fp:1n1008" V 1200 5400 50  0001 C CNN
F 3 "" V 1200 5400 50  0000 C CNN
	1    1200 5400
	-1   0    0    1   
$EndComp
$EndSCHEMATC
