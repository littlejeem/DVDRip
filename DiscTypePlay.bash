#!/bin/bash
# code below is derived from work by JimVanns, thanks
# https://github.com/jvanns/htpc/blob/master/dsc-trg-q
MEDIA=
sleep 2

if [ "$ID_CDROM_MEDIA_BD" = "1" ]
then
        MEDIA=bluray
        (
        echo "$MEDIA" >> /jlivin25/home/myscripts/scriptlogs/DiscTypePlay.log
        )
elif [ "$ID_CDROM_MEDIA_DVD" = "1" ]
then
        MEDIA=dvd
        (
        echo "$MEDIA" >> /jlivin25/home/myscripts/scriptlogs/DiscTypePlay.log
        )
elif [ "$ID_CDROM_MEDIA_CD" = "1" ]
then
#       NO_MOUNT=1
#       NO_EJECT=1
        MEDIA=cdrom
        (
        echo "$MEDIA" >> /jlivin25/home/myscripts/scriptlogs/DiscTypePlay.log
        )
fi
