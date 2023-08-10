@echo off
echo Assembling...
mos.exe build
if errorlevel 1 goto end
cd target
del keytar.d64
c1541 -format diskname,id d64 keytar.d64 -attach keytar.d64 -write main.prg main
xvic.exe -autostart keytar.d64
:end