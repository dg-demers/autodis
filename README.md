# autodis
a shell script to disconnect from a PPP internet service provider after a maximum connection time or if the incoming bitrate remains continuously below 30.00 Kbps for 5 minutes. It also provides information to the user about the connection such as elapsed time, bitrate, and its consistency.

###  Overview and Motivation  ###
autodis disconnects from a PPP internet service provider after a maximum 
connection time or if the incoming bitrate remains continuously below 
30.00 Kbps for 5 minutes. This is particularly useful for managing 
dial-up connections that are heavily used for automated file downloading 
(with wget, for example) and that are made to ISPs that do not 
automatically disconnect after a time limit or after a period of 
inactivity, but whose terms of service limit daily or monthly connection 
time. autodis also limits unproductive connection time by disconnecting 
from poor quality connections of repeatedly low bitrate due to 
intermittent phone line trouble, slow or failing servers, etc. In 
addition, autodis provides information to the user about a PPP ISP
connection such as the elapsed connection time, the bitrate, and its 
consistency by printing to the terminal window and by beeping the 
speaker. 

###  Command Line Arguments, Modes, and Script-Caused Disconnection  ###
#####  Command Line Arguments Determine Mode #####
autodis takes at most one command line argument. Depending on the 
argument (or its absence) autodis is started in one of three possible 
modes: time limit, no time limit, or report mode. If the argument is a 
time limit in the form HH:MM:SS or MM:SS (not HH:MM as, for example, 
04:39 is interpreted as 00:04:39, rather than 04:39:00), autodis is in 
time limit mode. If there is no command line argument, it is in no time 
limit mode. If the command line argument is the string "report" (without 
quotes), autodis is in report mode.  

#####  Time Limit Disconnection #####
In time limit mode only, if the time since the connection was made (the 
elapsed time that the process pppd which establishes and manages the 
connection has been running) reaches the time limit given on the command 
line, autodis will disconnect. 

#####  Sustained Low Incoming Bitrate Disconnection and Beeps  #####
In all modes, autodis checks the incoming (only, not outgoing or total) 
bitrate once per second. Each time it is low (< 30.00 Kbps), autodis 
gives a short warning beep, initially at the frequency 300 Hz. If 
autodis is not in report mode, after 4.5 minutes of continously low 
incoming bitrate the pitch of the warning beeps jumps up to 600 Hz 
signaling that autodis will disconnect if the low bitrate continues for 
another 30 seconds. (But the user can press CTRL+C to terminate and 
override it.) If it is in report mode, autodis emits its low incoming 
bitrate warning beeps at 300 Hz only and does not disconnect for any 
reason. 

###  Scrolling Terminal Printout  ###
In all modes, autodis prints scrolling lines to the terminal every 
second that show five items: 
1) the incoming bitrate in Kbps (as NN.DD), 
2) the connection elapsed time (as HH:MM:SS), 
3) the number of seconds the incoming bitrate has been continuously less 
   30.00 Kbps (as SS... sec @ < 30.00 Kbps) or filler spaces if 0, 
4) the connection time limit (as HH:MM:SS max) or "no time max" or 
   "report only" depending on the mode, 
5) the regional time (as HH:MM:SS AM/PM). 

###  Disconnection/No Connection: Printout, Beeping, and Exit Codes  ###
#####  End of Existing Connection  #####
In all modes, if and only if an existing connection ends for any reason, autodis 
will print the reason (time limit, continuously low incoming bitrate, or 
connection ended, but not by autodis) the connection ended, then emit 
short 800 Hz beeps once per second for 30 seconds, then exit. 

#####  No Existing Connection at Startup  #####
If there is no existing ISP connection when autodis is started, an exit 
message is printed by the external program autodis uses for monitoring 
the incoming bitrate, ifstat, as "ifstat: no interfaces to monitor!" 
Then autodis exits without beeping. 
(Thus, autodis must be started after the connection is established.) 

#####  Exit/Error Codes  #####
The exit code is   
  1, if the command line arguments are invalid,   
  2, if there was no existing ISP connection when autodis was started,   
  3, if the connection was ended, but not by autodis,   
  4, if the time limit was reached, and   
  5, if the incoming bitrate was continuously low for 5 minutes.   
Exit code 0 is not used. 

###  System Requirements  ###
autodis requires bash, of course, as well as several external processes: beep, pppd, and ifstat. So their 
so- or similar-named packages should be installed and they must be available to be run by the user.

So far busyppp has only been tested with the following software:  
  Debian Stretch (Linux kernel release 4.13.0-1-686-pae)  
  xterm 327-2  
  bash 4.4.12  
  beep 1.3  
  pppd 2.4.7  
  ifstat 1.1 with the compiled-in drivers proc and snmp  

To use autodis you must be connected through pppd (the point-to-point protocol daemon) to your dial-up ISP. Although you may 
never have heard of pppd, you are connecting through it if you have used one of its various GUI or TUI frontends, such as kppp, gnome-ppp, or wvdial, that ultimately employs pppd to make the connection. 

In addition, to hear the helpful beep cues (see the section below with that title) you must set up your system to beep. It seems the default in many Linux distributions is to turn off the ability to beep. To find out how to turn it back on see, for example,  
  https://askubuntu.com/questions/277215/make-a-sound-once-process-is-complete

And beep itself needs to have its suid bit set. See  
  https://github.com/johnath/beep
