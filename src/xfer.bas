   10REM $Id: xfer.bas,v 1.10 2005/01/22 12:36:45 jon Exp $
   20REM ***************************************
   30REM * Xfer/BBC                            *
   40REM * BBC <-> PC Serial Transfer program  *
   50REM * BBC End (Slave)                     *
   60REM * (c) Mark de Weger, 1996-1997        *
   70REM * (c) Angus Duggan, 1999              *
   80REM * (c) Jon Welch, 2005                 *
   90REM ***************************************
  100:
  110:
  120REM *****************
  130REM Main program
  140REM *****************
  150:
  160REM Initialisation
  170PROCreset
  180REM Clear serial port buffers
  190*FX 21,1
  200*FX 21,2
  210MODE 7
  220ON ERROR PROCfatal_error
  230PROCsetvars
  240PROCassemble
  250PROCinitconnection
  260PROCmain
  270END
  280:
  290REM Main procedure
  300DEF PROCmain
  310REM Switch RS423 Escape off
  320*FX 181,1
  330REM Switch RS423 Printer selection off
  340*FX 5,0
  350REM Switch RS423 Output off
  360*FX 3,0
  370REM Switch output to printer off
  380VDU 3
  390REPEAT
  400REM Switch RS423 Output off
  410*FX 3,0
  420PROCstatus("waiting for command","",0)
  430g$=GET$
  440IF (g$="*") OR (g$="S") OR (g$="R") OR (g$="I") OR (g$="X") THEN name$=FNread_string
  450IF g$="*" THEN PROCoscli(name$)
  460IF g$="S" THEN PROCsendfile(name$)
  470IF g$="X" THEN PROCsendcrc(name$)
  480IF g$="I" THEN PROCsendinf(name$)
  490IF g$="R" THEN PROCreceivefile(name$)
  500IF g$="T" THEN PROCtermemu
  510REM C: command to send current directory name (before transfer of file)
  520IF g$="C" THEN PROCsenddir
  530REM B: command to send current boot option
  540IF g$="B" THEN PROCsendboot
  550REM D: command to receive and set boot option
  560IF g$="F" THEN PROCreceiveboot
  570REM N: command to send disc size
  580IF g$="N" THEN PROCsendsize
  590REM G: command to send disc sectors
  600IF g$="G" THEN PROCsendtrack
  610REM g: command to write DFS disc track
  620IF g$="g" THEN PROCwriteDFStrack
  630REM A: command to send ADFS disc sectors
  640IF g$="A" THEN PROCsendADFStrack
  641REM a: command to write ADFS disc sectors
  642IF g$="a" THEN PROCwriteADFStrack
  650UNTIL g$="Q" OR g$="E"
  660:
  670REM Quit
  680PROCreset
  690REM Clear RS423 input buffer
  700*FX 21,1
  710IF g$="Q" THEN PROCstatus("quitting XFER","",0) ELSE PROCstatus("error at PC; quitting XFER","",0)
  720END
  730:
  740:
  750REM ******************
  760REM Oscli command
  770REM ******************
  780:
  790REM Carry out * command
  800DEF PROCoscli(oscli$)
  810REM Switch output to printer on (*FX 3,3 doesn't work for *-commands)
  820VDU 2
  830REM Select RS423 for printer output
  840*FX 5,2
  850ON ERROR PROCallowed_error(err_txt$)
  860OSCLI(oscli$)
  870ON ERROR PROCfatal_error
  880PRINT sync_text$
  890REM Switch output to printer off
  900VDU 3
  910REM Deselect RS423 for printer output
  920*FX 5,0
  930ENDPROC
  940:
  950:
  960REM ******************
  970REM Send files to PC
  980REM ******************
  990:
 1000REM Send file
 1010DEF PROCsendfile(f$)
 1020ON ERROR PROCallowed_error(err_txt$):ENDPROC
 1030fh%=OPENIN(f$)
 1040REM Print string to show OPENIN went well
 1050*FX 3,3
 1060PRINT sync_text$
 1070ON ERROR PROCallowed_error(""):ENDPROC
 1080REM If file does not exist: send 0 to pc
 1090PROCwrite_integer(fh%)
 1100*FX 3,0
 1110ON ERROR PROCfatal_error
 1120IF fh%=0 THEN ENDPROC
 1130ON ERROR PROCallowed_error(""):ENDPROC
 1140fs%=EXT#fh%
 1150PROCstatus("sending file",f$,fs%)
 1160REM Select serial port for output
 1170*FX 3,3
 1180REM Send file size
 1190PROCwrite_integer(fs%)
 1200REM Send file contents
 1210crc2%=FNsfc(fh%,fs%)
 1220CLOSE#fh%
 1230REM Send CRC
 1240PROCwrite_integer(crc2%)
 1250ON ERROR PROCfatal_error
 1260REM Select VDU for output
 1270*FX 3,0
 1280ENDPROC
 1290:
 1300REM Send file contents
 1310DEF FNsfc(fh%,fs%)
 1320REM Initialise
 1330!crc%=0
 1340?pblock%=fh%
 1350!filelength%=fs%
 1360REM Do it
 1370CALL sendfile
 1380=!crc%
 1390:
 1400REM Send CRC
 1410DEF PROCsendcrc(f$)
 1420ON ERROR PROCallowed_error(err_txt$):ENDPROC
 1430fh%=OPENIN(f$)
 1440REM Print string to show OPENIN went well
 1450*FX 3,3
 1460PRINT sync_text$
 1470ON ERROR PROCallowed_error(""):ENDPROC
 1480REM If file does not exist: send 0 to pc
 1490PROCwrite_integer(fh%)
 1500*FX 3,0
 1510ON ERROR PROCfatal_error
 1520IF fh%=0 THEN ENDPROC
 1530ON ERROR PROCallowed_error(""):ENDPROC
 1540fs%=EXT#fh%
 1550PROCstatus("calculating CRC",f$,0)
 1560REM disable VDU and printer driver
 1570*FX 3,6
 1580REM Send file contents to null
 1590crc2%=FNsfc(fh%,fs%)
 1600CLOSE#fh%
 1610REM Select serial port for output
 1620*FX 3,3
 1630REM Send CRC
 1640PROCwrite_integer(crc2%)
 1650ON ERROR PROCfatal_error
 1660REM Select VDU for output
 1670*FX 3,0
 1680ENDPROC
 1690:
 1700REM Send .inf file
 1710DEF PROCsendinf(f$)
 1720REM Osfile 5: reads file's catalog info
 1730$nblock%=f$
 1740?pblock%=nblock% MOD 256
 1750pblock%?1=nblock% DIV 256
 1760X%=pblock% MOD 256
 1770Y%=pblock% DIV 256
 1780A%=5
 1790ON ERROR PROCallowed_error(err_txt$):ENDPROC
 1800type%=USR osfile% AND 255
 1810ON ERROR PROCfatal_error
 1820load%=pblock%!2
 1830exec%=pblock%!6
 1840length%=pblock%!&0A
 1850attr%=pblock%!&0E
 1860*FX 3,3
 1870PRINT f$;" ";~load%;" ";~exec%;" ";~length%;" ";~attr%;" ";type%
 1880*FX 3,0
 1890ENDPROC
 1900:
 1910:
 1920REM **********************
 1930REM Receive files from PC
 1940REM **********************
 1950:
 1960REM Receive file
 1970DEF PROCreceivefile(f$)
 1980REM Receive file attributes+length
 1990start%=FNread_integer
 2000exec%=FNread_integer
 2010length%=FNread_integer
 2020attr%=FNread_integer
 2030PROCstatus("receiving file",f$,length%)
 2040ON ERROR PROCallowed_error(err_txt$):ENDPROC
 2050fh%=OPENOUT(f$)
 2060REM Print string to show OPENOUT went well
 2070*FX 3,3
 2080PRINT sync_text$
 2090*FX 3,0
 2100REM Receive file contents
 2110crc2%=FNrfc(fh%,length%)
 2120CLOSE#fh%
 2130REM IF crc2%=-1 THEN ENDPROC
 2140crcrec%=FNread_integer
 2150REM Tell pc if crc error
 2160*FX 3,3
 2170IF crcrec%<>crc2% THEN PRINT err_txt2$:ENDPROC ELSE PRINT sync_text$
 2180*FX 3,0
 2190REM Osfile 1: set file attributes
 2200$nblock%=f$
 2210?pblock%=nblock% MOD 256
 2220pblock%?1=nblock% DIV 256
 2230pblock%!2=start%
 2240pblock%!6=exec%
 2250pblock%!&0A=length%
 2260pblock%!&0E=attr%
 2270X%=pblock% MOD 256
 2280Y%=pblock% DIV 256
 2290A%=1
 2300CALL osfile%
 2310ON ERROR PROCfatal_error
 2320REM Print string to show receive went well
 2330*FX 3,3
 2340PRINT sync_text$
 2350*FX 3,0
 2360ENDPROC
 2370:
 2380REM Receive file contents
 2390DEF FNrfc(fh%,fs%)
 2400REM Initialise
 2410!crc%=0
 2420!filelength%=fs%
 2430?pblock%=fh%
 2440REM Do it
 2450CALL receivefile
 2460=!crc%
 2470:
 2480:
 2490REM ****************************
 2500REM Terminal emulation
 2510REM ****************************
 2520:
 2530REM Start terminal emulation
 2540DEF PROCtermemu
 2550PROCstatus("terminal emulation","",0)
 2560REM Select RS423 as printer (*FX 3,3 doesn't work for *-commands)
 2570*FX 5,2
 2580REM Switch output to printer on
 2590VDU 2
 2600REM Enable RS423 Escape
 2610*FX 181,0
 2620END
 2630ENDPROC
 2640:
 2650:
 2660REM ****************************
 2670REM Send current directory name
 2680REM ****************************
 2690:
 2700DEF PROCsenddir
 2710dir$=FNgetcurrentdir
 2720REM Switch RS423 output on
 2730*FX3,3
 2740PRINT dir$
 2750REM Switch RS423 output off
 2760*FX3,0
 2770ENDPROC
 2780:
 2790REM ****************************
 2800REM Send size of disc
 2810REM ****************************
 2820:
 2830REM Send disc size
 2840DEF PROCsendsize
 2850ON ERROR PROCallowed_error(err_txt$):ENDPROC
 2860X%=pblock% MOD 256
 2870Y%=pblock% DIV 256
 2880A%=&7E
 2890CALL osword%
 2900ON ERROR PROCfatal_error
 2910REM Switch on RS423 output
 2920*FX3,3
 2930PROCwrite_integer(!pblock%)
 2940REM Switch RS423 output off
 2950*FX3,0
 2960ENDPROC
 2970:
 2980:
 2990REM ****************************
 3000REM 8271 read track
 3010REM ****************************
 3020:
 3030REM Send read track and perform CRC
 3040DEF PROCsendtrack
 3050?pblock%=FNread_integer
 3060pblock%!1=buffer%
 3070pblock%?7=FNread_integer
 3080!crc%=0
 3090PROCstatus("sending drive "+STR$(?pblock%)+" track "+STR$(pblock%?7),"",0)
 3100REM Switch on RS423 output
 3110*FX3,3
 3120ON ERROR PROCallowed_error("")
 3130CALL readtrack%
 3140IF ?pblock%<>0 THEN PRINT err_txt2$ ELSE PROCwrite_integer(!crc%)
 3150ON ERROR PROCfatal_error
 3160REM Switch off RS423 output
 3170*FX3,0
 3180ENDPROC
 3190:
 3200:
 3210REM ****************************
 3220REM 8271 write DFS track
 3230REM ****************************
 3240:
 3250REM Write track and perform CRC
 3260DEF PROCwriteDFStrack
 3270?pblock%=FNread_integer
 3280pblock%!1=buffer%
 3290pblock%?7=FNread_integer
 3300!crc%=0
 3310PROCstatus("writing drive "+STR$(?pblock%)+" track "+STR$(pblock%?7),"",0)
 3320ON ERROR PROCallowed_error("")
 3330REM Print string to show ready to receive track
 3340*FX 3,3
 3350PRINT sync_text$
 3360*FX 3,0
 3370CALL writeDFStrack%
 3380REM Send crc to pc
 3390*FX 3,3
 3400IF ?pblock%<>0 THEN PRINT err_txt2$ ELSE PROCwrite_integer(!crc%)
 3410ON ERROR PROCfatal_error
 3420REM Switch off RS423 output
 3430*FX3,0
 3440ENDPROC
 3450:
 3460:
 3470REM ****************************
 3480REM 1770 read ADFS track
 3490REM ****************************
 3500:
 3510REM Send read track and perform CRC
 3520DEF PROCsendADFStrack
 3530pblock%?0=0
 3540pblock%!1=buffer%
 3550pblock%?5=8
 3560pblock%?6=FNread_integer*32
 3570T%=FNread_integer
 3580S%=T% * 16
 3590pblock%?7=(S% DIV 256) MOD 256
 3600pblock%?8=S% MOD 256
 3610pblock%?9=16
 3620!crc%=0
 3630PROCstatus("sending drive "+STR$(?pblock%)+" track "+STR$(T%),"",0)
 3640REM Switch on RS423 output
 3650*FX3,3
 3660ON ERROR PROCallowed_error("")
 3670CALL readADFStrack%
 3680IF ?pblock%<>0 THEN PRINT err_txt2$ ELSE PROCwrite_integer(!crc%)
 3690ON ERROR PROCfatal_error
 3700REM Switch off RS423 output
 3710*FX3,0
 3720ENDPROC
 3721:
 3722:
 3723REM ****************************
 3724REM 1770 write ADFS track
 3725REM ****************************
 3726:
 3727REM Write track and perform CRC
 3728DEF PROCwriteADFStrack
 3729pblock%?0=0
 3730pblock%!1=buffer%
 3731pblock%?5=10
 3732pblock%?6=FNread_integer*32
 3733T%=FNread_integer
 3734S%=T% * 16
 3735pblock%?7=(S% DIV 256) MOD 256
 3736pblock%?8=S% MOD 256
 3737pblock%?9=16
 3738!crc%=0
 3739PROCstatus("writing drive "+STR$(?pblock%)+" track "+STR$(T%),"",0)
 3740ON ERROR PROCallowed_error("")
 3741REM Print string to show ready to receive track
 3742*FX 3,3
 3743PRINT sync_text$
 3744*FX 3,0
 3745CALL writeADFStrack%
 3746REM Send crc to pc
 3747*FX 3,3
 3748IF ?pblock%<>0 THEN PRINT err_txt2$ ELSE PROCwrite_integer(!crc%)
 3749ON ERROR PROCfatal_error
 3750REM Switch off RS423 output
 3751*FX3,0
 3752ENDPROC
 3753:
 3754:
 3755REM ****************************
 3760REM Send set/get boot option
 3770REM ****************************
 3780:
 3790REM Send !BOOT option
 3800DEF PROCsendboot
 3810REM Osgbpb 5: read boot option
 3820ON ERROR PROCallowed_error(err_txt$)
 3830pblock%!1=nblock%
 3840X%=pblock% MOD 256
 3850Y%=pblock% DIV 256
 3860A%=5
 3870CALL osgbpb%
 3880ON ERROR PROCfatal_error
 3890*FX 3,3
 3900PROCwrite_integer(?(nblock%+?nblock%+1))
 3910*FX 3,0
 3920ENDPROC
 3930:
 3940REM Receive and set !BOOT option
 3950DEF PROCreceiveboot
 3960REM Osbyte 139: *OPT X%,Y%
 3970Y%=FNread_integer
 3980X%=4
 3990A%=139
 4000ON ERROR PROCallowed_error(err_txt$)
 4010CALL osbyte%
 4020ON ERROR PROCfatal_error
 4030*FX 3,3
 4040PRINT sync_text$
 4050*FX 3,0
 4060ENDPROC
 4070:
 4080:
 4090REM ****************************
 4100REM Initialisation/error/status
 4110REM ****************************
 4120:
 4130REM Initialise and check connection
 4140DEF PROCinitconnection
 4150PROCstatus("Waiting for connection","",0)
 4160REM 1200 Baud RS423 Receiving
 4170*FX 7,4
 4180REM Receive from RS423
 4190*FX 2,1
 4200REM Test connection
 4210text$=FNread_string
 4220IF text$<>sync_text$ THEN PROCreset:PRINT "Invalid data received. Please try again.":END
 4230REM Get protocol version
 4240p%=FNread_integer
 4250IF p%<>protocol% THEN PROCreset:PRINT "Incompatible XFer protocol version"'"Received ";p%;" required ";protocol%:END
 4260REM Get baud rate and set it
 4270x%=FNread_integer
 4280PRINT
 4290PRINT "Initializing at ";STR$(x%);" baud."
 4300PRINT
 4310REM Osbyte 7: set RS423 receiving speed
 4320IF x%=1200 THEN X%=4
 4330IF x%=2400 THEN X%=5
 4340IF x%=4800 THEN X%=6
 4350IF x%=9600 THEN X%=7
 4360IF x%=19200 THEN X%=8
 4370A%=7
 4380CALL osbyte%
 4390REM Osbyte 8: set RS423 sending speed
 4400A%=8
 4410CALL osbyte%
 4420ENDPROC
 4430:
 4440REM Initialise variables
 4450DEF PROCsetvars
 4460DIM pblock% &11
 4470DIM nblock% 256
 4480osbyte%=&FFF4
 4490osword%=&FFF1
 4500oscli%=&FFF7
 4510osfile%=&FFDD
 4520osgbpb%=&FFD1
 4530oswrch%=&FFEE
 4540sync_text$="-----BBC-----PC-----"
 4550err_txt$="-----BBCerror1-----PC-----"
 4560err_txt2$="-----BBCerror2-----PC-----"
 4570@%=&90A
 4580REM Variables for mc
 4590bufsize%=4096
 4600crc%=&70
 4610filelength%=&74
 4620bufptr%=&78
 4630buflen%=&7A
 4640bufidx%=&7B
 4650protocol%=100001
 4660ENDPROC
 4670:
 4680REM Print status of connection
 4690DEF PROCstatus(status$,file$,length%)
 4700CLS
 4710PRINT CHR$141;"XFER/BBC"
 4720PRINT CHR$141;"XFER/BBC"
 4730PRINT
 4740PRINT "(c) 1996 Mark de Weger"
 4750PRINT "    1999 Angus Duggan"
 4760PRINT "    2005 Jon Welch"
 4770PRINT
 4780PRINT ""
 4790PRINT "Status: ";status$
 4800IF file$<>"" THEN PRINT "  File name: ";file$
 4810IF length%<>0 THEN PRINT "  File length: ";STR$(length%)
 4820PRINT ""
 4830ENDPROC
 4840:
 4850REM Reset RS423
 4860DEF PROCreset
 4870ON ERROR OFF
 4880REM Close serial port and reselect keyboard input
 4890*FX 2,0
 4900REM Flush serial port input buffer
 4910*FX 21,1
 4920REM Reselect VDU output
 4930*FX 3,0
 4940REM Deselect RS423 as printer destination
 4950*FX 5,0
 4960REM Switch printer output off
 4970VDU 3
 4980REM Close remaining open files
 4990CLOSE#0
 5000PRINT ""
 5010ENDPROC
 5020:
 5030REM Fatal error
 5040DEF PROCfatal_error
 5050PROCreset
 5060REPORT
 5070PRINT " at line ";ERL
 5080END
 5090ENDPROC
 5100:
 5110:
 5120REM ********************
 5130REM RS423 Utilities
 5140REM ********************
 5150:
 5160REM Read string
 5170DEF FNread_string
 5180LOCAL string$,g$
 5190string$=""
 5200REPEAT
 5210g$=GET$
 5220REM IF ASC(g$)<32 THEN PRINT "~ ";~ASC(g$);" "; ELSE PRINT g$;" ";~ASC(g$);" ";
 5230IF g$<>CHR$(13) THEN string$=string$+g$
 5240UNTIL g$=CHR$(13)
 5250PRINT 'string$
 5260=string$
 5270:
 5280REM Read integer
 5290DEF FNread_integer
 5300LOCAL s$
 5310s$=FNread_string
 5320=VAL(s$)
 5330:
 5340REM Write integer
 5350DEF PROCwrite_integer(i%)
 5360LOCAL s$
 5370s$=STR$(i%)
 5380PRINT s$
 5390ENDPROC
 5400:
 5410:
 5420REM ********************
 5430REM Other utilities
 5440REM ********************
 5450:
 5460REM Get current directory name
 5470DEF FNgetcurrentdir
 5480LOCAL s$,dir%,index%
 5490REM Osgbpb 6: read directory (and device)
 5500pblock%!1=nblock%
 5510X%=pblock% MOD 256
 5520Y%=pblock% DIV 256
 5530A%=6
 5540CALL osgbpb%
 5550dir%=nblock%+?nblock%+1
 5560IF ?dir%=0 THEN =""
 5570FOR index%=1 TO ?dir%
 5580s$=s$+CHR$(dir%?index%)
 5590NEXT
 5600=s$
 5610:
 5620REM Error to be trapped
 5630DEF PROCallowed_error(pc$)
 5640ON ERROR PROCfatal_error
 5650REM Close open files
 5660CLOSE#0
 5670REM Switch off RS423 output
 5680*FX 3,0
 5690REM De-select RS423 printer
 5700*FX 5,0
 5710REM Switch output to printer off
 5720VDU 3
 5730REM Switch RS423 Escape off
 5740*FX 181,1
 5750PROCstatus("error, waiting for PC to respond","",0)
 5760REM Switch on RS423 output
 5770*FX 3,3
 5780REM Print string to tell PC of error
 5790IF pc$<>"" THEN PRINT pc$
 5800REM Wait for pc to respond acknowledgement of error
 5810pc$=""
 5820REPEAT
 5830g$=GET$
 5840IF g$<>"" THEN pc$=pc$+g$ ELSE pc$=""
 5850IF LEN(pc$)>LEN(err_txt$) THEN pc$=RIGHT$(pc$,LEN(pc$)-1)
 5860UNTIL pc$=err_txt$
 5870REM Send error to PC
 5880REPORT
 5890PRINT
 5900REM Switch off RS423 output
 5910*FX 3,0
 5920PROCmain
 5930:
 5940:
 5950REM ***********************
 5960REM Machine code generation
 5970REM ***********************
 5980:
 5990DEF PROCassemble
 6000DIM mc% 600
 6010DIM buffer% bufsize%
 6020FOR opt%=0 TO 2 STEP 2
 6030P%=mc%
 6040[
 6050OPT opt%
 6060\
 6070\ Receive file
 6080.receivefile
 6090\ WHILE !filelength%<>0
 6100CLC
 6110LDA filelength%+3
 6120BMI recvexit
 6130ORA filelength%+2
 6140ORA filelength%+1
 6150ORA filelength%
 6160BEQ recvexit
 6170\ set up OSGBPB pointers
 6180JSR setsize
 6190\ receive block of data from RS423
 6200\ *bufptr%=buffer%
 6210LDA #buffer% MOD 256
 6220STA bufptr%
 6230LDA #buffer% DIV 256
 6240STA bufptr%+1
 6250\ *buflen%=-pblock%!5
 6260SEC
 6270LDA #0
 6280SBC pblock%+5
 6290STA buflen%
 6300LDA #0
 6310SBC pblock%+6
 6320STA buflen%+1
 6330\
 6340.recvblock
 6350\ Y%=get from RS423 input buffer
 6360LDA #145
 6370LDX #1
 6380JSR osbyte%
 6390\ keep trying until got a byte (should put a timeout here)
 6400BCS recvblock
 6410TYA
 6420LDX #0
 6430STA (bufptr%,X)
 6440JSR crccalc
 6450INC bufptr%
 6460BNE recvnext
 6470INC bufptr%+1
 6480.recvnext
 6490INC buflen%
 6500BNE recvblock
 6510INC buflen%+1
 6520BNE recvblock
 6530\ save received block to file
 6540LDA #2
 6550LDX #pblock% MOD 256
 6560LDY #pblock% DIV 256
 6570JSR osgbpb%
 6580BCC receivefile
 6590.recvexit
 6600RTS
 6610\
 6620\ Send file
 6630.sendfile
 6640\ WHILE !filelength%<>0
 6650CLC
 6660LDA filelength%+3
 6670BMI sendexit
 6680ORA filelength%+2
 6690ORA filelength%+1
 6700ORA filelength%
 6710BEQ sendexit
 6720\ set up OSGBPB pointers
 6730JSR setsize
 6740\ load block from disc using OSGBPB
 6750LDA #4
 6760LDX #pblock% MOD 256
 6770LDY #pblock% DIV 256
 6780JSR osgbpb%
 6790\ if read is too short, quit
 6800BCS sendexit
 6810\ send block to pc and calculate crc
 6820\ *bufptr%=buffer%
 6830LDA #buffer% MOD 256
 6840STA bufptr%
 6850LDA #buffer% DIV 256
 6860STA bufptr%+1
 6870\ *buflen%=pblock%!1-buffer%
 6880SEC
 6890LDA pblock%+1
 6900SBC #buffer% MOD 256
 6910STA buflen%
 6920LDA pblock%+2
 6930SBC #buffer% DIV 256
 6940STA buflen%+1
 6950LDY #0
 6960.sbloop
 6970\ VDU ?(bufptr%)
 6980LDA (bufptr%),Y
 6990JSR oswrch%
 7000JSR crccalc
 7010INY
 7020BNE sbnext
 7030INC bufptr%+1
 7040DEC buflen%+1
 7050BNE sbloop
 7060.sbnext
 7070CPY buflen%
 7080BNE sbloop
 7090LDA buflen%+1
 7100BNE sbloop
 7110JMP sendfile
 7120.sendexit
 7130RTS
 7140\
 7150\ Merge accumulator into CRC. Invalidates A,X,P
 7160.crccalc
 7170EOR crc%+3
 7180STA crc%+3
 7190LDX #8
 7200.crcloop
 7210LDA crc%+3
 7220ROL A
 7230BCC crcclear
 7240LDA crc%
 7250EOR #&57
 7260STA crc%
 7270.crcclear
 7280ROL crc%
 7290ROL crc%+1
 7300ROL crc%+2
 7310ROL crc%+3
 7320DEX
 7330BNE crcloop
 7340RTS
 7350\
 7360\ 1770 command read ADFS track of data info buffer, and calculate CRC
 7370.readADFStrack%
 7380LDX #pblock% MOD 256
 7390LDY #pblock% DIV 256
 7400LDA #&72
 7410JSR osword%
 7420LDA pblock%+0
 7430BNE trackdone
 7440STA pblock%+10
 7450LDA #16
 7460STA buflen%
 7470JMP xfertrack
 7480\
 7490\ 8271 command read track of data info buffer, and calculate CRC
 7500.readtrack%
 7510LDA #1
 7520STA pblock%+5
 7530LDA #&69
 7540STA pblock%+6
 7550LDX #pblock% MOD 256
 7560LDY #pblock% DIV 256
 7570LDA #&7F
 7580JSR osword%
 7590LDA pblock%+8
 7600BNE trackdone
 7610LDA #3
 7620STA pblock%+5
 7630LDA #&53:\ read multiple sectors
 7640STA pblock%+6
 7650LDA #0
 7660STA pblock%+8
 7670LDA #&2A
 7680STA pblock%+9
 7690LDX #pblock% MOD 256
 7700LDY #pblock% DIV 256
 7710LDA #&7F
 7720JSR osword%
 7730LDA pblock%+10
 7740BNE trackdone
 7750LDA #10
 7760STA buflen%
 7770.xfertrack
 7780LDA #buffer% MOD 256
 7790STA bufptr%
 7800LDA #buffer% DIV 256
 7810STA bufptr%+1
 7820LDY #0
 7830.trackcrc
 7840LDA (bufptr%),Y
 7850JSR oswrch%
 7860JSR crccalc
 7870INY
 7880BNE trackcrc
 7890INC bufptr%+1
 7900DEC buflen%
 7910BNE trackcrc
 7920LDA pblock%+10
 7930.trackdone
 7940STA pblock%
 7950RTS
 7960\
 7970\ set buffer and size pointers for OSGBPB in pblock
 7980.setsize
 7990\ pblock%!1=buffer%
 8000LDA #buffer% MOD 256
 8010STA pblock%+1
 8020LDA #buffer% DIV 256
 8030STA pblock%+2
 8040LDA #0
 8050STA pblock%+3
 8060STA pblock%+4
 8070\ pblock%!5=filelength%:\ filelength%=filelength%-bufsize%
 8080SEC
 8090LDA filelength%
 8100STA pblock%+5
 8110SBC #bufsize% MOD 256
 8120STA filelength%
 8130LDA filelength%+1
 8140STA pblock%+6
 8150SBC #bufsize% DIV 256
 8160STA filelength%+1
 8170LDA filelength%+2
 8180STA pblock%+7
 8190SBC #0
 8200STA filelength%+2
 8210LDA filelength%+3
 8220STA pblock%+8
 8230SBC #0
 8240STA filelength%+3
 8250BCC donesize
 8260\ IF pblock%!5 >= bufsize% THEN pblock%!5=bufsize%
 8270LDA #bufsize% MOD 256
 8280STA pblock%+5
 8290LDA #bufsize% DIV 256
 8300STA pblock%+6
 8310LDA #0
 8320STA pblock%+7
 8330STA pblock%+8
 8340.donesize
 8350RTS
 8360\
 8370\ Receive a DFS track and write to disc
 8380.writeDFStrack%
 8390LDA #10
 8400STA buflen%
 8410JSR rcvtrack%
 8420\ Seek track
 8430LDA #1
 8440STA pblock%+5
 8450LDA #&69
 8460STA pblock%+6
 8470LDX #pblock% MOD 256
 8480LDY #pblock% DIV 256
 8490LDA #&7F
 8500JSR osword%
 8510LDA pblock%+8
 8520BNE write1
 8530LDA #3
 8540STA pblock%+5
 8550LDA #&4B:\ write multiple sectors
 8560STA pblock%+6
 8570LDA #0
 8580STA pblock%+8
 8590LDA #&2A
 8600STA pblock%+9
 8610LDX #pblock% MOD 256
 8620LDY #pblock% DIV 256
 8630LDA #&7F
 8640JSR osword%
 8650LDA pblock%+10
 8660.write1
 8670STA pblock%
 8680RTS
 8690\
 8700\ Receive a track
 8710.rcvtrack%
 8720LDA #buffer% MOD 256
 8730STA bufptr%
 8740LDA #buffer% DIV 256
 8750STA bufptr%+1
 8760LDY #0
 8770STY bufidx%
 8780.rcvt1
 8790\ Y%=get from RS423 input buffer
 8800LDA #145
 8810LDX #1
 8820JSR osbyte%
 8830\ keep trying until got a byte (should put a timeout here)
 8840BCS rcvt1
 8850TYA
 8860LDY bufidx%
 8870STA (bufptr%),Y
 8880JSR crccalc
 8890INY
 8900STY bufidx%
 8910BNE rcvt1
 8920INC bufptr%+1
 8930DEC buflen%
 8940BNE rcvt1
 8950RTS
 8951\
 8952\ Receive an ADFS track and write to disc
 8953.writeADFStrack%
 8954LDA #16
 8955STA buflen%
 8956JSR rcvtrack%
 8957LDX #pblock% MOD 256
 8958LDY #pblock% DIV 256
 8959LDA #&72
 8960JSR osword%
 8961RTS
 8962]
 8963NEXT
 8964ENDPROC
