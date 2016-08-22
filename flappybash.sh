#!/bin/bash

# FLAPPY BASH
# by Xion

W=${1-`tput cols`}
H=`tput lines`
W2=$[W/2]
H2=$[H/2]
H4=$[H/4]

DT=0.05  # 20 FPS
G=2  # minimum height of the pipe gap (is double this number)

K=.  # last pressed key (dot is ignored)
X=2
Y=$H2
VY=0  # vertical velocity
AY=100  # vertical acceleration
D=0
# current pipe is stored as an array of $H chars
P=( )  # start as empty array
PX=''  # pipe's current X
PVX=-100
S=0  # score


# update & draw, called every $DT seconds
a() {
    # Update
    ########

    case "$K" in
        q) exit ;;
        *[!\ ]*) ;;          # non-space
        *) VY='-60'; K=. ;;  # space
    esac

    VY=`_ "$VY+($AY*$DT)"`
    Y=`_ "y=$Y+($VY*$DT);if(y<0)0 else if(y>$H)$H else y"`; tY=`t $Y`

    PX=`_ "$PX+($PVX*$DT)"`; PX=`t $PX`
    # the -le check below is bad and I should feel bad, but doing it properly
    # (i.e. keeping previous and current value of PX, and checking if X is in between)
    # won't fit within the limit
    if [ $PX -le $X ] && [ ${P[tY]} = '█' ]; then D=1; exit; fi
    if [ $PX -le 0 ]; then
        ( s 700 0.1; s 350 0.1 )&  # be-boop
        S=$[S+1]
        np
    fi

    # Draw
    ######

    clear

    # draw the pipe
    for ((i=1; i<=$H; i++)); do
        p $PX $i "\e[1;32;49m${P[i]}"  # bold green-on-default
    done

    # draw the player
    p $X $tY "\e[1;37;41mB"  # bold white-on-red

    # draw the score
    p `_ "$W2-5"` 2 "\e[1;37;49mScore: $S"  # bold white-on-default

    # schedule the next call of this function
    ( sleep $DT; kill -14 $$ )&
}

# create a new pipe and place it all the way to the right
np() {
    _u=$[H4+RANDOM%(H2-H4-G)]  # upper pipe is < this coordinate
    _l=$[H2+G+RANDOM%(H2-H4-G)]  # lower pipe is >= this one

    for ((i=1; i<$_u; i++)) do P[i]='█'; done
    for ((i=$_u; i<$_l; i++)) do P[i]=' '; done
    for ((i=$_l; i<=$H; i++)) do P[i]='█'; done
    PX=$[W-1]  # start from the right side
}

# cleanup and exit
q() {
    $p "\e[?12l\e[?25h"  # cursor on
    tput rmcup
    $e -en "\e[0m"
    clear

    # handle failure
    if [ $D -gt 0 ]; then
        $e -en "\a";  # BEL
        $p "score:$S\ngit gud\n";
    fi
}


# put text at given position: p $x $y $text
p() { $e -en "\e[$2;${1}f$3"; }
# play a sine wave (requires ALSA): s $frequency $duration
s() { ( speaker-test >$n -t sine -f $1 )& _p=$!; sleep $2; kill -9 $_p; }
# wrapper over bc (basic POSIX calculator) that makes all computations shorter
_() { $e "$*" | bc; }
# truncate fractional part
t() { $p "%.*f" 0 $1; }


p=printf
e=echo
n=/dev/null


#
# Main
#

exec 2>$n  # swallow errors, because obviously they're just noise
tput smcup
$p "\e[?25l"  # cursor off
trap q ERR EXIT

# set terminal title and start main loop
$p "\e]0;FLAPPY BASH\007"
trap a 14  # handler for the ALRM signal
np  # create new pipe
a
while :; do
    read -rsn1 K
done
