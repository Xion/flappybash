#!/bin/bash
W=${1-`tput cols`};H=`tput lines`;W2=$[W/2];H2=$[H/2];H4=$[H/4];DT=0.05;G=2;K=.;X=2;Y=$H2;VY=0;AY=99;D=0;P=( );PX='';PVX=-99;S=0; a() { case "$K" in q) exit;;*[!\ ]*);;*) VY=-64;K=.;;esac;VY=`_ "$VY+($AY*$DT)"`;Y=`_ "y=$Y+($VY*$DT);if(y<0)0 else if(y>$H)$H else y"`;tY=`t $Y`;PX=`_ "$PX+($PVX*$DT)"`;PX=`t $PX`;if [ $PX -le $X ] && [ ${P[tY]} = '█' ];then D=1;exit;fi;if [ $PX -le 0 ];then ( s 700 0.1;s 350 0.1 )&;S=$[S+1];np;fi;clear;for ((i=1;i<=$H;i++)) do p $PX $i "\e[1;32;49m${P[i]}";done;p $X $tY "\e[1;37;41mB";p `_ "$W2-5"` 2 "\e[1;37;49mScore: $S";( sleep $DT;kill -14 $$ )&}; np() { _u=$[H4+RANDOM%(H2-H4-G)];_l=$[H2+G+RANDOM%(H2-H4-G)];for ((i=1;i<$_u;i++)) do P[i]='█';done;for ((i=$_u;i<$_l;i++)) do P[i]=' ';done;for ((i=$_l;i<=$H;i++)) do P[i]='█';done;PX=$[W-1];}; q() { $p "\e[?12l\e[?25h";tput rmcup;$e -en "\e[0m";if [ $D -gt 0 ];then $e -en "\a";$p "score:$S\ngit gud\n";fi;}; p() { $e -en "\e[$2;${1}f$3";}; s() { ( speaker-test >$n -t sine -f $1 )& _p=$!;sleep $2;kill -9 $_p;}; _() { $e "$*"|bc;}; t() { $p "%.*f" 0 $1;};p=printf;e=echo;n=/dev/null;exec 2>$n;tput smcup;$p "\e[?25l";trap q ERR EXIT;$p "\e]0;FLAPPY BASH\007";trap a 14;np;a;while :;do read -rsn1 K;done