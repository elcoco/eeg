#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <bcm2835.h>
#include <sys/time.h>

#include <stdlib.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

int main();
int boot();
int setup();
int startSPI();
int closeSPI();
int setupNoiseCheck();
int setupTestSignal();
int handleCommands(int);
uint8_t transfer(uint8_t);
uint8_t rreg(uint8_t);
uint8_t wreg(uint8_t, uint8_t);
void startSocket(int*, int*);
int msgInbound(char[256]);
int msgOutbound(char[256]);
int sendData(int);
char * get_data(int, char *);
//unsigned int capture_data();

/*
RPI2 SPI pin layout

CE0     = PIN 24
CE1     = PIN 26
MOSI    = PIN 19
MISO    = PIN 21
CLK     = PIN 23
*/

struct captureData{
    int LOFF_STATP;
    int LOFF_STATN;
    int GPIO;
    int CH1_DATA;
    int CH2_DATA;
    int CH3_DATA;
    int CH4_DATA;
    int CH5_DATA;
    int CH6_DATA;
    int CH7_DATA;
    int CH8_DATA;
};


struct {
    int powerdown;
    int reset;
    int dataready;
    int button;
} PIN;


struct {
    uint8_t WAKEUP;
    uint8_t STANDBY;
    uint8_t RESET;
    uint8_t START;
    uint8_t STOP;
    uint8_t RDATAC;
    uint8_t SDATAC;
    uint8_t RDATA;
    uint8_t RREG;
    uint8_t WREG;
} OP;


struct {
    uint8_t ID;
    uint8_t CONFIG1;
    uint8_t CONFIG2;
    uint8_t CONFIG3;
    uint8_t LOFF;
    uint8_t CH1SET;
    uint8_t CH2SET;
    uint8_t CH3SET;
    uint8_t CH4SET;
    uint8_t CH5SET;
    uint8_t CH6SET;
    uint8_t CH7SET;
    uint8_t CH8SET;
    uint8_t BIAS_SENSP;
    uint8_t BIAS_SENSN;
    uint8_t LOFF_SENSP;
    uint8_t LOFF_SENSN;
    uint8_t LOFF_FLIP;
    uint8_t LOFF_STATP;
    uint8_t LOFF_STATN;
    uint8_t GPIO;
    uint8_t MISC1;
    uint8_t MISC2;
    uint8_t CONFIG4;
} REG;


int setup() {
    PIN.powerdown = 14; // PIN 8  on RPI2
    PIN.reset     = 15; // PIN 10 on RPI2
    PIN.dataready = 16; // PIN 36 on RPI2
    PIN.button    = 4;  // PIN 7  on RPI2

    REG.ID          = 0x00; // default = 0x00
    REG.CONFIG1     = 0x01; // default = 0x96
    REG.CONFIG2     = 0x02; // default = 0xC0
    REG.CONFIG3     = 0x03; // default = 0x60
    REG.LOFF        = 0x04; // default = 0x61
    REG.CH1SET      = 0x05; // default = 0x61
    REG.CH2SET      = 0x06; // default = 0x61
    REG.CH3SET      = 0x07; // default = 0x61
    REG.CH4SET      = 0x08; // default = 0x61
    REG.CH5SET      = 0x09; // default = 0x61
    REG.CH6SET      = 0x0A; // default = 0x61
    REG.CH7SET      = 0x0B; // default = 0x61
    REG.CH8SET      = 0x0C; // default = 0x61
    REG.BIAS_SENSP  = 0x0D; // default = 0x00
    REG.BIAS_SENSN  = 0x0E; // default = 0x00
    REG.LOFF_SENSP  = 0x0F; // default = 0x00
    REG.LOFF_SENSN  = 0x10; // default = 0x00
    REG.LOFF_FLIP   = 0x11; // default = 0x00
    REG.LOFF_STATP  = 0x12; // default = 0x00
    REG.LOFF_STATN  = 0x13; // default = 0x00
    REG.GPIO        = 0x14; // default = 0x0F
    REG.MISC1       = 0x15; // default = 0x00
    REG.MISC2       = 0x16; // default = 0x00
    REG.CONFIG4     = 0x17; // default = 0x00

    OP.WAKEUP  = 0x02;
    OP.STANDBY = 0x04;
    OP.RESET   = 0x06;
    OP.START   = 0x08;
    OP.STOP    = 0x0A;
    OP.RDATAC  = 0x10;
    OP.SDATAC  = 0x11;
    OP.RDATA   = 0x12;
    OP.RREG    = 0x20;
    OP.WREG    = 0x40;
};


int main() {
    int socketfd, socketfd_old;
    int inloop;

    setup();
    startSPI();
    boot();
    while (inloop == 0) {
        startSocket(&socketfd, &socketfd_old);
        inloop = handleCommands(socketfd);
        close(socketfd);
        close(socketfd_old);
    }
    fflush(stdout);
    closeSPI();

    return 0;
};


uint8_t rreg(uint8_t reg) {
    transfer(OP.RREG + reg);
    transfer(0x00);
    uint8_t rd = transfer(0x00);
    printf("READING - Register: %02X = Value: %02X\n", reg, rd);
    return rd;
};


uint8_t wreg(uint8_t reg, uint8_t value) {
    // One register is one byte
    // Change the default value and write the whole byte (all bits in the register) at once.
    printf("WRITING - Register: %02X, Value: %02X\n", reg, value);
    transfer(reg + OP.WREG);
    transfer(0x00);
    transfer(value);
};


uint8_t transfer(uint8_t sd) {
    //printf("Begin sending: %02X\n",sd);
    uint8_t rd = bcm2835_spi_transfer(sd);
    return rd;
};


int setupNoiseCheck() {
    // Stop DATAC mode
    transfer(OP.SDATAC);

    // Power up sequence diagram from page 58 tells me to write some registers
    // They seem to be the default values but I'll do it anyways because I want to be good obviously.
    wreg(REG.CONFIG1, 0x96);
    wreg(REG.CONFIG2, 0xC0);

    // Short all the inputs
    wreg(REG.CH1SET,  0x01);
    wreg(REG.CH2SET,  0x01);
    wreg(REG.CH3SET,  0x01);
    wreg(REG.CH4SET,  0x01);
    wreg(REG.CH5SET,  0x01);
    wreg(REG.CH6SET,  0x01);
    wreg(REG.CH7SET,  0x01);
    wreg(REG.CH8SET,  0x01);

    // Set Start = 1, DRDY should now toggle when data is available
    transfer(OP.START);

    // Put chip in RDATAC mode
    transfer(OP.RDATAC);
};


int setupTestSignal() {
    // Stop RDATAC mode
    transfer(OP.SDATAC);

    // Write defaults
    //wreg(REG.CONFIG1, 0x96);
    //wreg(REG.CONFIG2, 0xC0);

    // Do test signals
    wreg(REG.CONFIG2, 0xD0); // Set signals to be generated internally
    wreg(REG.CH1SET,  0x05);
    wreg(REG.CH2SET,  0x05);
    wreg(REG.CH3SET,  0x05);
    wreg(REG.CH4SET,  0x05);
    wreg(REG.CH5SET,  0x05);
    wreg(REG.CH6SET,  0x05);
    wreg(REG.CH7SET,  0x05);
    wreg(REG.CH8SET,  0x05);

    // Set Start = 1, DRDY should now toggle when data is available
    transfer(OP.START);

    printf(">>%d<<\n",bcm2835_gpio_lev(PIN.dataready));
    // Put chip in RDATAC mode
    transfer(OP.RDATAC);
};


bool dataReady() {
    // return status of the dataready pin
    return (!(bcm2835_gpio_lev(PIN.dataready)));
};


float map(float x, float in_min, float in_max, float out_min, float out_max) {
    return (x - in_min) * (out_max - out_min ) / (in_max - in_min) + out_min;
}


bool isPositive(int data) {
    // range positief = hoog, laag - 8388607, 1
    // range negatief = hoog, laag - 8388608, 16777215,
    if (data <= 8388607)
        return 1;
    return 0;
}


bool writeToFile(int channel, int data) {
    FILE *f = fopen("/home/eco/usb/data.txt", "a");;
    if (f == NULL) {
        printf("Failed to open file");
        return 0;
    };
    fprintf(f, "%d %d\n",channel, data);
    fclose(f);
};


int boot() {
    printf("\nBooting up ADS1299\n");
    // Boot up the ADS299

    bcm2835_gpio_fsel(PIN.powerdown, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(PIN.reset, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(PIN.button, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(PIN.dataready, BCM2835_GPIO_FSEL_INPT);


    printf("All inputs LOW\n");
    bcm2835_gpio_write(PIN.powerdown, LOW);
    bcm2835_gpio_write(PIN.reset, LOW);
    bcm2835_gpio_write(PIN.button, LOW);

    delayMicroseconds(50);

    printf("Powerdown/ Reset HIGH\n");
    bcm2835_gpio_write(PIN.powerdown, HIGH);
    bcm2835_gpio_write(PIN.reset, HIGH);

    delayMicroseconds(50);

    printf("Doing Reset\n");
    bcm2835_gpio_write(PIN.reset, LOW);

    delayMicroseconds(50);

    bcm2835_gpio_write(PIN.reset, HIGH);

    delayMicroseconds(50);

    // Device wakes up in RDATAC (Read data continuous), to send commands we have
    // to send SDATAC (Stop read data continuous).
    printf("Setting SDATAC\n");
    transfer(OP.SDATAC);

    delayMicroseconds(50);

    printf("Setting internal reference\n");
    wreg(REG.CONFIG3, 0xE0);

    delayMicroseconds(150);

    printf("Routing all negative inputs to SRB1\n");
    wreg(REG.MISC1, 0x20);
    
    // Set all ADS1299 GPIO outputs to zero since it can create noise
    printf("Setting all ADS1299 GPIO outputs to zero\n");
    wreg(REG.GPIO, 0x00);
    
    printf("Turn off lead off detection for all positive/negative channels\n");
    wreg(REG.LOFF_SENSP, 0x00);
    wreg(REG.LOFF_SENSN, 0x00);

    printf("End booting up ADS1299\n\n");
};


int startSPI() {
    // Start SPI
    if (!bcm2835_init()) {
        printf("No can't do open spi, just no");
        return 1;
    };

    bcm2835_spi_begin();                                        // Open SPI
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);    // Fill with trailing zero's
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0,0);       // CS LOW when transfer
    //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_16);  // 15.625 mhz
    //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_65536);  // 3.8 khz
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_256);  // 1 mhz
    //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_2048);  // 122.x khz
    //bcm2835_spi_setDataMode(BCM2835_SPI_MODE0); // Clock idle low, data is clocked in on rising edge, ouput data (change) on falling edge
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE1); // Clock idle low, data is clocked in on rising edge, ouput data (change) on falling edge
    //bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                    // Use first CS (RPI2 has two CS)
    bcm2835_spi_chipSelect(BCM2835_SPI_CS_NONE);                    // Use first CS (RPI2 has two CS)
    printf("SPI is turned on!!!\n");
}


int closeSPI() {
    bcm2835_spi_end();
    bcm2835_close();
    printf("SPI is turned off!!!\n");
};


struct captureData capture_data() {
    // Capture data from ADS1299
    // 3 * 3 bytes (LOFF_STATP, LOFF_STATN, GPIO) + (3 bytes * 8 channels) (page 27)
    uint8_t data;
    int LOFF_STATP;
    int LOFF_STATN;
    int GPIO;
    int ch_data;
    struct captureData cd;
    int in_loop = 0;

    while (in_loop == 0) {
        if (dataReady()) {
            in_loop = 1;
            delayMicroseconds(5);
            cd.LOFF_STATP = transfer(0x00);
            cd.LOFF_STATN = transfer(0x00);
            cd.GPIO = transfer(0x00);
            printf("%02X %02X %02X - ",cd.LOFF_STATP, cd.LOFF_STATN, cd.GPIO);

            for (int i=1 ; i<=8 ; i++ ) {

                ch_data = 0;

                printf(" [");
                for (int x=0 ; x<3 ; x++ ) {
                    data = transfer(0x00);
                    printf("%02X",data);
                    ch_data = (ch_data<<8) | data;
                };
                printf("] ");

                if (!isPositive(ch_data)) {
                    // is negative value
                    int mapped_data = map(ch_data, 16777215, 8388608, 1, 8388607);
                    ch_data = mapped_data * -1;
                }

                if (i == 1)
                    cd.CH1_DATA = ch_data;
                else if (i == 2)
                    cd.CH2_DATA = ch_data;
                else if (i == 3)
                    cd.CH3_DATA = ch_data;
                else if (i == 4)
                    cd.CH4_DATA = ch_data;
                else if (i == 5)
                    cd.CH5_DATA = ch_data;
                else if (i == 6)
                    cd.CH6_DATA = ch_data;
                else if (i == 7)
                    cd.CH7_DATA = ch_data;
                else if (i == 8)
                    cd.CH8_DATA = ch_data;
            };
            printf("\n");
        };
    };
    return cd;
};


int sendData(int socketfd) {
    // Send RDATAC data to client
    char out[500];
    char out2[500];
    int status;
    char command[256];

    // NOTE: Channel 8 data is incorrect and the rest is zero
    while (1) {
        struct captureData cd = capture_data();
        sprintf(out, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", cd.LOFF_STATP, \
                                                         cd.LOFF_STATN, \
                                                         cd.GPIO, \
                                                         cd.CH1_DATA, \
                                                         cd.CH2_DATA, \
                                                         cd.CH3_DATA, \
                                                         cd.CH4_DATA, \
                                                         cd.CH5_DATA, \
                                                         cd.CH6_DATA, \
                                                         cd.CH7_DATA, \
                                                         cd.CH8_DATA);

        sprintf(out2, "%03d%s", strlen(out), out);
        if (write(socketfd, out2, strlen(out2)) == -1) {
            return 1;
        };
    };
    //status = write(socketfd, "004DONE", 7);
};


int msgInbound(char msg[256]) {;
    printf("\x1b[32m<<<\x1b[0m %s\n", msg);
}


int msgOutbound(char msg[256]) {;
    printf("\x1b[34m<<<\x1b[0m %s\n", msg);
}



char * get_data(int socketfd, char *msg) {
    int length;
    // Get data from socket
    if ((recv(socketfd, msg, 3, 0)) > 0) {
        // Convert string to int
        length = atoi(msg);
        // Reset buffers
        bzero((char *) msg, sizeof(msg));
        // Get data
        recv(socketfd, msg, length, 0);
        msgInbound(msg);
        return msg;
    };

}

int handleCommands(int socketfd) {
    int read_size;
    char data[256];
    int running = 0;

    while (running == 0) {
        get_data(socketfd, data);

        // Use memcmp() instead of strcmp() if string is not \0 terminated
        if (memcmp(data, "QUIT", 1) == 0 ) {
            msgInbound(data);
            running  = 1;
        }

        else if (memcmp(data, "SHUTDOWN", 1) == 0 ) {
            msgInbound(data);
            return 1;
        }

        else if (memcmp(data, "NOISECHECK", 1) == 0 ) {
            msgInbound(data);
            setupNoiseCheck();
            running = sendData(socketfd);
            transfer(OP.STOP);

        }

        else if (memcmp(data, "TESTSIGNAL", 1) == 0 ) {
            msgInbound(data);
            setupTestSignal();
            running = sendData(socketfd);
            transfer(OP.STOP);
        }

        else {
            msgInbound(data);
        };

        printf("Connection is broken\n");

        strcpy(data, "");


    };
    return 0;
};


void startSocket(int *socketfd, int *socketfd_old) {
    *socketfd,*socketfd_old = 0;
    socklen_t clilen;
    struct sockaddr_in server_address, client_address;

    int port = 8888;

    // Create a new internet TCP socket
    *socketfd_old = socket(AF_INET, SOCK_STREAM, 0);
    if (*socketfd_old < 0) 
       printf("ERROR opening socket\n");

    // Set all values in buffer to zero
    bzero((char *) &server_address, sizeof(server_address));

    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(port);

    // Tell the kernel to reuse the socket
    int yes = 1;
    if (setsockopt(*socketfd_old, SOL_SOCKET, SO_REUSEADDR, &yes,sizeof(int)) == -1) {
        printf("setsockopt");
        exit(1);
    };
    // Bind the socket to an address
    if (bind(*socketfd_old, (struct sockaddr *) &server_address,
             sizeof(server_address)) < 0) 
             printf("ERROR on binding\n");

    listen(*socketfd_old,5);

    printf("Waiting for incoming connections...\n");
    clilen = sizeof(client_address);

    // Block process until a connection to a client is made
    *socketfd = accept(*socketfd_old, 
                (struct sockaddr *) &client_address, 
                &clilen);

    if (*socketfd < 0) 
         printf("ERROR on accept\n");
    else
        printf("Connected to client\n");
}



/*
        self.spi_speed = 5000
        #self.spi_speed = 2000000
        #self.spi_speed = 2048000
        self.spi_bus = 0
        self.spi_device = 0

        # SPI setup
        self.spi = SPI(self.spi_bus, self.spi_device, self.spi_speed)

        #GPIO init
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(self.pin_pwdn, GPIO.OUT)
        GPIO.setup(self.pin_cs, GPIO.OUT)
        GPIO.setup(self.pin_reset, GPIO.OUT)


        Notation 0x00 == 00h
        if 8-bit add leading zeroes till 2x4 chars

        CONVERSION TABLE
        Binary      Octal   Decimal     Hex
        0000B       00Q     00          00H
        0001B       01Q     01          01H
        0010B       02Q     02          02H
        0011B       03Q     03          03H
        0100B       04Q     04          04H
        0101B       05Q     05          05H
        0110B       06Q     06          06H
        0111B       07Q     07          07H
        1000B       10Q     08          08H
        1001B       11Q     09          09H
        1010B       12Q     10          0AH
        1011B       13Q     11          0BH
        1100B       14Q     12          0CH
        1101B       15Q     13          0DH
        1110B       16Q     14          0EH
        1111B       17Q     15          0FH
        1 0000B     20Q     16          10H


        OPCODES
        wakeup  - 0000 0010 (02h)
        standby - 0000 0100 (04h)
        reset   - 0000 0110 (06h)
        start   - 0000 1000 (08h)
        stop    - 0000 1010 (0Ah)
        rdatac  - 0001 0000 (10h)
        sdatac  - 0001 0001 (11h)
        rdata   - 0001 0010 (12h)
        rreg    - 001r rrrr (02h)
                  000n nnnn (00h)


        # wreg is a two byte opcode followed by the register data input in MSB-first format
        wreg    - 010r rrrr (04h)
                  000n nnnn (00h)

        r rrrr = adress
        n nnnn = number of registers to be read or written starting from 00h (so that means MINUS ONE!!)

        EXAMPLES:
        Write to 02h (config3)
        WREG          = 04h - 0100
        CONFIG3       = 02h - 0010
        START_CONFIG  = 00h - 0000
        bit 3         = 02h - 0010 
        Bits to Send: 0100 0010 0000 0010 -> 66, 2

        Read register 00h (config0)
        RREG          = 02h - 0010
        CONFIG0       = 00h - 0000
        PREFIX        = 00h - 0000
        BITS 0        = 00h - 0000
        Bits to Send: 0010 0000 0000 0000 -> 32, 0


        Example write in C: (from: https://github.com/OpenBCI/OpenBCI-V2hardware-DEPRECATED/blob/master/Arduino/Libraries/ADS1299/ADS1299.cpp#L194)

        void ADS1299::WREG(byte _address, byte _value) {    //  Write ONE register at _address
            byte opcode1 = _address + 0x40;     //  WREG expects 010rrrrr where rrrrr = _address
            digitalWrite(CS, LOW);              //  open SPI
            transfer(opcode1);                  //  Send WREG command & address
            transfer(0x00);                     //  Send number of registers to read -1
            transfer(_value);                   //  Write the value to the register
            digitalWrite(CS, HIGH);             //  close SPI
            regData[_address] = _value;         //  update the mirror array
            if(verbose){                        //  verbose output
                Serial.print(F("Register "));
                printHex(_address);
                Serial.println(F(" modified."));
            }
        }

*/
