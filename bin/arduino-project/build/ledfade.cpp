#include <WProgram.h>

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

float mapfloat(float x, float in_min, float in_max, float out_min, float out_max);
void setup();
void loop();
#line 1 "build/ledfade.pde"
// Arduino sketch template file

int LED0Pin = 9;
int NTC0Pin = 0;
int n;
float NTCValue;
float AverageNTCValue;
float Temperature;


void setup()
	{
	pinMode(NTC0Pin, INPUT);
	Serial.begin(9600);
	}

void loop()
	{
	AverageNTCValue = 0;

	for ( n=0; n<1; n++ )
		{
		NTCValue = analogRead(NTC0Pin);
		delay(1000);
		}

	Temperature = mapfloat(NTCValue, 272, 337, 18, 60);
		
/*

	NTCValue = analogRead(NTC0Pin);
	Temperature = mapfloat(NTCValue, 21, 357, 18, 100);
	delay(1000);
*/

	Serial.print(Temperature);
	Serial.println(); //newline character to signal end of data for python
	}



float mapfloat(float x, float in_min, float in_max, float out_min, float out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}



