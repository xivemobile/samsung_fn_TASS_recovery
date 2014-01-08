@echo off
bin\tar --group=1 -H ustar -c recovery.img > recovery.tar
bin\md5sum -t recovery.tar >> recovery.tar
bin\mv recovery.tar recovery.tar.md5

@echo Thank me at xda @cabloomi

@echo Info: http://forum.xda-developers.com/showthread.php?t=2281287

pause