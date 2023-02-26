#! /bin/bash

## Source the custom hash table
[[ -r ~/.hashtab ]] && . ~/.hashtab

declare -i DEFAULT_SZ=512

declare GIMPCONSOLE="gimp-console" 
declare FLAGS="--batch-interpreter=plug-in-script-fu-eval -idfs"
declare GIMP="$GIMPCONSOLE $FLAGS"

declare PATTERN="*.png"

declare USAGE="\
USAGE:  limp-po2-scale.sh [-h|--help]
        limp-po2-scale.sh [-p|--policy ( (CEIL|FLOOR|MID) | (NO_SQR|SQR_W|SQR_H) )]... DIR [MORE_DIRS...]

  --policy ARG  (default: CEIL & NO_SQR)
        -p ARG  - The rounding and squaring policies for making the texture(s) proper Po2."


declare -i rounding=0 squaring=0 debug=0

while [[ $1 =~ ^--?[a-zA-Z]* ]] ; do
  case $1 in
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    -p|--policy)
      shift ; test $# -lt 1 && echo "$USAGE" && exit 1
      case $1 in
        MID)
          let rounding=2
          ;;
        FLOOR)
          let rounding=1
          ;;
        CEIL)
          let rounding=0
          ;;
        SQR_H)
          let squaring=2
          ;;
        SQR_W)
          let squaring=1
          ;;
        NO_SQR)
          let squaring=0
          ;;
        *)
          let rounding=0 squaring=$1
          ;;
      esac
      ;;
    -g|--debug)
      let debug=1
      FLAGS+=" --verbose --console-messages"
      echo "Debug: ON    (FLAGS=\"$FLAGS\")"
      ;;
    ?)
      echo "No-op due to these ERROR(S)."
      echo "$USAGE"
      exit 1
      ;;
  esac
  shift
done

declare -a files=
for d in $@ ; do
  if [[ -f "$d" ]] ; then
    files+=("\"$d\"")
    continue
  fi

  d="$(realpath ${d%/})"

  if [[ ! -d "$d" ]] ; then
    echo "Directory does not exist: \"$d\""
    continue
  fi

  files+=$(find "$d" -type f -ipath "$PATTERN" -printf '"%p" ')
done

if [[ -z files ]] ; then
  echo "NO INPUT FILES EXIST!"
  echo "$USAGE"
  exit 1
fi

# declare base=$(cat limp-po2-scale.scm | grep -E '^[^;]+$')"
declare cmds="(limp-po2-scale $rounding $squaring (list ${files[@]}))"
declare DONE="(gimp-quit 0)"

# echo "$GIMP"

$GIMP -b "${cmds}" -b "${DONE}"
