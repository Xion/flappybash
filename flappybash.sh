#!/bin/bash

#
# FLAPPY BASH
# by Xion
#
# Note: requires UTF8 terminal
#

W=`tput cols`
H=`tput lines`
H2=$[H/2]

DT=0.05  # 20 FPS
G=3  # minimum height of pipe gap (is double this number)

KEY=.  # last pressed key (dot is ignored)
X=3
Y=$H2
VY=0  # vertical velocity
AY=100  # vertical acceleration
DEAD=0
# current pipe is stored as an array of $H chars
P=( )  # start as empty array
PX=''  # pipe's current X


tick() {
    if [ $DEAD -gt 0 ]; then exit; fi

    # Update
    ########

    case "$KEY" in
        q) exit ;;
        *[!\ ]*) ;;            # non-space
        *) VY='-70'; KEY=. ;;  # space
    esac

    VY=`_ "$VY+($AY*$DT)"`
    Y=`_ "y=$Y+($VY*$DT);if(y<0)0 else if(y>$H)$H else y"`

    # Draw
    ######

    clear

    # draw the pipe
    for ((i=0; i<$H; i++)); do
        echo -en "\e[$i;${PX}f\e[1;32;49m${P[i]}\e[0m"  # bold green-on-default
    done

    # draw the player (bold white-on-red)
    echo -en "\e[`t $Y`;${X}f\e[1;37;41mB\e[0m"

    # schedule the next call of this function
    ( sleep $DT; kill -ALRM $$ ) &
}

# create a new pipe and place it all the way to right
np() {
    local u=$[RANDOM % (H2-G)]  # upper pipe is < this coordinate
    local l=$[H2 + G + RANDOM % (H2-G)]  # lower pipe is >= this one

    for ((i=0; i<$u; i++)) do P[i]='#'; done
    for ((i=$u; i<$l; i++)) do P[i]=' '; done
    for ((i=$l; i<$H; i++)) do P[i]='#'; done
    PX=$[W-1]  # start from the right side
}

quit() {
    printf "\e[?12l\e[?25h"  # cursor on
    tput rmcup
    echo -en "\e[0m"
    clear
}


# wrapper over bc (basic POSIX calculator) that makes all computations shorter
_() { echo "$*" | bc; }
# truncate fractional part
t() { printf "%.*f" 0 "$1"; }


#
# Main
#

tput smcup
printf "\e[?25l"  # cursor off
trap quit ERR EXIT

# set terminal title and start main loop
printf "\e]0;FLAPPY BASH\007"
trap tick ALRM
np  # create new pipe
tick
while :; do
    read -rsn1 KEY
done
