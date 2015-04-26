#!/bin/bash
#
set -eu
#
# code below is derived from work by JimVanns, thanks
# https://github.com/jvanns/htpc/blob/master/dsc-trg-q
#
#
###########################################################################
###                        DEFINE VARIABLES HERE                        ###
### $HOME DOES NOT NEED DEFINING AS IT SEEMS TO BE BUILT INTO BASH FROM ###
###   WHAT POSTS I HAVE READ RELATING TO USING WHAT I THINK ARE UDEV    ###
###  ENVIRONMENTAL VARIABLES E.G. $ID_CDROM_MEDIA_CD DO NOT APPEAR TO   ###
###    NEED DEFINING THEMSELVES, ALSO PART OF BASH OR LINUX COMMAND     ###
###                      STRUCTURE CALLED BY BASH?                      ###
###########################################################################
#
MEDIA=
#
##############################################################################
### LEFT IN SO AS TO ALTER AS LITTLE AS POSSIBLE, I HAVE READ THAT DELAYS  ###
###  OFTEN IRON OUT KINKS IN CODE,  PLUS ALSO FOUND IT USEFULL TO ALLOW A  ###
###    SMALL DELAY FOR CD-DRIVE TO DO ITS THING AFTER PUTTING DISK IN      ###
##############################################################################
#
sleep 2
#
mkdir -p $HOME/myscripts/scriptlogs

if [ "$ID_CDROM_MEDIA_BD" = "1" ]
then
        MEDIA=bluray
        (
        echo "$MEDIA" >> $HOME/myscripts/scriptlogs/DiscTypeTest.log
        ) &
if [ "$ID_CDROM_MEDIA_DVD" = "1" ]
then
        MEDIA=dvd
        (
        echo "$MEDIA" >> $HOME/myscripts/scriptlogs/DiscTypeTest.log
        ) &
elif [ "$ID_CDROM_MEDIA_CD" = "1" ]
then
        MEDIA=cdrom
        (
        echo "$MEDIA" >> $HOME/myscripts/scriptlogs/DiscTypeTest.log
        ) &
fi
