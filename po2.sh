#! /bin/bash
#  Thanks to John1024 ( StackOverflow #33659076 )
#    - Heavily altered to be more flexible.

declare USAGE="\
USAGE:  po2.sh [-h|--help]
        po2.sh [(-r|--round) (CEIL|FLOOR|MID)] DECIMAL"

test $# -lt 1 && echo "$USAGE" && exit 1

declare -i rounding_policy=0

while [[ "$1" =~ ^- && ! "$1" == "--" ]] ; do
  case $1 in
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    -r|--round)
      shift ; test $# -lt 2 && echo "$USAGE" && exit 1
      case $1 in
        CEIL|0)
          let rounding_policy=0
          ;;
        FLOOR|1)
          let rounding_policy=1
          ;;
        MID|2)
          let rounding_policy=2
          ;;
      esac
      ;;
  esac
  shift
done ; test "$1" == "--" && shift

test $# -lt 1 && echo "$USAGE" && exit 1

case "$rounding_policy" in
  "0") # CEIL
    echo "\
    x = l($1) / l(2); \
    scale = 0; \
    2 ^ ((x / 1) + 1)" | bc --mathlib
    exit 0
    ;;
  "1") # FLOOR
    echo "\
    x = l($1) / l(2); \
    scale = 0; \
    2 ^ (x / 1)" | bc --mathlib
    exit 0
    ;;
  "2") # MID
    echo "\
    x = l($1) / l(2); \
    scale = 0; \
    2 ^ ((x + 0.5) / 1)" | bc --mathlib
    exit 0
    ;;
esac

echo "FUCK!"
exit 1