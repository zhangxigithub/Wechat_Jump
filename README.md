# Wechat_Jump


1. Mac捕获iOS屏幕 https://developer.apple.com/videos/play/wwdc2014/508/   （4:11）
~~2. openCV解析图像，识别棋子和目标点(或者 CIDetector https://gist.github.com/gardaud/9ce829e83fcd2d2fb29d)~~
2.根据固定颜色找到棋子
3.从某个位置开始逐行扫描图像，检测到像素剧烈波动，则为上顶点，向下取间隔5个像素的点，向下检测，遇到像素波动记录为下顶点，找到中心点。计算距离
4. 蓝牙连接arduino，控制伺服电机按下相应的时间，




2018.1.12
基本完成简单的位置检测，纯色图形支持较好，复杂图形支持不够好，但是能找到上顶点。下一步完成机械部分先确认一下精度够不够

2018.1.13
写完了下位机程序，根据上位机传来的时长，控制舵机“按下多少秒”，没有触控笔，不方便点按屏幕，从淘宝3.8包邮买了一个。

2018.1.24
等待触控笔，先拿耳塞泡水接地简单做了个，出现两次误条情况，不清楚是蓝牙通信问题还是arduino问题，测试用的是40块钱的UNO，明天拿正版mega试试。
