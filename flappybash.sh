#!/bin/bash

#
# FLAPPY BASH
# by Xion
#
# Note: requires UTF8 terminal
#

# wrapper over bc (basic POSIX calculator) that makes all computations shorter
_() { echo "$*" | bc; }
# truncate fractional part
t() { printf "%.*f" 0 "$1"; }


W=`tput cols`
H=`tput lines`
DT=0.05  # 20 FPS

KEY=.  # last pressed key (dot is ignored)
X=3
Y=$[H / 2]
VY=0  # vertical velocity
AY=100  # vertical acceleration
DEAD=0


tick() {
    if [ $DEAD -gt 0 ]; then exit; fi

    # Update
    ########

    case "$KEY" in
        q) exit ;;
        *[!\ ]*) AY=100; VY=0 ;;     # non-space
        *) AY='-100'; KEY=. ;;  # space
    esac

    VY=`_ "$VY+($AY*$DT)"`
    Y=`_ "$Y+($VY*$DT)"`

    # Draw
    ######

    clear

    # draw the player (bold white-on-red)
    echo -en "\e[`t $Y`;${X}f\e[1;37;42mB\e[0m"

    # schedule the next call of this function
    ( sleep $DT; kill -ALRM $$ ) &
}

quit() {
    printf "\e[?12l\e[?25h"  # cursor on
    tput rmcup
    echo -en "\e[0m"
    clear
}


#
# Main
#

tput smcup
printf "\e[?25l"  # cursor off
trap quit ERR EXIT

# set terminal title and start main loop
printf "\e]0;FLAPPY BASH\007"
trap tick ALRM
tick
while :; do
    read -rsn1 KEY
done
