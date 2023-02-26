#! /bin/bash

## Source the custom hash table
[[ -r ~/.hashtab ]] && . ~/.hashtab

declare -i DEFAULT_SZ=512

declare GIMP="gimp-console" 
declare FLAGS="--new-instance --pdb-compat-mode=on -idfs"

declare OUTDIR="${0%/*}/generated"
declare FORMAT=".png"
declare USAGE="\
USAGE:  limp-noisegen.sh [-h|--help]
        limp-noisegen.sh [(-x|--width) XSIZE] [(-y|--height) YSIZE] [(-n|--iterations) NUM] [-r|--random-sizes] [BASENAME]

    --width XSIZE    (default: $DEFAULT_SZ)
         -x XSIZE  - The x-dimension of the textures to generate.
   --height YSIZE    (default: $DEFAULT_SZ)
         -y YSIZE  - The y-dimension of the textures to generate.
 --iterations NUM    (default: 1)
           -n NUM  - The number of textures to generate.
   --random-sizes
               -r  - Generates random sizes for each output file in the range (1,SIZE]."


declare -i xsz=$DEFAULT_SZ
declare -i ysz=$DEFAULT_SZ
declare -i num=1
declare -i rsz=0

while [[ $1 =~ ^--?[a-zA-Z]* ]] ; do
  case $1 in
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    -x|--width)
      shift ; test $# -lt 1 && echo "$USAGE" && exit 1
      let xsz="${1#-}"
      ;;
    -y|--height)
      shift ; test $# -lt 1 && echo "$USAGE" && exit 1
      let ysz="${1#-}"
      ;;
    -n|--iterations)
      shift ; test $# -lt 1 && echo "$USAGE" && exit 1
      let num=$1
      ;;
    -r|--random-sizes)
      let rsz+=1
      ;;
    -g|--debug)
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

declare base_filename="perlin-solid"
test $# -gt 0 && test -n "${@: -1}" && base_filename="${@: -1}"
base_filename="$OUTDIR/$base_filename"


function do_noisegen()
{
  local commands="$(cat limp-noisegen.scm)" next_file=
  for (( i = 1 ; i <= $num ; ++i )) ; do
    next_file="$(printf ${base_filename}_%3.3d${FORMAT} $i | cygpath -mapl --file -)"
    commands+="(limp-noisegen-solid \"$next_file\" $xsz $ysz)"$'\n'
  done

  exec "$GIMP" $FLAGS --batch="$commands" --batch="(gimp-quit 0)"
}

function do_random_sizes()
{
  local commands="$(cat limp-noisegen.scm)" next_file=
  local -i rx=0 ry=0
  for (( i = 1 ; i <= $num ; ++i )) ; do
    next_file="$(printf ${base_filename}_%3.3d${FORMAT} $i | cygpath -mapl --file -)"
    let rx=$(( $RANDOM % $xsz + 1 ))
    let ry=$(( $RANDOM % $ysz + 1 ))
    commands+="(limp-noisegen-solid \"$next_file\" $rx $ry)"$'\n'
  done

  exec "$GIMP" $FLAGS --batch="$commands" --batch="(gimp-quit 0)"
}



test -d "$OUTDIR" || mkdir "$OUTDIR"

if [[ rsz -gt 0 ]] ; then
  do_random_sizes
else
  do_noisegen
fi
