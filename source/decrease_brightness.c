#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *file;
    int brightness;

    FILE *fp = fopen("/sys/class/backlight/acpi_video0/brightness", "r");
    if (!fp) {
        perror("Failed to open brightness file for reading");
        return 1;
    }

    fscanf(fp, "%d", &brightness);
    fclose(fp);

    brightness -= 10;

    fp = fopen("/sys/class/backlight/acpi_video0/brightness", "w");
    if (!fp) {
        perror("Failed to open brightness file for writing");
        return 1;
    }

    fprintf(fp, "%d", brightness);
    fclose(fp);

    return 0;
}
