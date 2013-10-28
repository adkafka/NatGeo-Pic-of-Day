#!/bin/bash
#Written by Adam Kafka

# This script goes to the NatGeo pic of day url (or from $1) and grabs the downloads the PoD
## The script also adds the title of the post to the image along with the description and the credit by using ../imageCaptions/addCaption.sh

# FLAGS
## Silent flag (silentFlag) - True to be silent
## Recursive flag (recursiveFlag) - True to run recursively to yesterday
## Force flag (forceFlag) - Force download this time (ignore whether succeeded today)


# Things to add:
## Add in -s and -r flags to trigger in place flags
## Make ln only run if doesn't already exist

#############
# FUNCTIONS #
#############

#Logger
function log(){
    if  [ ! "$silentFlag" == "True" ]; then #If silent flag does not equal true
        echo "NatGeoPoD - `date` - $@" >> $logFile
    fi
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

#Puts final file where it belongs
function moveFileToDest(){
    mv ${name} ${destFolder} #Move to destination folder
    ln "${destFolder}${name}" "${otherDir}" #Link destination to screen saver directory
}

#Downloads the image, names it and adds caption
function DownloadImage(){
    #Grab image from line and save it as Day-Name.ext
    generateDateNum
    titleNoSpace=`echo $title | tr -d ' ' | sed 's/,/_/g'`
    ext=`echo $picUrl | egrep -o '\.[a-z]{2,4}' | tail -1`
    name="${DATENUM}-${titleNoSpace}${ext}"
    log "Downloading img name:$name"
    curl -s -o ${name} $picUrl || curlExit=$?
    if [[ $curlExit -gt 0 ]]; then
        log "Curl failed ($curlExit)"
        exit 1
    fi
    #Add info as captions (WORK ON LAST)
    log `bash ../../imageCaptions/addCaption.sh -i "${name}" -t "${title}"  -d "${desc}" -c "${credit}"`

    #Copy to directory and link
    if [ -a $name ];then #Marked as succesful
        log "Succeeded"
        moveFileToDest #File creation, manipulation, and naming is complete. Now move it to where it belongs
        ##Use for recursion testing...
        if [ "$recursiveFlag" == "True" ]; then
            log "Running recursively with url=\"${prevLink}\" as the next link"
            cd .. #Get out of workspace folder
            source $0 ${prevLink} 
            
        fi
        exit 0
    fi
    log "File does not exist. DownloadImage function failed"
    exit 2
}

 
###############
# MAIN METHOD #
###############
###########
#VARIABLES#
###########
#silentFlag="True" #Comment out to run normally
#recursiveFlag="True" #Comment out to run normally
#forceFlag="True" # Comment out to run normally

destFolder="/Users/Adam/Desktop/PicturesOfDay/NatGeo/"
url="http://photography.nationalgeographic.com/photography/photo-of-the-day/"
tempName="temp.html"
wkspFolder="/Users/Adam/Projects/NatGeoPicOfDay/workspace"
otherDir="/Users/Adam/Pictures/Screen Saver Pics" #ScreenSaverPics directory
infoFile="info.txt.tmp"
logFile="/Users/Adam/Library/Logs/NatGeoPic.log"
pyScript="NatGeoPOD.py"

#Parameter input
if [ -n "$1" ]; then #If url is provided, use that one instead of default
    url=$1
    echo "Using provided url"
fi

#######
#START#
#######

#Create log file if it doesn't exist already
if [ ! -f ${logFile} ]; then
    touch ${logFile}
fi

#See if ran succesfully today
cat ${logFile} | egrep -q "NatGeoPoD - `date +%a" "%b" "%d` [0-9:]{8} `date +%Z" "%Y` - Succeeded"
succeeded=`echo $?`
if [ ! "$forceFlag" == "True" ]; then
    if [[ ${succeeded} -eq 0 ]];then
        log "No need to run. already succeeded today"
        exit 0
    fi
fi

#Starting
log "STARTING SCRIPT"

cd $wkspFolder

#Clear workspace folder BE CAREFUL WITH rm -R!!!!!!!
rm -R ${wkspFolder}/*

#Download initial file, Exit if failed w/ log
log "Grabbing html page"
curl -s -o "${tempName}" $url || curlExit=$?
if [[ $curlExit -gt 0 ]]; then
    log "Curl failed ($curlExit)"
    exit 1
fi 
#Run python script & output to a file
python3.2 ../$pyScript > $infoFile

#Get info passed thru file, Read first line - from infoFile (awk with \n as seperator or each line with sed)
picUrl=`sed -n 1p $infoFile`
title=`sed -n 2p $infoFile`
credit=`sed -n 3p $infoFile`
date=`sed -n 4p $infoFile`
desc=`sed -n 5p $infoFile | sed s/\"/\'/g` #remove single quotes
prevLink=`sed -n 6p $infoFile`

#Download Image function
DownloadImage #Exit if failed in function

exit -1 #should not be reachable

