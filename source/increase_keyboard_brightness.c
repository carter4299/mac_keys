#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *file;
    int brightness;

    file = fopen("/sys/class/leds/smc::kbd_backlight/brightness", "r");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    fscanf(file, "%d", &brightness);
    fclose(file);

    brightness += 10;
    file = fopen("/sys/class/leds/smc::kbd_backlight/brightness", "w");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    fprintf(file, "%d", brightness);
    fclose(file);

    return 0;
}
