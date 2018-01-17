# 微信跳一跳外挂



* AVCapture捕获iPhone屏幕(https://developer.apple.com/videos/play/wwdc2014/508/  )
* 解析坐标：手动扫描像素点查找上下顶点
* 控制触手: Arduino+舵机
* 通信: 蓝牙
* 电容笔: 淘宝3.8包邮买的(DIY的效果不好，一开始用海绵蘸水，不稳定，铝箔太硬，接触不稳定)

2018.1.17
电容笔到了，基本完成，精度基本满意，连续跳到中心最多能达到20次。
* [iPhone演示](https://youtu.be/IY3LUXc-2dg)
* [Mac演示](https://youtu.be/4C_StpnPUC0)

2018.1.16
现在触控时间是一个y=ax的函数，考虑到舵机有响应时间，应该是y=ax+b，需要测量下舵机的实际响应时间，求出b。

2018.1.15
耳塞泡水触控受干湿度的影响太大了，该用铝箔纸做触控笔后，效果还比较稳定，玩到了1000分。
https://youtu.be/DsFWsGPrE-M

2018.1.14
等待触控笔，先拿耳塞泡水接地简单做了个，出现两次误跳情况，不清楚是蓝牙通信问题还是arduino问题，测试用的是40块钱的UNO，明天拿正版mega试试。https://youtu.be/y332n1p0jYY

2018.1.13
写完了下位机程序，根据上位机传来的时长，控制舵机“按下多少秒”，没有触控笔，不方便点按屏幕，从淘宝3.8包邮买了一个。

2018.1.12
基本完成简单的位置检测，纯色图形支持较好，复杂图形支持不够好，但是能找到上顶点。下一步完成机械部分先确认一下精度够不够







![Arduino](https://raw.githubusercontent.com/zhangxigithub/Wechat_Jump/master/pic3.JPG)
![Mac](https://raw.githubusercontent.com/zhangxigithub/Wechat_Jump/master/pic.png)
![Arduino](https://raw.githubusercontent.com/zhangxigithub/Wechat_Jump/master/pic2.JPG)
