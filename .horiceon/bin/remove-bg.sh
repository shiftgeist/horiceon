#!/bin/bash

# script to remove color from background

bg_color="White"
fg_color="#000"
input="$1"
output="remove-bg-$1"
apply_fill=1

main() {
  convert "$input" -transparent $bg_color "$output" # remove bg
  echo "Remove background"

  if [ "$apply_fill" -ne 0 ]; then
    convert "$output" xc:"$fg_color" -channel RGB -clut "$output" # make everthing mono-color
    echo "Clut lines"
  fi

  convert "$output" -trim +repage "$output" # trim transparent
  echo "Trim transparency"
}

help() {
  cat << EOF
usage: $0 [OPTIONS]

    -help            Show this message

    -i|--input       Image to transform ($input)

    -b|--background  What color to remove ($bg_color)
    -f|--foreground  Foreground color ($fg_color)
    -o|--output      Output name ($output)

    --skip-fill      Output name ($output)
EOF
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --help)
      help
      exit 0
    ;;
    -i|--input)
      input=$2
      shift
      ;;
    -b|--background)
      bg_color=$2
      shift
      ;;
    -f|--foreground)
      fg_color=$2
      shift
      ;;
    -o|--output)
      output=$2
      shift
      ;;
    --skip-fill)
      apply_fill=0
      shift
      ;;
  esac
  shift
done

main "$@"
