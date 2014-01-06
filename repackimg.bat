@echo off
set CYGWIN=nodosfilewarning
set hideErrors=n

cd "%~p0"
if not exist split_img\nul goto nofiles
set bin=AIKbuildTools
set "args=%*"
set "errout= "
if "%hideErrors%" == "y" set "errout=2>nul"
if "%args%" == "--original" set "args=-o"

echo Android Image Kitchen - RepackImg Script
echo by osm0sis @ xda-developers
echo.

if not exist *-new.* goto nowarning
echo Warning: Overwriting existing files!
echo.

:nowarning
del ramdisk-new.cpio* 2>nul
if "%args%" == "-o" echo Repacking with original ramdisk . . . & goto skipramdisk
echo Packing ramdisk . . .
echo.
for /f "delims=" %%a in ('dir /b split_img\*-ramdiskcomp') do @set ramdiskcname=%%a
for /f "delims=" %%a in ('type "split_img\%ramdiskcname%"') do @set ramdiskcomp=%%a
echo Using compression: %ramdiskcomp%
if "%ramdiskcomp%" == "gzip" set "repackcmd=gzip" & set "compext=gz"
if "%ramdiskcomp%" == "lzop" set "repackcmd=lzop" & set "compext=lzo"
if "%ramdiskcomp%" == "lzma" set "repackcmd=xz -Flzma" & set "compext=lzma"
if "%ramdiskcomp%" == "xz" set "repackcmd=xz -1 -Ccrc32" & set "compext=xz"
if "%ramdiskcomp%" == "bzip2" set "repackcmd=bzip2" & set "compext=bz2"
if "%ramdiskcomp%" == "lz4" set "repackcmd=lz4 stdin stdout 2>nul" & set "compext=lz4"
%bin%\mkbootfs ramdisk %errout% | %bin%\%repackcmd% %errout% > ramdisk-new.cpio.%compext%
if errorlevel == 1 goto error
:skipramdisk
echo.

echo Getting build information . . .
echo.
for /f "delims=" %%a in ('dir /b split_img\*-zImage') do @set kernel=%%a
echo kernel = %kernel%
for /f "delims=" %%a in ('dir /b split_img\*-ramdisk.cpio*') do @set ramdisk=%%a
if "%args%" == "-o" echo ramdisk = %ramdisk% & set "ramdisk=--ramdisk "split_img/%ramdisk%""
for /f "delims=" %%a in ('dir /b split_img\*-cmdline') do @set cmdname=%%a
for /f "delims=" %%a in ('type "split_img\%cmdname%"') do @set cmdline=%%a
echo cmdline = %cmdline%
for /f "delims=" %%a in ('dir /b split_img\*-base') do @set basename=%%a
for /f "delims=" %%a in ('type "split_img\%basename%"') do @set base=%%a
echo base = %base%
for /f "delims=" %%a in ('dir /b split_img\*-pagesize') do @set pagename=%%a
for /f "delims=" %%a in ('type "split_img\%pagename%"') do @set pagesize=%%a
echo pagesize = %pagesize%
for /f "delims=" %%a in ('dir /b split_img\*-kerneloff') do @set koffname=%%a
for /f "delims=" %%a in ('type "split_img\%koffname%"') do @set kerneloff=%%a
echo kernel_offset = %kerneloff%
for /f "delims=" %%a in ('dir /b split_img\*-ramdiskoff') do @set roffname=%%a
for /f "delims=" %%a in ('type "split_img\%roffname%"') do @set ramdiskoff=%%a
echo ramdisk_offset = %ramdiskoff%
for /f "delims=" %%a in ('dir /b split_img\*-tagsoff') do @set toffname=%%a
for /f "delims=" %%a in ('type "split_img\%toffname%"') do @set tagsoff=%%a
echo tags_offset = %tagsoff%
if not exist "split_img\*-second" goto skipsecond
for /f "delims=" %%a in ('dir /b split_img\*-second') do @set second=%%a
echo second = %second% & set "second=--second "split_img/%second%""
for /f "delims=" %%a in ('dir /b split_img\*-secondoff') do @set soffname=%%a
for /f "delims=" %%a in ('type "split_img\%soffname%"') do @set secondoff=%%a
echo second_offset = %secondoff% & set "second_offset=--second_offset %secondoff%"
:skipsecond
if not exist "split_img\*-dtb" goto skipdtb
for /f "delims=" %%a in ('dir /b split_img\*-dtb') do @set dtb=%%a
echo dtb = %dtb% & set "dtb=--dt "split_img/%dtb%""
:skipdtb
echo.

echo Building image . . .
echo.
if not "%args%" == "-o" set "ramdisk=--ramdisk ramdisk-new.cpio.%compext%"
if not "%cmdline%" == "" set "cmdline=--cmdline '%cmdline%'"
%bin%\mkbootimg --kernel "split_img/%kernel%" %ramdisk% %second% %cmdline% --base %base% --pagesize %pagesize% --kernel_offset %kerneloff% --ramdisk_offset %ramdiskoff% %second_offset% --tags_offset %tagsoff% %dtb% -o image-new.img %errout%
if errorlevel == 1 goto error

echo Done!
goto end

:nofiles
echo No files found to be packed/built.

:error
echo Error!

:end
echo.
pause
