#include <avr/io.h>

int input_check(void);
unsigned char SW5(unsigned char input);
unsigned char SW4(unsigned char input);
unsigned char SW3(unsigned char input);
unsigned char SW2(unsigned char input);
unsigned char SW1(unsigned char input);

int main(void)
{
    unsigned char state = 0x01;                 //Set initial state to 1
    int input;

    DDRB = 0xff;                                //Set PORTB as output
    DDRD = 0x00;                                //Set PORTD as input
    PORTD = 0xff;
    PORTB = state;                              //Set LEDs to initial state
    for(;;) {
        while ((input = input_check()) == 0){}  //Wait for button press
        if (input == 5) {                       //According to the input
            state = SW5(state);                 //do the corresponding job
            PORTB = state;
        } else if (input == 4) {
            state = SW4(state);
            PORTB = state;
        } else if (input == 3) {
            state = SW3(state);
            PORTB = state;
        } else if (input == 2) {
            state = SW2(state);
            PORTB = state;
        } else {
            state = SW1(state);
            PORTB = state;
        }
    }
    return -1;
}

int input_check(void)
{
    int end = 0;
    int ret = 0;
    unsigned char input;

    input = PIND;                               //Read the input from PORTD
    input = input & 0x1f;                       //Keep the 5 first bits
    if (input == 0)                             //Check every posible button
        return 0;
    for (;;) {
    /*
    * The ret value checking in the clauses
    * guarantees that only the pressed button of
    * maximum value will take effect
    */
        if (input >= 16)
            ret = 5;
        else if ((input >= 8) && (ret <= 4))
            ret = 4;
        else if ((input >= 4) && (ret <= 3))
            ret = 3;
        else if ((input >= 2) && (ret <= 2))
            ret = 2;
        else if ((input >= 1) && (ret <= 1))
            ret = 1;
        else if (input == 0)                        //The button was released
            end = 1;
        if (end == 1)
            return ret;
        input = PIND;
        input = input & 0x1f;
    }
    return -1;
}

unsigned char SW5(unsigned char input)          //SW5 sets the 1st LED
{
    return 0x01;
}

unsigned char SW4(unsigned char input)          //SW4 sets the LED two places right
{
    if (input > 2)
        return input / 4;
    else
        return input * 64;
}

unsigned char SW3(unsigned char input)          //SW3 sets the LED two places left
{
    return (input * 4) % 255;
}

unsigned char SW2(unsigned char input)          //SW2 sets the LED one place right
{
    if (input > 1)
        return input / 2;
    else
        return 128;
}

unsigned char SW1(unsigned char input)          //SW2 sets the LED one place left
{
    return (input * 2) % 255;
}
