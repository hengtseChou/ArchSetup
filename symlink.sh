#!/bin/bash
# ---------------------------------------------------------------------------- #
#    Script made by hengtseChou
#    Symlink dotfiles to ~/ or ~/.config
#    Also support custom directory
# ---------------------------------------------------------------------------- #
_usage() {
  echo "Usage: symlink <dotfile> [--to-home] [--to-config] [--custom-dir <path>] [-v, --verbose]"
}

if [ $# -lt 1 ]; then
  _usage
  exit 1
fi

source="$1"
shift
PARSED=$(getopt -o v --long to-home,to-config,custom-dir:,verbose -- "$@")
if [[ $? -ne 0 ]]; then
  exit 1
fi
eval set -- "$PARSED"

target_dir=""
verbose=0
while true; do
  case "$1" in
  --to-home)
    target_dir="$HOME"
    shift
    ;;
  --to-config)
    target_dir="$HOME/.config"
    shift
    ;;
  --custom-dir)
    target_dir="$2"
    shift 2
    ;;
  -v|--verbose)
    verbose=1
    shift
    ;;
  --)
    shift # End of options
    break
    ;;
  *)
    echo "Invalid option: $1" >&2
    exit 1
    ;;
  esac
done

# If no valid options were provided (target_dir is empty), show an error and exit
if [ -z "$target_dir" ]; then
  _usage
  exit 1
fi

target="$target_dir/$(basename $source)"

if [ -L "${target}" ]; then
  # is a symlink
  rm ${target}
  ln -s ${source} ${target}
  if [ $? -eq 0 ]; then
    [ $verbose -eq 1 ] && echo ":: Existing symlink ${target} removed."
    [ $verbose -eq 1 ] && echo ":: Symlink ${source} -> ${target} created."
  else
    exit 1
  fi
elif [ -d ${target} ]; then
  # is a dir
  rm -rf ${target}/
  ln -s ${source} ${target}
  if [ $? -eq 0 ]; then
    [ $verbose -eq 1 ] && echo ":: Existing directory ${target} removed."
    [ $verbose -eq 1 ] && echo ":: Symlink ${source} -> ${target} created."
  else
    exit 1
  fi
elif [ -f ${target} ]; then
  # is a file
  rm ${target}
  ln -s ${source} ${target}
  if [ $? -eq 0 ]; then
    [ $verbose -eq 1 ] && echo ":: Existing file ${target} removed."
    [ $verbose -eq 1 ] && echo ":: Symlink ${source} -> ${target} created."
  else
    exit 1
  fi
else
  ln -s ${source} ${target}
  if [ $? -eq 0 ]; then
    [ $verbose -eq 1 ] && echo ":: New symlink ${source} -> ${target} created."
  else
    exit 1
  fi
fi