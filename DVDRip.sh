#!/bin/bash
OUTPUT_DIR="$HOME/Movies/DVD"
mkdir -p $OUTPUT_DIR
SOURCE_DRIVE="/dev/sr0"
HANDBRAKE_PRESET="High Profile"
EXTENSION="mkv"
function rip_dvd() {
        # Grab the DVD title
        DVD_TITLE=$(blkid -o value -s LABEL $SOURCE_DRIVE)
        # Replace spaces with underscores
        DVD_TITLE=${DVD_TITLE// /_}
        # Backup the DVD to hard drive
        dvdbackup -i $SOURCE_DRIVE -o $OUTPUT_DIR -M -n $DVD_TITLE
        # grep for the HandBrakeCLI process and get the PID
        HANDBRAKE_PID=`ps aux|grep H\[a\]ndBrakeCLI`
        set -- $HANDBRAKE_PID
        HANDBRAKE_PID=$2
        # Wait until our previous Handbrake job is done
        if [ -n "$HANDBRAKE_PID" ]
        then
                while [ -e /proc/$HANDBRAKE_PID ]; do sleep 1; done
        fi
        # HandBrake isn't ripping anything so we can pop out the disc
        eject $SOURCE_DRIVE
        # this bit is for TV Series
        cd "$HOME/Movies/DVD/$DVD_TITLE/VIDEO_TS/"
        #change directory above the list contents into file for use
        ls >> "$HOME/myscripts/scriptlogs/ls.log"
        #create a new variable that is a count of the number of VTS.vob files are in the above file
        CHAPTER_COUNT=$(grep -co VTS_**_0.VOB $HOME/myscripts/scriptlogs/ls.log | wc -l)
        # now use this variable to create a loop to carry on encoding until all the vob file are encoded
        for ((i=1; i<=$CHAPTER_COUNT; i++))
        # And now we can start encoding
        do
         #handbrake title from above variable inout from folder output it to a folder using an incremental numbering system to .mkv high profile and only encode long files
         HandBrakeCLI -t $i -i $OUTPUT_DIR/$DVD_TITLE -o $OUTPUT_DIR/$DVD_TITLE"_"$i.$EXTENSION --preset=$HANDBRAKE_PRESET --min-duration 1200
        done
        # Clean up
        rm -R $OUTPUT_DIR/$DVD_TITLE
        rm $HOME/myscripts/scriptlogs/ls.log
        mv $HOME/Movies/DVD/* $HOME/"TV Shows"
        rm -R $OUTPUT_DIR
}
rip_dvd
