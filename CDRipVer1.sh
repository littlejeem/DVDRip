#!/bin/bash 
#This script rips CDs to FLAC using sound-juicer 
#It then converts them to ALAC for iTunes and HomeSharing 
#It translates the FLAC metadata to the ALAC metadata format 
#It also retains the original FLAC file for prosperity
#Work taken from this website
#http://confoundedtech.blogspot.co.uk/2011/11/ubuntu-automatically-rip-cd-to-flac-and.html



##############################
### SET YOUR PARAMETERS ### 
############################## 
 


#Set the base directory 
sBASEDIR="/DATA/Music/" 
 
#Set directory sound juicer rips to 
sIN="Ripped" 
 
#Set directory ALAC files are placed in 
sOUTALAC="Automatically Add to iTunes" 
 
#Set directory converted FLAC files are placed in 
sOUTFLAC="Processed" 
 


###################################
### DO NOT EDIT BELOWTHIS LINE ###
###################################

#Check and install flac 
problem=$(dpkg -s flac|grep installed) 
echo "Checking for flac: $problem" 
if [ "" == "$problem" ]; then 
     echo "No flac. Setting up flac" 
     sudo apt-get --force-yes --yes install flac 
fi 
 
#Check and install ffmpeg 
problem=$(dpkg -s ffmpeg|grep installed) 
echo "Checking for ffmpeg: $problem" 
if [ "" == "$problem" ]; then 
      echo "No ffmpeg. Setting up ffmpeg" 
      sudo apt-get --force-yes --yes install ffmpeg 
fi 
 
#Check and install sound-juicer 
problem=$(dpkg -s sound-juicer|grep installed) 
echo "Checking for sound-juicer: $problem" 
if [ "" == "$problem" ]; then 
      echo "No sound-juicer. Setting up sound-juicer" 
      sudo apt-get --force-yes --yes install sound-juicer 
fi 
 
#Start sound-juicer 
sound-juicer 
 
###############################
### START ALAC CONVERSION ### 
###############################
 

#Set up some directory paths based on the variables 
sINPATH="$sBASEDIR""$sIN" 
sOUTALACPATH="$sBASEDIR""$sOUTALAC" 
sOUTFLACPATH="$sBASEDIR""$sOUTFLAC" 
echo "Variables set" 
 
#Create ALAC output directory structure 
find $sINPATH -type d | sed "s/$sIN/$sOUTALAC/" | xargs -d'\n' mkdir 
 
#Create processed FLAC directory structure, prevents future reprocessing 
find $sINPATH -type d | sed "s/$sIN/$sOUTFLAC/" | xargs -d'\n' mkdir 
 
#Capture the FLAC meta data for conversion to ALAC metadata 
for i in "$sINPATH"/*/*/*.flac 
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
 
#Finally after all files have been processed delete the empty source ripped directories of the files which have been processed, which now reside in the converted folder and ALAC folder 
for FOLDER in $sINPATH/* 
    do 
    rm -r "$FOLDER" 
    done 
exit; 