# CS:Source 满十插件 Mixmod

> 修改自 [iDragon的Mixmod插件](https://forums.alliedmods.net/showthread.php?p=1512637)  
> 由 Sparkle 重构

## 功能特性

- 十人准备、自动换图
- 准备HUD面板，支持!show/!hide切换
- 自动录制Demo（可选）
- 半场自动换边并自动live
- 地图雾气自动移除
- 支持MR12赛制与一次MR3加时
- 满人后自动踢出未准备玩家
- 比赛时自动设置/移除服务器密码
- 管理员菜单与常用命令支持

## 安装步骤

1. 安装 [Sourcemod](https://www.sourcemod.net/downloads.php?branch=stable) 和 [Metamod](https://www.sourcemm.net/downloads.php?branch=stable)。
2. 下载 [Team Limits插件](https://forums.alliedmods.net/showthread.php?p=2699194) 和 [Restart Empty插件](https://forums.alliedmods.net/showthread.php?p=2646280)。
3. 将本项目所有文件解压到服务器 `cstrike` 目录下。
4. 启动服务器后关闭，在 `cstrike/cfg/sourcemod/` 目录下找到 `sm_mixmod.cfg`，按需修改参数。
5. 修改 `cstrike/cfg/sourcemod/sm_restart_empty.cfg`，将 `sm_restart_empty_method` 参数改为3。
6. 完成安装。

## 常用命令

### 玩家命令

- `!ready` / `!r`：准备
- `!notready` / `!nr`：取消准备
- `!sp`：显示/隐藏准备面板
- `!score`：显示比分
- `!mvp`：显示MVP
- `!hp`：死亡后查看敌人血量

### 管理员命令

- `!mix`：显示Mix管理菜单
- `!mr12` / `!live`：执行mr12.cfg并开始比赛
- `!prac` / `!warmup`：恢复热身
- `!map`：显示地图列表
- `!rr`：重启当前回合
- `!swap`：交换队伍
- `!record` / `!stop`：开始/停止录制
- `!kickct` / `!kickt`：踢出所有CT/T
- `!random`：随机分配队伍
- `!ko3`：开始刀局
- `!password`：设置服务器密码
- `!removepassword` / `!rpass`：移除密码
- `!rpw`：设置随机密码
- `!mmute` / `!mgag`：静音/禁言玩家

## 配置说明

- 主要配置文件：`cfg/sourcemod/sm_mixmod.cfg`
- 赛制配置：`cfg/mr12.cfg`, `cfg/mr3.cfg`, `cfg/prac.cfg`
- 详细参数请参考配置文件注释

## 注意事项

- 换图后请务必执行 `changelevel_next`，否则可能导致服务器崩溃。
- 插件默认支持常用比赛流程，支持自定义队名、密码、地图列表等。

## 许可证

本插件遵循 [GNU GPL v3](LICENSE) 协议开源发布。  
如需反馈或贡献，请访问 [项目主页](https://github.com/ZxYdzero/CS-S-Mixmod)。

---

如需详细开发文档或二次开发接口说明，请查阅源码注释及各模块文件。