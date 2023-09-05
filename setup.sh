#!/bin/sh
mkdir -p ~/.mac_keys
mkdir -p ~/Pictures/Screenshots
# Dependecies and sys files
acpi_output=$(ls /sys/class/backlight/)

if [ -z "$acpi_output" ]; then
    echo "Error: No ACPI backlight interface found. The script will not work on your system."
    exit 1
fi
echo "Detected backlight interface: $acpi_output. Inserting into package... "
sed -i "s|char file_location[256] = \"/sys/class/backlight/acpi_video0/brightness\";|char file_location[256] = \"/sys/class/backlight/$acpi_output/brightness\";|" ./source/increase_brightness.c
sed -i "s|char file_location[256] = \"/sys/class/backlight/acpi_video0/brightness\";|char file_location[256] = \"/sys/class/backlight/$acpi_output/brightness\";|" ./source/decrease_brightness.c

# Check for pulseaudio
if which pulseaudio >/dev/null; then
    echo "pulseaudio is installed. Installing bridge pulseaudio-alsa...  "
    sudo pacman -S pulseaudio-alsa
else
    echo "pulseaudio is not installed. Installing... "
    sudo pacman -S pulseaudio pulseaudio-alsa
fi

if which amixer >/dev/null; then 
    echo "alsa-utils is installed... "
else
    echo "alsa-utils is not installed. Installing... "
    sudo pacman -S alsa-utils
fi

if which rofi >/dev/null; then
    echo "rofi is installed."
else
    echo "rofi is not installed. Installing... "
    sudo pacman -S rofi
fi


# Step 1: Compile
if command -v gcc > /dev/null 2>&1; then
    echo "Compiling the brightness adjustment programs..."
    if gcc ./source/increase_brightness.c -o ~/.mac_keys/increase_brightness; then
        echo "increase_brightness compiled successfully... "
    else
        echo "Error compiling increase_brightness. Exiting... "
        exit 1
    fi
    echo "Compiling the brightness adjustment programs..."
    if gcc ./source/decrease_brightness.c -o ~/.mac_keys/decrease_brightness; then
        echo "decrease_brightness compiled successfully... "
    else
        echo "Error compiling decrease_brightness. Exiting... "
        exit 1
    fi
    echo "Compiling the brightness adjustment programs..."
    if gcc ./source/increase_keyboard_brightness.c -o ~/.mac_keys/increase_keyboard_brightness; then
        echo "increase_keyboard_brightness compiled successfully... "
    else
        echo "Error compiling increase_keyboard_brightness. Exiting... "
        exit 1
    fi
    echo "Compiling the brightness adjustment programs..."
    if gcc ./source/decrease_keyboard_brightness.c -o ~/.mac_keys/decrease_keyboard_brightness; then
        echo "decrease_keyboard_brightness compiled successfully... "
    else
        echo "Error compiling decrease_keyboard_brightness. Exiting... "
        exit 1
    fi
    echo "Compiling the brightness adjustment programs..."
    if gcc ./source/volume_control.c -o ~/.mac_keys/volume_control; then
        echo "volume_control compiled successfully... "
    else
        echo "Error compiling volume_control. Exiting... "
        exit 1
    fi
else
    echo "GCC not found. Using pre-compiled binaries..."
    cp ./compiled/increase_brightness_binary ~/.mac_keys/increase_brightness
    cp ./compiled/decrease_brightness_binary ~/.mac_keys/decrease_brightness
    cp ./compiled/increase_keyboard_brightness_binary ~/.mac_keys/increase_keyboard_brightness
    cp ./compiled/decrease_keyboard_brightness_binary ~/.mac_keys/decrease_keyboard_brightness
    cp ./compiled/volume_control_binary.c -o ~/.mac_keys/volume_control
fi


# Step 2: Set permissions for binaries
echo "Setting permissions for binaries... "
sudo chown root:root ~/.mac_keys/increase_brightness ~/.mac_keys/decrease_brightness ~/.mac_keys/increase_keyboard_brightness ~/.mac_keys/decrease_keyboard_brightness ~/.mac_keys/volume_control

echo "Adding NOPASSWD entries to sudoers for the brightness adjustment programs... "

temp_sudoers=$(mktemp ~/temp_sudoers.XXXXXX)
sudo chown $USER: $temp_sudoers
sudo cp /etc/sudoers $temp_sudoers
for cmd in "$HOME/.mac_keys/increase_brightness" "$HOME/.mac_keys/decrease_brightness" "$HOME/.mac_keys/increase_keyboard_brightness" "$HOME/.mac_keys/decrease_keyboard_brightness"; do
    if ! grep -q "$USER ALL=NOPASSWD: $cmd" $temp_sudoers; then
        echo "$USER ALL=NOPASSWD: $cmd" | tee -a $temp_sudoers
    fi
done

if sudo visudo -cf $temp_sudoers; then
    sudo cp $temp_sudoers /etc/sudoers
else
    echo "Error: Failed to update sudoers file. No changes were made."
    exit 1
fi
sudo rm -f $temp_sudoers


# Step 3: Update i3 config
cp ~/.config/i3/config ~/.config/i3/config.backup
echo "Updating i3 config. Backup stored at ~/.config/i3/config.backup if you want to convert back."
if [ -f ~/.config/i3/config ]; then
    for binding in "bindsym XF86LaunchA exec rofi -show window" "bindsym XF86LaunchB exec rofi -show drun" "bindsym XF86MonBrightnessDown exec sudo ~/.mac_keys/decrease_brightness" "bindsym XF86MonBrightnessUp exec sudo ~/.mac_keys/increase_brightness" "bindsym XF86KbdBrightnessDown exec sudo ~/.mac_keys/decrease_keyboard_brightness" "bindsym XF86KbdBrightnessUp exec sudo ~/.mac_keys/increase_keyboard_brightness" "bindsym XF86AudioLowerVolume exec ~/.mac_keys/volume_control lower" "bindsym XF86AudioRaiseVolume exec ~/.mac_keys/volume_control raise" "bindsym XF86AudioMute exec ~/.mac_keys/volume_control mute" 'bindsym Mod4+Shift+XF86LaunchA exec sh -c "xfce4-screenshooter -f -s ~/Pictures/Screenshots/$(date +%s%3N).png"'; do  
        if ! grep -q "$binding" ~/.config/i3/config; then
            echo "$binding" | tee -a ~/.config/i3/config
        fi
    done
else
    echo "Error: i3 config not found at ~/.config/i3/config. Skipping this step."
fi


# Step 4: reload i3
echo "All done! Please reload i3 using mod+Shift+R."

