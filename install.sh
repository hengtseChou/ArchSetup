#!/bin/bash
set -e

deps=("gum" "figlet")
missing_deps=()
for dep in "${deps[@]}"; do
  if ! command -v "$dep" 2>&1 >/dev/null; then
    missing_deps+=("$dep")
  fi
done
if [[ ${#missing_deps[@]} -gt 0 ]]; then
  read -p "Install dependencies for the script? (Y/n): " install_deps
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
export GUM_CONFIRM_PROMPT_FOREGROUND="${colors[7]}"
export GUM_CONFIRM_SELECTED_BACKGROUND="${colors[2]}"
export GUM_SPIN_SPINNER_FOREGROUND="${colors[2]}"
export GUM_SPIN_TITLE_FOREGROUND="${colors[7]}"

figlet "Arch Setup Script" -f smslant
print_color_palette

aur=$(gum choose "paru" "yay" "aura" "trizen" --header "Choose your AUR helper:")
gum style --foreground "${colors[2]}" "Selected AUR helper: $aur"
case $aur in
"paru")
  if ! command -v paru 2>&1 >/dev/null; then
    gum style --foreground "${colors[2]}" "paru is not installed. Installing now..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
  fi
  ;;
"yay")
  if ! command -v yay 2>&1 >/dev/null; then
    gum style --foreground "${colors[2]}" "yay is not installed. Installing now..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
  fi
  ;;
"aura")
  if ! command -v aura 2>&1 >/dev/null; then
    gum style --foreground "${colors[2]}" "aura is not installed. Installing now..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/aura.git
    cd aura
    makepkg -si
    cd ..
  fi
  ;;
"trizen")
  if ! command -v trizen 2>&1 >/dev/null; then
    gum style --foreground "${colors[2]}" "trizen is not installed. Installing now..."
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
config_path=""
while true; do
  create_config_folder=$(gum choose --header "Create a dedicated config folder under $HOME?" "Yes" "No")
  if [[ "$create_config_folder" == "Yes" ]]; then
    folder=$(gum input --header "Folder name:")
    if [[ -n "$folder" && "$folder" =~ ^[a-zA-Z0-9_-]+$ ]]; then
      if [[ -d "$HOME/$folder" ]]; then
        overwrite=$(gum choose --header "Folder already exists. Overwrite?" "Yes" "No")
        if [[ "$overwrite" == "Yes" ]]; then
          rm -rf "$HOME/$folder"
          mkdir "$HOME/$folder"
          config_path="$HOME/$folder"
          break
        else
          gum style --foreground "#9c1625" "Folder $folder already exists. Try again."
        fi
      else
        mkdir "$HOME/$folder"
        config_path="$HOME/$folder"
        break
      fi
    else
      gum style --foreground "#9c1625" "Folder name cannot be empty or contain special characters. Try again."
    fi
  else
    break
  fi
done

cd base
if [[ -n "$config_path" ]]; then
  cp -r ./config/* "$config_path"
fi
bash ./setup.sh $aur "$config_path"

# -------------------------------- desktop environments -------------------------------- #

# validate_input() {
#   for choice in $selection; do
#     if ! [[ "$choice" =~ ^[1-3]$ ]]; then
#       gum style --foreground "#9c1625" "Invalid input $selection. Please try again."
#       return 1
#     fi
#   done
#   return 0
# }
# display_options() {
#   echo "Pick one or more DE/WM with pre-configured setup:"
#   echo "   1) GNOME"
#   echo "   2) Hyprland"
#   echo "   3) niri"
# }
# declare -A setups=(
#   ["1"]="GNOME"
#   ["2"]="Hyprland"
#   ["3"]="niri"
# )
# display_options
# while true; do
#   selection=$(gum input --header "Enter a selection (default=1): ")
#   if [[ -z "$selection" ]]; then
#     selection="1"
#   fi
#   if validate_input; then
#     selected_setups=()
#     for choice in $selection; do
#       selected_setups+=("${setups[$choice]}")
#     done
#     selected_setups=$(IFS=", " echo "${selected_setups[*]}")
#     break
#   fi
# done
# gum style --foreground "${colors[2]}" "Selected DE/WM: $selected_setups"

# ---------------------------------------- extra --------------------------------------- #
