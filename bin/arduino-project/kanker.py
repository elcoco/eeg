#!/usr/bin/python
import serial  
import time  
  
locations=['/dev/ttyUSB0','/dev/ttyUSB1','/dev/ttyACM0', '/dev/ttyACM1', '/dev/ttyUSB2','/dev/ttyUSB3',  
'/dev/ttyS0','/dev/ttyS1','/dev/ttyS2','/dev/ttyS3']    
  
for device in locations:  
    try:  
        print "Trying...",device  
        arduino = serial.Serial(device, 9600)  
        break  
    except:  
        print "Failed to connect on",device     
  
try:  
	print "trying to read the arduino"
	print arduino.readline()  
except:  
    print "Failed to send!" 
