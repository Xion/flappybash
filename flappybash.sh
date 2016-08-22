#!/bin/bash

#
# FLAPPY BASH
# by Xion
#
# Note: requires UTF8 terminal
#

W=`tput cols`
H=`tput lines`
W2=$[W/2]
H2=$[H/2]
H4=$[H/4]

DT=0.05  # 20 FPS
G=2  # minimum height of pipe gap (is double this number)

KEY=.  # last pressed key (dot is ignored)
X=2
Y=$H2
VY=0  # vertical velocity
AY=100  # vertical acceleration
DEAD=0
# current pipe is stored as an array of $H chars
P=( )  # start as empty array
PX=''  # pipe's current X
PVX='-100'
S=0  # score


tick() {
    # Update
    ########

    case "$KEY" in
        q) exit ;;
        *[!\ ]*) ;;            # non-space
        *) VY='-60'; KEY=. ;;  # space
    esac

    VY=`_ "$VY+($AY*$DT)"`
    Y=`_ "y=$Y+($VY*$DT);if(y<0)0 else if(y>$H)$H else y"`; tY=`t $Y`

    PX=`_ "$PX+($PVX*$DT)"`; PX=`t $PX`
    # the -le check below is bad and I should feel bad, but doing it properly
    # (i.e. keeping previous and current value of PX, and checking if X is in between)
    # probably won't fit within the limit; oh well, maybe I'll try that later
    if [ $PX -le $X ] && [ ${P[tY]} = '#' ]; then DEAD=1; exit; fi
    if [ $PX -le 0 ]; then S=$[S+1]; np; fi

    # Draw
    ######

    clear

    # draw the pipe
    for ((i=1; i<=$H; i++)); do
        echo -en "\e[$i;${PX}f\e[1;32;49m${P[i]}"  # bold green-on-default
    done

    # draw the player
    echo -en "\e[$tY;${X}f\e[1;37;41mB"  # bold white-on-red

    # draw the score
    echo -en "\e[2;`_ "$W2-5"`f\e[1;37;49mScore: $S"  # bold white-on-default

    # schedule the next call of this function
    ( sleep $DT; kill -ALRM $$ ) &
}

# create a new pipe and place it all the way to right
np() {
    local u=$[H4+RANDOM % (H2-H4-G)]  # upper pipe is < this coordinate
    local l=$[H2+G+RANDOM % (H2-H4-G)]  # lower pipe is >= this one

    for ((i=1; i<$u; i++)) do P[i]='#'; done
    for ((i=$u; i<$l; i++)) do P[i]=' '; done
    for ((i=$l; i<=$H; i++)) do P[i]='#'; done
    PX=$[W-1]  # start from the right side
}

quit() {
    trap : ALRM
    printf "\e[?12l\e[?25h"  # cursor on
    tput rmcup
    echo -en "\e[0m"
    clear
    if [ $DEAD -gt 0 ]; then printf "score:$S\ngit gud\n"; fi
    exit
}


# wrapper over bc (basic POSIX calculator) that makes all computations shorter
_() { echo "$*" | bc; }
# truncate fractional part
t() { printf "%.*f" 0 "$1"; }


#
# Main
#

exec 2>/dev/null  # swallow errors, because obviously they're just noise
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
