<h4 align="right">
  <strong>简体中文</strong> | <a href="https://github.com/hua0512/stream-rec/blob/main/README.md">English</a>
</h4>

# Stream-rec

[![QQ交流群](https://img.shields.io/badge/QQ交流群-EB1923?logo=tencent-qq&logoColor=white)](https://qm.qq.com/q/qAbmjCuTug)
[![赞助](https://img.shields.io/badge/赞助-爱发电-ff69b4)](https://afdian.com/a/streamrec)

Stream-rec 是一个自动录制各种直播平台的工具。

基于 [Kotlin](https://kotlinlang.org/), [Ktor](https://ktor.io/), 和 [ffmpeg](https://ffmpeg.org/)。

# 功能列表

- 自动录播，可配置录制质量，路径，格式，并发量，分段录制（时间或文件大小），分段上传，根据直播标题和开始时间自动命名文件。
- 自动弹幕录制（XML格式），可使用 [DanmakuFactory](https://github.com/hihkm/DanmakuFactory) 进行弹幕转换，或配合[AList](https://alist.nn.ci/zh/)来实现弹幕自动挂载。
- 使用 [SQLite](https://www.sqlite.org/index.html) 持久化存储录播和上传信息
- 支持 [Rclone](https://rclone.org/) 上传到云存储
- 使用 Web 界面进行配置
- 支持 Docker
- 支持 FLV AVC 修复

# 直播平台支持列表

|    平台     | 录制 | 弹幕 |                                  链接格式                                   |
|:---------:|:--:|:--:|:-----------------------------------------------------------------------:|
|    抖音     | ✅  | ✅  |                    `https://live.douyin.com/{抖音id}`                     |
|    斗鱼     | ✅  | ✅  |                      `https://www.douyu.com/{直播间}`                      |
|    虎牙     | ✅  | ✅  |                      `https://www.huya.com/{直播间}`                       |
|  PandaTV  | ✅  | ✅  |                `https://www.pandalive.co.kr/play/{直播间}`                 |
|  Twitch   | ✅  | ✅  |                      `https://www.twitch.tv/{直播间}`                      |
|    微博     | ✅  | ❌  | `https://weibo.com/u/{用户名}` 或 `https://weibo.com/l/wblive/p/show/{直播间}` |
| AfreecaTv | ❌  | ❌  |                                                                         |
| Bilibili  | ❌  | ❌  |                                                                         |
| Niconico  | ❌  | ❌  |                                                                         |
|  Youtube  | ❌  | ❌  |                                                                         |

- 更多平台的支持将在未来加入 (如果我有时间的话，欢迎PR)。

# 截图

![login.png](https://github.com/stream-rec/stream-rec-frontend/blob/master/docs/zh/login.png)
![dashboard.png](https://github.com/stream-rec/stream-rec-frontend/blob/master/docs/zh/dashboard.png)
![streamers.png](https://github.com/stream-rec/stream-rec-frontend/blob/master/docs/zh/streamers.png)

# 文档

请参阅 [文档](https://stream-rec.github.io/docs/zh_CN) 获取更多信息。

# 贡献

欢迎贡献！如果您有任何想法、建议或错误报告，请随时提出问题或拉取请求。

# 许可证

本项目根据 MIT 许可证进行许可。有关详细信息，请参阅 [LICENSE](../LICENSE) 文件。

# 感谢

- [Ktor](https://ktor.io/)
- [Kotlin](https://kotlinlang.org/)
- [FFmpeg](https://ffmpeg.org/)
- [Sqlite](https://www.sqlite.org/index.html)
- [Rclone](https://rclone.org/)
- [Streamlink](https://streamlink.github.io/)
- [ykdl](https://github.com/SeaHOH/ykdl)