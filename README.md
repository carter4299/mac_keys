# Mac Media Controls for Arch Linux i3

## Should work for most macbooks
#### Host: MacBookAir7,2 1.0 
#### Kernel: 6.4.12-arch1-1 
#### DE: sway 
#### WM: i3

## Dependecies:
(Launcher): 
Rofi \
(Sound):
pulseaudio 
pulseaudio-alsa
alsa-utils 

## Media Keys:
- f1: dec brightness
- f2: dec brightness
- f3: rofi list of open windows
- f4: rofi app launcher
- f5: dec keyboard brightness
- f6: dec keyboard brightness
- f10: mute volume
- f11: dec volume
- f12: inc volume

## Initial Setup

1. **Clone the Repository**

```zsh
    git clone xxxxxxx
```

2. **Run the Startup Script**

```zsh
    cd mac_keys
    chmod +x setup.sh
    ./setup.sh
```

After executing, reload i3 with `mod+shift+R`.

## Manual Configuration

1. **Read bash script** 

## Troubleshooting

If the brightness control isn't working, the most likely reason is that `/sys/class/backlight/acpi_video0/brightness` has no value. To check:

```zsh
    ls /sys/class/backlight/
```

If there's a value and the setup script didn't detect it, modify the setup script and hardcode the value. It should work after.


If the volume isnt working 

***Good Luck***