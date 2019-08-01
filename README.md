# ZEGO 即构语聊房DEMO

## 运行指引
将项目下载到本地后，还需要额外下载相关直播SDK方可运行。 
### 下载SDK 
在[ZEGO官网SDK下载页面](https://doc.zego.im/download/sdk)下载ZegoLiveRoom.framework进阶版及ZegoChatroom.framework。将SDK放在项目的合适位置。
### 导入项目
将下载的两个 SDK 拖入 Chatroom-iOS 项目，并且在 Chatroom-iOS target 的 General 设置页面中的 Embedded Binaries 和 Linked Frameworks And Binaries 中添加以上SDK。
### 修改项目 Embed 配置
在 Chatroom-iOS target 的 Build Phases 设置页面中的 Embed Frameworks 中，将旧的 ZegoChatroom.framework 移除，加入新的 ZegoChatroom.framework。

## ZEGO Support
Please visit [语聊房](https://doc.zego.im/CN/646.html)
