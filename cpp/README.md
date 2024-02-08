# RapidOCR-json 构建指南

本文档帮助如何在 Windows x64 上编译 RapidOCR-json 。

本文参考了 RapidAI 官方的[CPU 版本编译说明](https://github.com/RapidAI/RapidOcrOnnx/blob/main/BUILD.md)，[GPU 版本附加说明](https://github.com/RapidAI/RapidOcrOnnx/blob/main/onnxruntime-gpu/README.md) 。

## 1. 前期准备

资源链接后面的(括弧里是版本)，请看清楚。

### 1.1 需要安装的工具：

- [Visual Studio 2022](https://visualstudio.microsoft.com/zh-hans/vs/) (Community)
- [Cmake](https://cmake.org/download/) (Windows x64 Installer)

## 2. 构建项目

1. 解压 `lib.7z` ，将其中两个文件夹 `onnxruntime-static` 和 `opencv-static` 解压到 `cpp/` 中。（注意，是直接放在 `cpp/opencv-static` ，而不是 `cpp/lib/opencv-static` ！）
2. 动动手指，点击运行 `generate-vs-project.bat` ，静等文件生成。
3. 打开 `build-win-vs2019-x64` ，用 vs2019 打开 `RapidOcrOnnx` 。
4. vs2019 上方控制栏，将 `Debug` 改为 `Release` 。
5. 解决方案资源管理器 → ALL_BUILD → 常规：
   - 输出目录 → 改为 `$(ProjectDir)/Release` 。
   - 目标文件名 → 改为 `RapidOCR-json` 或你喜欢的名字。
6. 解决方案资源管理器 → ALL_BUILD → 调试：
   - 工作目录 → 改为 `$(ProjectDir)/Release` 。
7. 解决方案资源管理器 → ALL_BUILD → 高级：
   - 字符集 → 改为 `使用Unicode字符集` 。应用，关闭此页面。
8. 解决方案资源管理器 → RapidOcrOnnx → 常规：
   - 目标文件名 → 改为 `RapidOCR-json` 或你喜欢的名字。
9. 解决方案资源管理器 → RapidOcrOnnx → 高级：
   - 字符集 → 改为 `使用Unicode字符集` 。应用，关闭此页面。
10. F5 尝试编译。如果有 `成功*个，失败0个……` 那就成功了。如果一个黑窗口一闪而过，那就正常。
11. 项目根目录的 `models.7z` ，解压，将 `models` 文件夹整个放到 `Release` 目录下。
12. 随便拿一张测试图片，命名为 `test.png` 之类，放到 `Release` 目录下。
13. 命令行启动程序并调试： `RapidOCR-json.exe --models=models --det=ch_PP-OCRv3_det_infer.onnx --cls=ch_ppocr_mobile_v2.0_cls_infer.onnx --rec=ch_PP-OCRv3_rec_infer.onnx  --keys=ppocr_keys_v1.txt --image=test.png`
