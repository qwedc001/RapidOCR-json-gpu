#### 离线 OCR 组件 系列项目：

- [PaddleOCR-json](https://github.com/hiroi-sora/PaddleOCR-json)
- [RapidOCR-json](https://github.com/hiroi-sora/RapidOCR-json) <- **RapidOCR-json-gpu**

|                  | PaddleOCR-json                                      | RapidOCR-json        |
| ---------------- | --------------------------------------------------- | -------------------- |
| CPU 要求         | CPU 必须具有 AVX 指令集。不支持以下 CPU：           | 无特殊要求 👍        |
|                  | 凌动 Atom，安腾 Itanium，赛扬 Celeron，奔腾 Pentium |                      |
| 推理加速库       | mkldnn 👍                                           | 无                   |
| 识别速度         | 快（启用 mkldnn 加速）👍                            | 中等                 |
|                  | 极慢（不启用 mkldnn）                               |                      |
| 初始化耗时       | 约 2s，慢                                           | 0.1s 内，快 👍       |
| 组件体积（压缩） | 52MB                                                | 15MB 👍              |
| 组件体积（部署） | 250MB                                               | 30MB 👍              |
| CPU 占用         | 高，榨干硬件性能                                    | 较低，对低配机器友好 |
| 内存占用峰值     | >2000MB（启用 mkldnn）                              | ~500MB 👍            |
|                  | ~600MB（不启用 mkldnn）                             |                      |

---

# RapidOCR-json-gpu 项目说明

本项目基于 RapidOCR-json，实际源代码完全不变，仅更换了编译选项并增添了 GPU 加速功能。

**需要注意的是，本项目的 GPU 加速功能强依赖于 NVIDIA 的 CUDA 和 cuDNN 库。如果需要使用，请前往 NVIDIA 官网下载 CUDA 和 Cudnn，并且严格对照 release 中提供的 cuda 和 cudnn 版本号。反之则可能出现闪退等一系列问题。**

如果 release 中提供的文件并不能正常在您电脑上运行，请首先尝试采用标注 cuda 版本更低的 release，或者 clone 此项目，并按照构建指南进行编译。

## [项目构建指南](cpp)

👆 当你需要修改项目源码时欢迎参考。

# RapidOCR-json 原项目

这是一个基于 [RapidOcrOnnx](https://github.com/RapidAI/RapidOcrOnnx) 的离线图片 OCR 文字识别程序。通过管道等方式输入本地图片路径，输出识别结果 json 字符串。适用于 `Win7 x64` 及以上的系统。

本项目旨在提供一个封装好的 OCR 引擎组件，使得没有 C++编程基础的用户也可以用别的语言来简单地调用 OCR，享受到更快的运行效率、更便捷的打包&部署手段。

![](/readme_images/img-1.png)

### 简单试用

方式一：

打开控制台，输入 `path/RapidOCR-json.exe --GPU=0 --image_path=path/test1.png` 。

方式二：

打开控制台，输入 `RapidOCR_json.exe --GPU=0` 。等程序初始化完毕输出`OCR init completed.`。

使用 json 字符串输入图片路径，建议使用 ascii 转义。如：

`{"image_path":"D:/\u6d4b\u8bd5\u56fe\u7247.png"}`

也支持传入图片 base64 编码的字符串。如：

`{"image_base64":"……"}`

还可以直接使用 [Python API](api/python/) 。

## 指令说明

| 键名称         | 值说明                               | 默认值                                |
| -------------- | ------------------------------------ | ------------------------------------- |
| ensureAscii    | 启用(1)/禁用(0) ASCII 转义输出       | 0                                     |
| models         | 模型目录地址，可绝对 or 相对路径     | "models"                              |
| det            | det 库名称                           | "ch_PP-OCRv3_det_infer.onnx"          |
| cls            | cls 库名称                           | "ch_ppocr_mobile_v2.0_cls_infer.onnx" |
| rec            | rec 库名称                           | "ch_PP-OCRv3_rec_infer.onnx"          |
| keys           | rec 字典名称                         | "ppocr_keys_v1.txt"                   |
| doAngle        | 启用(1)/禁用(0) 文字方向检测         | 1                                     |
| mostAngle      | 启用(1)/禁用(0) 角度投票             | 1                                     |
| numThread      | 线程数                               | 4                                     |
| padding        | 预处理白边宽度，可优化窄边图片识别率 | 50                                    |
| maxSideLen     | 图片长边缩小值，可提高大图速度       | 1024                                  |
| boxScoreThresh | 文字框置信度门限值                   | 0.5                                   |
| boxThresh      |                                      | 0.3                                   |
| unClipRatio    | 单个文字框大小倍率                   | 1.6                                   |
| image_path     | 初始图片路径                         | ""                                    |

例 1：（启动时传入图片路径，执行一次识别，然后关闭程序）

```
RapidOCR_json.exe  --image_path="D:/images/test(1).png"
输出: 识别结果
```

例 2：（启动时不传入图片路径，进入无限循环，不断接受 json 输入）

```
RapidOCR_json.exe  --ensureAscii=1
输出: OCR init completed.
{"image_path": "D:/images/test(1).png"}
输出: 识别结果
```

例 3：（手动指定参数）

```
RapidOCR_json.exe --doAngle=0 --mostAngle=0 --numThread=12 --padding=100 --image_path="D:/images/test(1).png"
```

## 返回值说明

通过 API 调用一次 OCR，无论成功与否，都会返回一个字典。

字典中，根含两个元素：状态码`code`和内容`data`。

状态码`code`为整数，每种状态码对应一种情况：

##### `100` 识别到文字

- data 内容为数组。数组每一项为字典，含三个元素：
  - `text` ：文本内容，字符串。
  - `box` ：文本包围盒，长度为 4 的数组，分别为左上角、右上角、右下角、左下角的`[x,y]`。整数。
  - `score` ：识别置信度，浮点数。
- 例：
  ```
    {'code':100,'data':[{'box':[[13,5],[161,5],[161,27],[13,27]],'score':0.9996442794799805,'text':'飞舞的因果交流'}]}
  ```

##### `101` 未识别到文字

- data 为字符串：`No text found in image. Path:"图片路径"`
- 例：`{'code':101,'data':'No text found in image. Path: "D:\\空白.png"'}`
- 这是正常现象，识别没有文字的空白图片时会出现这种结果。

##### `200` 图片路径不存在

- data 为字符串：`Image path dose not exist. Path:"图片路径".`
- 例：`{'code':200,'data':'Image path dose not exist. Path: "D:\\不存在.png"'}`
- 注意，在系统未开启 utf-8 支持（`使用 Unicode UTF-8 提供全球语言支持"`）时，不能读入含 emoji 等特殊字符的路径（如`😀.png`）。但一般的中文及其他 Unicode 字符路径是没问题的，不受系统区域及默认编码影响。

##### `201` 图片路径 string 无法转换到 wstring

- data 为字符串：`Image path failed to convert to utf-16 wstring. Path: "图片路径".`
- 使用 API 时，理论上不会报这个错。
- 开发 API 时，若传入字符串的编码不合法，有可能报这个错。

##### `202` 图片路径存在，但无法打开文件

- data 为字符串：`Image open failed. Path: "图片路径".`
- 可能由系统权限等原因引起。

##### `203` 图片打开成功，但读取到的内容无法被 opencv 解码

- data 为字符串：`Image decode failed. Path: "图片路径".`
- 注意，引擎不以文件后缀来区分各种图片，而是对存在的路径，均读入字节尝试解码。若传入的文件路径不是图片，或图片已损坏，则会报这个错。
- 反之，将正常图片的后缀改为别的（如`.png`改成`.jpg或.exe`），也可以被正常识别。

##### `210` 剪贴板打开失败

- data 为字符串：`Clipboard open failed.`
- 可能由别的程序正在占用剪贴板等原因引起。

##### `211` 剪贴板为空

- data 为字符串：`Clipboard is empty.`

##### `212` 剪贴板的格式不支持

- data 为字符串：`Clipboard format is not valid.`
- 引擎只能识别剪贴板中的位图或文件。若不是这两种格式（如复制了一段文本），则会报这个错。

##### `213` 剪贴板获取内容句柄失败

- data 为字符串：`Getting clipboard data handle failed.`
- 可能由别的程序正在占用剪贴板等原因引起。

##### `214` 剪贴板查询到的文件的数量不为 1

- data 为字符串：`Clipboard number of query files is not valid. Number: 文件数量`
- 只允许一次复制一个文件。一次复制多个文件再调用 OCR 会得到此报错。

##### `215` 剪贴板检索图形对象信息失败

- data 为字符串：`Clipboard get bitmap object failed.`
- 剪贴板中是位图，但获取位图信息失败。可能由别的程序正在占用剪贴板等原因引起。

##### `216` 剪贴板获取位图数据失败

- data 为字符串：`Getting clipboard bitmap bits failed.`
- 剪贴板中是位图，获取位图信息成功，但读入缓冲区失败。可能由别的程序正在占用剪贴板等原因引起。

##### `217` 剪贴板中位图的通道数不支持

- data 为字符串：`Clipboard number of image channels is not valid. Number: 通道数`
- 引擎只允许读入通道为 1（黑白）、3（RGB）、4（RGBA）的图片。位图通道数不是 1、3 或 4，会报这个错。

##### `299` 未知异常

- data 为字符串：`An unknown error has occurred.`
- 正常情况下不应该出现此状态码。请提 issue。

##### `300` 返回数据无法转换为 json 字符串

- data 为字符串：`JSON dump failed. Coding error.`
- 通过启动参数-image_dir 传入非法编码的路径（含中文）时引起。（中文路径应该先启动程序再输入）

## 通过 API 调用

### 1. Python API

[资源目录](api/python)

使用示例：

```python
import os
import sys

from RapidOCR_api import OcrAPI

ocrPath = '引擎路径/RapidOCR_json.exe'
ocr = OcrAPI(ocrPath)
res = ocr.run('样例.png')

print('OCR识别结果：\n', res)
ocr.stop()
```

其他待填坑……

## 感谢

感谢 [RapidAI/RapidOcrOnnx](https://github.com/RapidAI/RapidOcrOnnx) ，没有它就没有本项目。

本项目中使用了 [nlohmann/json](https://github.com/nlohmann/json) ：

> “JSON for Modern C++”

## 更新日志

#### v0.2.0 `2023.9.25`

- 路径识图的 key 由 `imagePath` 改为 `image_path`
- 新功能：base64 识图，key 为 `image_base64`

#### v0.1.0 `2023.4.29`
