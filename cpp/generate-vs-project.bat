@ECHO OFF
chcp 65001
cls
@SETLOCAL
echo "========请先参考README.md准备好编译环境，回车以开始生成========"
pause
set BUILD_TYPE=Release
echo "编译类型: Release"
set BUILD_OUTPUT="BIN"
echo "编译输出类型：exe程序"
set MT_ENABLED="True"
echo "编译CRT类型：MT"
set ONNX_TYPE="CUDA"
echo "Onnx类型：CUDA"
mkdir build-win-vs2022-x64
pushd build-win-vs2022-x64
echo "开始生成VS工程文件"
call :cmakeParams "Visual Studio 17 2022" "x64"
popd
GOTO:EOF

:cmakeParams
echo cmake -G "%~1" -A "%~2" -DOCR_OUTPUT=%BUILD_OUTPUT% -DOCR_BUILD_CRT=%MT_ENABLED% -DOCR_ONNX=%ONNX_TYPE% ..
cmake -G "%~1" -A "%~2" -DOCR_OUTPUT=%BUILD_OUTPUT% -DOCR_BUILD_CRT=%MT_ENABLED% -DOCR_ONNX=%ONNX_TYPE% ..
GOTO:EOF

@ENDLOCAL
