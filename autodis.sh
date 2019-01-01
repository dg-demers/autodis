#!/bin/bash

# autodis
# a shell script to disconnect from a PPP internet service provider after a 
# maximum connection time or if the incoming bitrate remains continuously 
# below 30.00 Kbps for 5 minutes. It also provides information to the user 
# about the connection such as elapsed time, bitrate, and its consistency.

  autodis () { 
    ifstat -zwnb 1 | { 
      declare -i i=1; 
      declare -i j=0; 
      local line; local x; local y; local maxtime; local limitword="max"; 
      if [[ $# = 0 ]]; 
        then maxtime="no time"; 
      elif [[ $1 = "report" &&  $# = 1 ]]; 
      then 
        maxtime="report"; 
        limitword="only"; 
      elif grep -E '^([0-9][0-9]:)?[0-5][0-9]:[0-5][0-9]$' <<<$1 >/dev/null;  # works
      then 
        maxtime="$1"; 
        if [[ ${maxtime:5:1} = "" ]]; then maxtime="00:$maxtime"; fi; 
      else 
        echo "Sorry, quitting because..."; 
        echo "you must provide either the elapsed time limit as HH:MM:SS or MM:SS,"; 
        echo "or the word \"report\", or no command line argument."; 
        exit 1; 
      fi; 

      while IFS= read -r line; 
      do 
        y="$(ps -C pppd --no-headers -o etime | tr -d [:blank:])"; 
        x="$(sed 's/^[ \t]*//;s/ .*//' <<<$line)";  # first non-whitespace sequence of characters up to & not including the next whitespace 
        if [[ $y = "" ]] || [[ $x = "n/a" ]]; 
        then 
          echo "CONNECTION ENDED: but not by autodis"; 
          beep -f 800 -l 200 -r 50 -d 400; # 0.5 min = 600 ms x 50 / 60 of beeping
          exit 3; 
        fi; 
        if [[ ${y:5:1} = "" ]]; then y="00:$y"; fi; 
        if ((j <= 1)); 
        then 
          j+=1; 
        else 
          if (($(bc <<< "30.0 > $x"))); 
          then 
            echo "$x  $y  $i sec @ < 30.00 Kbps  $maxtime $limitword   $(date +"%r")"; 
            if ((i < 270)); 
            then 
              beep -f 300; 
            elif [[ $maxtime == "report" ]]; 
            then
              beep -f 300; 
            elif ((i < 300)); 
            then
              beep -f 600; 
            else 
              echo "CONNECTION ENDED: continuously low bitrate in (< 30.00 Kbps) for 5 min"; 
              killall -s 2 wvdial; 
              beep -f 800 -l 200 -r 50 -d 400; # 0.5 min = 600 ms x 50 / 60 of beeping
              exit 5; 
            fi; 
            i+=1; 
          else 
            i=1; 
            echo "$x  $y                        $maxtime $limitword   $(date +"%r")"; 
          fi; 
          if [[ ! $maxtime == "report" &&  ! $maxtime == "no time" && $y > $maxtime || $y = $maxtime ]]; 
          then 
            echo "CONNECTION ENDED: time limit $maxtime" reached; 
            killall -s 2 wvdial; 
            beep -f 800 -l 200 -r 50 -d 400; # 0.5 min = 600 ms x 50 / 60 of beeping
            exit 4; 
          fi; 
        fi; 
      done; 
      exit 2; 
    }; 
  }
