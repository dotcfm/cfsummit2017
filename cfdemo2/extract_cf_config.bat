@echo off

set tmpdir=%tmp%\cftmp

echo Extracts ColdFusion configuration files from a Docker container
echo.
set /p container=Container [%container%]: 
set /p cnf=Configuration [%cnf%]: 
echo.
echo This will overwrite/update files in the [%cd%\%cnf%] folder. Ok?
pause

mkdir %tmpdir%
del /s /q %tmpdir% 1>nul

echo Extracting configuration files from [%container%]...
docker cp %container%:/opt/coldfusion2016/cfusion/lib/ %tmpdir%
docker cp %container%:/opt/coldfusion2016/cfusion/lib/adminconfig.xml %tmpdir%
docker cp %container%:/opt/coldfusion2016/cfusion/bin/jvm.config %tmpdir%
docker cp %container%:/opt/coldfusion2016/cfusion/runtime/conf/server.xml %tmpdir%

echo Updating configuration folder...
mkdir %cnf% 2>nul
copy %tmpdir%\lib\neo-*.xml %cnf% 1>nul
copy %tmpdir%\lib\seed.properties %cnf%\seed.properties 1>nul
copy %tmpdir%\adminconfig.xml %cnf%\adminconfig.xml 1>nul
copy %tmpdir%\jvm.config %cnf%\jvm.config 1>nul
copy %tmpdir%\server.xml %cnf%\server.xml 1>nul

rmdir /s /q %tmpdir%

echo Done