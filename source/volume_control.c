#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_OUTPUT_SIZE 128

int get_default_sink() {
    FILE *fp;
    char output[MAX_OUTPUT_SIZE];
    char default_sink_name[MAX_OUTPUT_SIZE];
    int default_sink_id = -1;

    fp = popen("pactl info | grep 'Default Sink:' | awk '{print $3}'", "r");
    if (fp == NULL) {
        printf("Failed to run command\n");
        exit(1);
    }
    if (fgets(default_sink_name, sizeof(default_sink_name) - 1, fp) == NULL) {
        pclose(fp);
        return -1;
    }
    strtok(default_sink_name, "\n"); 
    pclose(fp);

    fp = popen("pactl list short sinks", "r");
    if (fp == NULL) {
        printf("Failed to run command\n");
        exit(1);
    }
    while (fgets(output, sizeof(output) - 1, fp) != NULL) {
        int id;
        char name[MAX_OUTPUT_SIZE];
        if (sscanf(output, "%d\t%s", &id, name) == 2 && strcmp(name, default_sink_name) == 0) {
            default_sink_id = id;
            break;
        }
    }
    pclose(fp);

    return default_sink_id;
}



int get_current_volume(int sink) {
    FILE *fp;
    char command[MAX_OUTPUT_SIZE], output[MAX_OUTPUT_SIZE];
    int volume = -1;

    snprintf(command, sizeof(command), "pactl list sinks | grep -A15 'Sink #%d' | grep 'Volume:' | awk '{print $5}' | sed 's/%%//'", sink);
    fp = popen(command, "r");
    if (fp == NULL) {
        printf("Failed to run command\n");
        exit(1);
    }

    if (fgets(output, sizeof(output) - 1, fp) != NULL) {
        sscanf(output, "%d", &volume);
    }
    pclose(fp);

    return volume;
}

void adjust_volume(int sink, int adjustment) {
    int current_volume = get_current_volume(sink);
    if (current_volume == -1) return;

    int target_volume = current_volume + adjustment;
    if (target_volume < 0) target_volume = 0;
    if (target_volume > 100) target_volume = 100;

    char command[MAX_OUTPUT_SIZE];
    snprintf(command, sizeof(command), "pactl set-sink-volume %d %d%%", sink, target_volume);
    system(command);
}

void toggle_mute(int sink) {
    char command[MAX_OUTPUT_SIZE];
    snprintf(command, sizeof(command), "pactl set-sink-mute %d toggle", sink);
    system(command);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s [lower|raise|mute]\n", argv[0]);
        return 1;
    }

    int default_sink = get_default_sink();

    if (default_sink == -1) {
        printf("No default sink found.\n");
        return 1;
    }

    if (strcmp(argv[1], "lower") == 0) {
        adjust_volume(default_sink, -5);
    } else if (strcmp(argv[1], "raise") == 0) {
        adjust_volume(default_sink, 5);
    } else if (strcmp(argv[1], "mute") == 0) {
        toggle_mute(default_sink);
    } else {
        printf("Unknown action.\n");
        return 1;
    }

    return 0;
}
