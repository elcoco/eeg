#!/usr/bin/python3.2
import serial,time,os,datetime

locations=['/dev/ttyUSB0','/dev/ttyUSB1','/dev/ttyUSB2','/dev/ttyUSB3','/dev/ttyACM0','/dev/ttyACM1',
'/dev/ttyS0','/dev/ttyS1','/dev/ttyS2','/dev/ttyS3']

for device in locations:
    try:
        print("Trying...",device)
        arduino = serial.Serial(device, 9600)
        break
    except:
        print("Failed to connect on",device)

#f=open("log","w")
#f.close()

n=0
# get stream
while 1:
	try:
		SerialOutput = (arduino.readline())
		SerialOutput=SerialOutput.decode("utf-8")
		SerialOutput=SerialOutput.rstrip()
		print(SerialOutput)
		now = datetime.datetime.now()

		n=n+1
		if (n != 1):		# throw away the first result (garbage)
			FILE = open("log", "a")
			FILE.write(str(now.day) + "-" + str(now.month) + "-" + str(now.year) + "," + str(now.hour) + ":" + str(now.minute) + ":" + str(now.second) + "  " + SerialOutput + "\n")
			#FILE.write(SerialOutput + "  " + str(now.day) + str(now.month) + str(now.year) + str(now.hour) + str(now.minute) + str(now.second) + "\n")
			FILE.close()
	except KeyboardInterrupt:
		break
