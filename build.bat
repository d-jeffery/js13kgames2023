rem TypeScript build script for LittleJS by Frank Force

set NAME=game
set BUILD_FOLDER=build
set BUILD_FILENAME=index.js
set BUILD_ENGINE=./engine/littlejs.esm.js

rem remove old files
del %NAME%.zip
rmdir /s /q %BUILD_FOLDER%

call npx tsc
if %ERRORLEVEL% NEQ 0 (
    pause
    exit /b %ERRORLEVEL%
)

rem copy images to build folder
copy index.html %BUILD_FOLDER%\index.html
copy tiles.png %BUILD_FOLDER%\tiles.png

rem copy engine release build
pushd %BUILD_FOLDER%


rem minify code with closure
move %BUILD_FILENAME% temp_%BUILD_FILENAME%
call npx google-closure-compiler --js=temp_%BUILD_FILENAME% --js=%BUILD_ENGINE% --js_output_file=%BUILD_FILENAME% --compilation_level=ADVANCED --language_out=ECMASCRIPT_2021 --warning_level=VERBOSE --jscomp_off=* --assume_function_wrapper
if %ERRORLEVEL% NEQ 0 (
    pause
    exit /b %ERRORLEVEL%
)
del temp_%BUILD_FILENAME%


rem more minification with uglify
call npx uglifyjs -o %BUILD_FILENAME% --compress --mangle -- %BUILD_FILENAME%
if %ERRORLEVEL% NEQ 0 (
    pause
    exit /b %ERRORLEVEL%
)


rem roadroller compresses the code better then zip
call npx roadroller %BUILD_FILENAME% -o %BUILD_FILENAME%
if %ERRORLEVEL% NEQ 0 (
    pause
    exit /b %ERRORLEVEL%
)


rem build the html, you can add an html header and footer here
rem type ..\header.html >> index.html
echo ^<script^> >> index.html
type %BUILD_FILENAME% >> index.html
echo ^</script^> >> index.html
rem type ..\footer.html >> index.html

rem delete intermediate files
del %BUILD_FILENAME%

rem zip the result, ect is recommended
call ..\node_modules\ect-bin\vendor\win32\ect.exe -9 -strip -zip ..\%NAME%.zip index.html tiles.png
if %ERRORLEVEL% NEQ 0 (
    pause
    exit /b %ERRORLEVEL%
)

popd


