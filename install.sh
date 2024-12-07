#!/bin/bash
set -e

msg() {
  if [ "$1" == "-n" ]; then
    shift
    printf "\033[s\033[38;2;117;138;155m%s\033[0m\n" "$1"
  else
    printf "\033[s\033[38;2;117;138;155m%s\033[0m" "$1"
  fi
}
msg_update() {
  printf "\033[u\033[2K\r\033[38;2;117;138;155m%s\033[0m\n" "$1"
}
msg_error() {
  printf "\033[38;2;156;22;37m%s\033[0m\n" "$1"
}
export -f msg
export -f msg_update
export -f msg_error
create_dedicated_folder() {
  create=$(gum choose --header "Create a dedicated config folder ~/$1?" "Yes" "No")
  if [[ "$create" == "Yes" ]]; then
    if [[ -d "$HOME/$1" ]]; then
      overwrite=$(gum choose --header "~/$1 already exists. Overwrite?" "Yes" "No")
      if [[ "$overwrite" == "Yes" ]]; then
        rm -rf "$HOME/$1"
        mkdir "$HOME/$1"
        return 0
      else
        msg -n "Falling back to symlink config files directly from this repo."
        return 1
      fi
    else
      mkdir "$HOME/$1"
      return 0
    fi
  else
    msg -n "Falling back to symlink config files directly from this repo."
    return 1
  fi
}

deps=("gum" "figlet")
missing_deps=()
for dep in "${deps[@]}"; do
  if ! command -v "$dep" 2>&1 >/dev/null; then
    missing_deps+=("$dep")
  fi
done
if [[ ${#missing_deps[@]} -gt 0 ]]; then
  msg "Install dependencies for the script? (Y/n): "
  read install_deps
  install_deps=${install_deps:-Y}
  if [[ "$install_deps" =~ ^[Yy]$ ]]; then
    sudo pacman -Syu --needed "${missing_deps[@]}"
    clear
  else
    exit 1
  fi
fi

colors=(
  "#0b0b0c" # Color0:  Black
  "#61768F" # Color1:  Red
  "#758A9B" # Color2:  Green
  "#949EA3" # Color3:  Yellow
  "#B2BCC4" # Color4:  Blue
  "#BCC2C6" # Color5:  Magenta
  "#B7D4ED" # Color6:  Cyan
  "#d8dadd" # Color7:  White
  "#97989a" # Color8:  Bright Black
  "#61768F" # Color9:  Bright Red
  "#758A9B" # Color10: Bright Green
  "#949EA3" # Color11: Bright Yellow
  "#B2BCC4" # Color12: Bright Blue
  "#BCC2C6" # Color13: Bright Magenta
  "#B7D4ED" # Color14: Bright Cyan
  "#d8dadd" # Color15: Bright White
)
print_color_palette() {
  printf "\n   "
  for i in {0..15}; do
    # Extract RGB values from the colors array
    R=$((16#${colors[i]:1:2}))
    G=$((16#${colors[i]:3:2}))
    B=$((16#${colors[i]:5:2}))

    # Print the color block
    printf "\e[48;2;%d;%d;%dm   \e[0m " $R $G $B
  done
  # Reset terminal formatting
  printf "\e[0m\n\n"
}

export GUM_CHOOSE_HEADER_FOREGROUND="${colors[7]}"
export GUM_CHOOSE_SELECTED_FOREGROUND="${colors[2]}"
export GUM_CHOOSE_CURSOR_FOREGROUND="${colors[2]}"
export GUM_INPUT_HEADER_FOREGROUND="${colors[7]}"
export GUM_INPUT_PROMPT_FOREGROUND="${colors[2]}"
export GUM_INPUT_CURSOR_FOREGROUND="${colors[2]}"
export GUM_SPIN_SPINNER_FOREGROUND="${colors[2]}"
export GUM_SPIN_TITLE_FOREGROUND="${colors[7]}"

figlet "Arch Setup Script" -f smslant
print_color_palette

aur=$(gum choose "paru" "yay" "aura" "trizen" --header "Choose your AUR helper:")
msg -n "Selected AUR helper: $aur"
case $aur in
"paru")
  if ! command -v paru 2>&1 >/dev/null; then
    msg -n "paru is not installed. Installing now..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
  fi
  ;;
"yay")
  if ! command -v yay 2>&1 >/dev/null; then
    msg -n "yay is not installed. Installing now..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
  fi
  ;;
"aura")
  if ! command -v aura 2>&1 >/dev/null; then
    msg -n "aura is not installed. Installing now..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/aura.git
    cd aura
    makepkg -si
    cd ..
  fi
  ;;
"trizen")
  if ! command -v trizen 2>&1 >/dev/null; then
    msg -n "trizen is not installed. Installing now..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/trizen.git
    cd trizen
    makepkg -si
    cd ..
  fi
  ;;
esac
printf "\n"

# ------------------------------------- base setup ------------------------------------- #

# if we want a folder thats just for configs
if create_dedicated_folder "Conf"; then
  use_config_folder="true"
else
  use_config_folder="false"
fi
if [[ "$use_config_folder" == "true" ]]; then
  cp -r ./base/config/* "$HOME/Conf"
fi
bash ./base/setup.sh $aur $use_config_folder

# -------------------------------- desktop environments -------------------------------- #

validate_input() {
  for choice in $selection; do
    if ! [[ "$choice" =~ ^[1-3]$ ]]; then
      msg_error "Invalid input $selection. Please try again."
      return 1
    fi
  done
  return 0
}
display_options() {
  echo "Pick one or more DE/WM with pre-configured setup:"
  echo "   1) GNOME"
  echo "   2) Hyprland"
  echo "   3) niri"
}
declare -A setups=(
  ["1"]="GNOME"
  ["2"]="Hyprland"
  ["3"]="niri"
)
display_options
while true; do
  selection=$(gum input --header "Enter a selection (default=1): ")
  if [[ -z "$selection" ]]; then
    selection="1"
  fi
  if validate_input; then
    selected_setups=()
    for choice in $selection; do
      selected_setups+=("${setups[$choice]}")
    done
    selected_setups=$(IFS=", " echo "${selected_setups[*]}")
    break
  fi
done
msg -n "Selected DE/WM: $selected_setups"
printf "\n"

for choice in $selection; do
  case $choice in
  "1")
    figlet "GNOME" -f smslant
    bash ./GNOME/setup.sh $aur
    ;;
  "2")
    figlet "Hyprland" -f smslant
    bash ./Hyprland/setup.sh $aur $use_config_folder
    ;;
  "3")
    if create_dedicated_folder "Niri"; then
      use_niri_folder="true"
    else
      use_niri_folder="false"
    fi

    if [[ "$use_niri_folder" == "true" ]]; then
      cp -r ./niri/*/ "$HOME/Niri"
    fi

    figlet "niri" -f smslant
    bash ./niri/setup.sh $aur $use_niri_folder
    ;;
  *)
    msg_error "Unknown selection $choice. Exiting..."
    exit 1
    ;;
  esac
done
# ---------------------------------------- extra --------------------------------------- #
