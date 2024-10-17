<h1 align="center">✨ Arch Setup Script ✨</h1>

The script will:

- Setup a GNOME environment with some useful apps/extensions
- Setup a Hyprland environment with pre-configured style and some useful apps (including settting up zsh and oh-my-zsh)
- Install essential, standalone apps
- Apply configuration for standalone apps
- Install Useful scripts to Home Folder

All parts excluding essential apps can be skipped. See `./install.sh --help`.

Make sure you checking out packages/settings from `setup.sh` in each subfolder and add/remove as you need before installing.

```
> ff
                                                 hank@archlinux
                                                 --------------
                                                 OS    ➜  Arch Linux x86_64
                        -`                        ├   ➜  Linux 6.11.3-arch1-1
                       .o+`                       ├ 󰏖  ➜  862 (pacman)
                      `ooo/                       ├   ➜  zsh 5.9
                     `+oooo:                      ├ 󱑀  ➜  1 day, 3 hours, 39 mins
                    `+oooooo:                     └ 󰃩  ➜  1 days
                    -+oooooo+:
                  `/:-:++oooo+:                  DE    ➜  GNOME 47.0
                 `/++++/+++++++:                  ├ 󰣆  ➜  Mutter (Wayland)
                `/++++++++++++++:                 ├ 󱅞  ➜  greetd (Wayland)
               `/+++ooooooooooooo/`               ├ 󰏘  ➜  Colloid-Grey [GTK2/3/4]
              ./ooosssso++osssssso+`              ├ 󰀻  ➜  Colloid [GTK2/3/4]
             .oossssso-````/ossssss+`             ├   ➜  GNOME Terminal 3.54.0
            -osssssso.      :ssssssso.
           :osssssss/        osssso+++.          PC    ➜  HP Pavilion Plus Laptop 14-eh1xxx
          /ossssssss/        +ssssooo/-           ├ 󰻠  ➜  13th Gen Intel(R) Core(TM) i5-13500H (16) @ 4.70 GHz
        `/ossssso+/:-        -:/+osssso+-         ├ 󰢮  ➜  Intel Iris Xe Graphics @ 1.45 GHz [Integrated]
       `+sso+:-`                 `.-/+oso:        ├ 󰍛  ➜  7.90 GiB / 15.34 GiB (51%)
      `++:.                           `-/+/       ├ 󰋊  ➜  25.90 GiB / 250.00 GiB (10%) - btrfs
      .`                                 `/       ├ 󰍹  ➜  2880x1800 @ 90 Hz (as 1920x1200) in 14" [Built-in]
                                                  └   ➜  [ ■■■■■----- ]52% [Discharging]
```