#!/bin/bash
#Written by Adam Kafka


##############
# PARAMETERS #
##############

#############
# FUNCTIONS #
#############

#Logger
function log(){
    echo "NatGeoPoD - `date` - $@" > $logFile
}

#Takes year, month, day and generates a numeric date as yyyy-mm-dd
function generateDateNum () {
    YEAR=`echo $date | egrep -o '[0-9]{1,2}, [0-9]{4}' | awk -F', ' '{print $2}'`
    DAY=`echo $date | egrep -o '[0-9]{1,2}, [0-9]{4}' | awk -F', ' '{print $1}'`
    MONTH=`echo $date |  egrep -o '[A-z]{3,10}'`

    DATENUM=`echo "$YEAR-"`

    #Get numeric value of month
    case "$MONTH" in
        January) DATENUM+="01";;
        February) DATENUM+="02";;
        March) DATENUM+="03";;
        April) DATENUM+="04";;
        May) DATENUM+="05";;
        June) DATENUM+="06";;
        July) DATENUM+="07";;
        August) DATENUM+="08";;
        September) DATENUM+="09";;
        October) DATENUM+="10";;
        November) DATENUM+="11";;
        December) DATENUM+="12";;

    esac

    DATENUM+="-${DAY}"
}

#Downloads the image, names it and adds caption
function DownloadImage(){
    #Grab image from line and save it as Day-Name.ext
    generateDateNum
    titleNoSpace=`echo $title | tr -d ' ' | sed 's/,/_/g'`
    ext=`echo $url | egrep -o '\.[a-z]{2,4}' | tail -1`
    name="${DATENUM}-${titleNoSpace}${ext}"
    log "Downloading img name:$name"
    curl -s -o ${name}.${ext} $picUrl
    #Add info as captions (WORK ON LAST)\
    
    #Copy to directory and link

    exit 0
}

 
###############
# MAIN METHOD #
###############
###########
#VARIABLES#
###########
url="http://photography.nationalgeographic.com/photography/photo-of-the-day/"
tempName="temp.html"
wkspFolder="workspace"
infoFile="info.txt.tmp"
logFile="/Users/Adam/Library/Logs/NatGeoPic.log"
pyScript="NatGeoPOD.py"

#######
#START#
#######

#Starting
log "STARTING SCRIPT"

cd $wkspFolder

#Clear workspace folder
rm -R ./*

#Download initial file, Exit if failed w/ log
log "Grabbing html page"
curl -s -o "${tempName}" $url #|| log "Curl request failed with exit status=$?; exit 1"

#Run python script & output to a file
python ../$pyScript > $infoFile

#Get info passed thru file, Read first line - from infoFile (awk with \n as seperator or each line with sed)
picUrl=`sed -n 1p $infoFile`
title=`sed -n 2p $infoFile`
credit=`sed -n 3p $infoFile`
date=`sed -n 4p $infoFile`
desc=`sed -n 5p $infoFile`

#Download Image function
DownloadImage #Exit if failed in function

exit -1 #should not be reachable

