#!/bin/bash 
#This script rips CDs to FLAC using abcde 
#It then converts them to ALAC for iTunes and HomeSharing using FAAC 
#It keeps the FLAC and .m4a files
#It uses beets audio library manager to tag both sets of files and write fil names
#It then uses rsync to move files to useful directory's
#Asks Kodi to update its library
#Exits

##############################
### SET YOUR PARAMETERS ### 
############################## 
 
#Set the base directory 
sBASEDIR="/home/jlivin25/Music/" 
 
#Set directory abcde  rips to 
sIN="flac"
 
#Set directory ALAC files are placed in 
sOUTALAC="AutoAddiTunes" 
 
#Set directory converted FLAC files are placed in 
sOUTFLAC="Processed"
 
###################################
### DO NOT EDIT BELOWTHIS LINE ###
###################################

#Check and install flac 
#problem=$(dpkg -s flac|grep installed) 
#echo "Checking for flac: $problem" 
#if [ "" == "$problem" ]; then 
#     echo "No flac. Setting up flac" 
#     sudo apt-get --force-yes --yes install flac 
#fi 
 
#Check and install ffmpeg 
#problem=$(dpkg -s ffmpeg|grep installed) 
#echo "Checking for ffmpeg: $problem" 
#if [ "" == "$problem" ]; then 
#      echo "No ffmpeg. Setting up ffmpeg" 
#      sudo apt-get --force-yes --yes install ffmpeg 
#fi 
 
#Check and install abcde 
#problem=$(dpkg -s abcde|grep installed) 
#echo "Checking for abcde: $problem" 
#if [ "" == "$problem" ]; then 
#      echo "No abcde. Setting up abcde" 
#      sudo apt-get --force-yes --yes install abcde 
#fi 

#Check and install python-dev & python pip
#problem=$(dpkg -s python-dev python-pip|grep installed) 
#echo "Checking for python-dev & pyhton-pip: $problem" 
#if [ "" == "$problem" ]; then 
#      echo "No python-dev or python-pip. Setting up python-dev" 
#      sudo apt-get --force-yes --yes install python-dev python-pip 
#fi 

#Check and install beets music manager 
#problem=$(dpkg -s beets|grep installed) 
#echo "Checking for beets: $problem" 
#if [ "" == "$problem" ]; then 
#      echo "No beets. Setting up beets" 
#      sudo pip install beets 
#fi
#sudo pip install beets
#Check and install beets extension acoustic fingerprint
#problem=$(dpkg -s pyacoustid|grep installed) 
#echo "Checking for acoustid: $problem" 
#if [ "" == "$problem" ]; then 
#      echo "No acoutsic fingerprint extension. Setting up pyacoustid" 
#      sudo pip install pyacoustid
#sudo pip install pyacoustid
#
#Start abcde
rm -r ~/Music/AutoAddiTunes
rm -r ~/Music/Processed
rm ~/Music/musiclibrary.blb
#Start abcde and tell it to use as many processor cores as poss, thanks go to Jim Vanns
abcde -j `getconf _NPROCESSORS_ONLN`
#
###############################
### START ALAC CONVERSION ### 
###############################
#
#Set up some directory paths based on the variables 
sINPATH="$sBASEDIR""$sIN" 
sOUTALACPATH="$sBASEDIR""$sOUTALAC" 
sOUTFLACPATH="$sBASEDIR""$sOUTFLAC" 
echo "Variables set" 
 
#Create ALAC output directory structure 
find $sINPATH -type d | sed "s/$sIN/$sOUTALAC/" | xargs -d'\n' mkdir
#find $sINPATH -type d | sed "s/$sIN/$sOUTALAC/" | xargs -d -o'\n' mkdir 
 
#Create processed FLAC directory structure, prevents future reprocessing 
find $sINPATH -type d | sed "s/$sIN/$sOUTFLAC/" | xargs -d'\n' mkdir 
 
#Capture the FLAC meta data for conversion to ALAC metadata 
for i in "$sINPATH"/*/*/*.flac
#for i in "$sINPATH"/*/*.flac
do 
 
ARTIST=`metaflac "$i" --show-tag=ARTIST | sed s/.*=//g` 
TITLE=`metaflac "$i" --show-tag=TITLE | sed s/.*=//g` 
ALBUM=`metaflac "$i" --show-tag=ALBUM | sed s/.*=//g` 
GENRE=`metaflac "$i" --show-tag=GENRE | sed s/.*=//g` 
TRACKTOTAL=`metaflac "$i" --show-tag=TRACKTOTAL | sed s/.*=//g` 
DATE=`metaflac "$i" --show-tag=DATE | sed s/.*=//g` 
TRACKNUMBER=`metaflac "$i" --show-tag=TRACKNUMBER | sed s/.*=//g` 
 
#Meta data options source:
#http://multimedia.cx/eggs/supplying-ffmpeg-with-metadata/ 
 
#Code to echo the metadata for debugging 
#echo $ARTIST 
#echo $TITLE 
#echo $ALBUM 
#echo $GENRE 
#echo $TRACKTOTAL 
#echo $DATE 
#echo $TRACKNUMBER 
 
#Set the array of files to process along with their output path 
o="${i/$sIN/$sOUTALAC}" 
 
#Set the array of files to process along with their new files extension 
o=""${o/.flac/.m4a}"" 
 
#Echo the files that will be processed to check in debugging 
o=""$(echo $o | sed 's/_//g')"" 
 
#Construct the filepath for the first file in the array to process 
filepath=${i%/*} 
 
#Construct the filename for the first file in the array to process 
filename=${i##*/} 
 
#Echo the path and file name to the terminal for debugging 
echo $i 
echo $o 
 
#Start the convrsion of file i in the array to ALAC with the metadata 
echo "n" |  ffmpeg -i "$i" -metadata title="$TITLE" -metadata author="$ARTIST" -metadata album="$ALBUM" -metadata year="$DATE" -metadata track="$TRACKNUMBER" -acodec alac "$o" 
 
#Move the ripped file that has been processed to the coverted file directory to stop ffmpeg trying to process the file again in future 
d="${i/$sIN/$sOUTFLAC}" 
mv "$i" "$d" 
done 
 
#After all files have been processed delete the empty source ripped directories of the files which have been processed, which now reside in the converted folder and ALAC folder 
for FOLDER in $sINPATH/* 
    do 
    rm -r "$FOLDER" 
    done 
###############################
### START LIBRARY WORK      ### 
###############################
#
#start beets audio manager and ask it to look in the AutoAddiTunes folder and tag files there
beet import ~/Music/AutoAddiTunes
# 
rsync -avrv ~/Music/AutoAddiTunes/ /media/Data_1/Music/correct/Albums
#
rm -r ~/Music/AutoAddiTunes
#
rm ~/Music/musiclibrary.blb
#
beet import ~/Music/Processed
#
rsync -avrv ~/Music/AutoAddiTunes/ /media/Data_1/Music/FLAC_Backups
#rsync -avrv  /media/Data_1/Music/correct/Albums
#
rm -r ~/Music/Processed
#
rm -r ~/Music/AutoAddiTunes
#
rm ~/Music/musiclibrary.blb
#
# ask kodi to update music library
curl --data-binary '{ "jsonrpc": "2.0", "method": "AudioLibrary.Scan", "id": "mybash"}' -H 'content-type: application/json;' http://localhost:8080/jsonrpc
# source for above come from http://kodi.wiki/view/HOW-TO:Remotely_update_library , changed port to my own, control of other systems must be on and webserver
#
###########
### END ### 
###########
exit;