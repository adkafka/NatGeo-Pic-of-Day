#!/bin/bash
#Written by Adam Kafka


#############
# FUNCTIONS #
#############

function usage(){
    echo "USAGE: $0 -i (inputFile) -o (outputFile) -t \"title\" -d \"description\" -c \"credit\""
    exit 1
}

function getHeight (){ #Takes a pixel height of original image and calculates the necessary height of the caption
	PERCENT=0.025 #Factor to decease caption by
	echo "${HEIGHT}*${PERCENT}" | bc
}

function addTitle(){
    convert ${INFILE} -fill white -undercolor '#00000080' -pointsize 30 -gravity North -annotate +0+5 "${TEXTtitle}" ${OUTPUT}
}
function addDesc(){
    convert -background '#0008' -fill white -size ${smallerWidth}x -pointsize 12 caption:"${TEXTdesc}" ${INFILE} +swap -gravity South -composite ${OUTPUT}
}
function addCredit(){
    convert -background '#0008' -fill white -size 150x -pointsize 10 caption:"${TEXTcredit}" ${INFILE} +swap -composite ${OUTPUT}
}

###############
# MAIN METHOD #
###############


while getopts ":i:o:t:d:c:" opt; do
  case $opt in
    i)
      INFILE=$OPTARG
      FILENAME=`echo ${INFILE} | sed 's:\.[A-z]\{2,4\}::g'`
      WIDTH=`identify -format %w ${INFILE}`
      smallerWidth=`echo "${WIDTH}*0.5" | bc`
      HEIGHT=`identify -format %h ${INFILE}`
      HEIGHT=`getHeight`
      OUTPUT=$INFILE #Will be changed if specified with -o
      ;;
    o)
      OUTPUT=$OPTARG
      ;;
    t)
      TEXTtitle=$OPTARG
      addTitle
      ;;
    d)
      TEXTdesc=$OPTARG
      addDesc
      ;;
    c)
      TEXTcredit=$OPTARG
      addCredit
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      usage
      ;;
  esac
done

if [ -z $1 ]; then
    usage
fi

echo "file:$INFILE; title:$TEXTtitle; desc:$TEXTdesc; credit:$TEXTcredit"

shift $((OPTIND - 1))

exit 0
