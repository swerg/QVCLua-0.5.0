rd /S /Q .tmp\.zip
md .tmp\.zip\x32-Lua51
md .tmp\.zip\x64-Lua53

copy bin\i386-win32\qvcl.dll .tmp\.zip\x32-Lua51
copy bin\x86_64-win64\qvcl.dll .tmp\.zip\x64-Lua53

copy nul .tmp\.zip\ReadMe.txt
echo ���������� ����������� ���������� QVcl ��� Lua � QUIK. >> .tmp\.zip\ReadMe.txt
echo ��������� ��������: https://quik2dde.ru/viewtopic.php?id=111 >> .tmp\.zip\ReadMe.txt
echo. >> .tmp\.zip\ReadMe.txt
echo \x32-Lua51  -- ��� QUIK 6.x, 7.x >> .tmp\.zip\ReadMe.txt
echo \x64-Lua53  -- ��� QUIK 8.5 � ����� >> .tmp\.zip\ReadMe.txt

cd .tmp\.zip
"C:\Program Files\7-Zip\7z.exe" a -r -tZip ..\..\qvcl.zip *.dll ReadMe.txt
cd ..\..

rd /S /Q .tmp\.zip
