
# CS:Source Mix 插件

这是一个为 Counter-Strike: Source 设计的比赛管理插件，提供了完整的比赛流程管理、队伍管理、统计系统和多语言支持。

## 安装步骤

1. 安装 [Sourcemod](https://www.sourcemod.net/downloads.php?branch=stable) 和 [Metamod](https://www.sourcemm.net/downloads.php?branch=stable)。
2. 下载 [Team Limits插件](https://forums.alliedmods.net/showthread.php?p=2699194) 和 [Restart Empty插件](https://forums.alliedmods.net/showthread.php?p=2646280)。
3. 将本项目所有文件解压到服务器 `cstrike` 目录下。
4. 启动服务器后关闭，在 `cstrike/cfg/sourcemod/` 目录下找到 `sm_mixmod.cfg`，按需修改参数。
5. 修改 `cstrike/cfg/sourcemod/sm_restart_empty.cfg`，将 `sm_restart_empty_method` 参数改为3。
6. 完成安装。

## 主要功能

### 比赛管理
- **比赛流程控制**：支持标准的 MR12 (每半场12回合) 赛制 并且最多有一次加时
- **半场交换**：自动处理半场结束时的队伍交换
- **刀局选边**：支持刀局决定队伍选边
- **回合重启**：支持管理员重启当前回合
- **DEMO录制**：内置 SourceTV 录制功能，可自动或手动控制

### 队伍管理
- **准备系统**：玩家可以使用 !ready/!notready 命令表示准备状态
- **随机分队**：支持随机分配队伍
- **队伍交换**：支持手动交换队伍
- **自定义队名**：可以为 CT 和 T 设置自定义队名

### 地图管理
- **地图投票**：支持地图列表和地图投票
- **地图切换**：支持管理员直接切换地图
- **地图列表来源**：可以从 maps 目录或 mapcycle.txt 生成地图列表

### 统计系统
- **个人统计**：记录击杀、死亡、助攻、爆头、伤害等数据
- **比赛统计**：在比赛结束时显示所有玩家的统计数据
- **实时查询**：玩家可以随时查看自己或他人的统计数据
- **残局识别**：自动识别并记录残局获胜情况
- **统计指标**：包括 K/D 比率、爆头率、平均每回合伤害(ADR)、命中率等

### 多语言支持
- **内置翻译**：支持中文、英文和俄文
- **翻译系统**：使用 SourceMod 原生翻译系统
- **客户端语言**：根据客户端语言设置显示对应语言的消息

### 其他功能
- **密码管理**：支持设置、移除和随机生成服务器密码
- **语音管理**：支持静音和禁言玩家
- **道具移除**：可以移除地图上的鸡、可打碎物体等干扰物
- **API接口**：提供 API 接口供其他插件访问比赛状态和统计数据

## 命令列表

### 玩家命令
- `!ready` / `!r`：设置为准备状态
- `!notready` / `!nr`：设置为未准备状态
- `!score`：显示当前比分
- `!mvp`：显示当前 MVP
- `!stats [玩家名]`：显示统计信息
- `!sp`：显示/隐藏指南面板
- `!help`：显示帮助信息

### 管理员命令
- `!mix`：显示 Mix 管理菜单
- `!mr12` / `!live`：执行 mr12.cfg 并开始比赛
- `!prac` / `!warmup`：恢复热身模式
- `!map`：显示地图列表
- `!rr`：重启当前回合
- `!swap`：交换队伍
- `!record` / `!stop`：开始/停止录制
- `!kickct` / `!kickt`：踢出所有 CT/T
- `!random`：随机分配队伍
- `!ko3`：开始刀局
- `!password`：设置服务器密码
- `!removepassword` / `!rpass`：移除密码
- `!rpw`：设置随机密码
- `!mmute` / `!mgag`：静音/禁言玩家

## 配置说明

插件提供了多个 ConVar 用于自定义功能：

- `sm_mixmod_enable`：启用或禁用插件 (默认: 1)
- `sm_mixmod_stats_enabled`：启用或禁用统计系统 (默认: 1)
- `sm_mixmod_showmoney`：显示玩家金钱和武器信息 (默认: 1)
- `sm_mixmod_showscores`：回合开始时显示比分 (默认: 1)
- `sm_mixmod_enable_rr_command`：启用 !rr 命令 (默认: 1)
- `sm_mixmod_custom_name_ct`：CT 队伍自定义名称 (默认: "Team A")
- `sm_mixmod_custom_name_t`：T 队伍自定义名称 (默认: "Team B")
- `sm_mixmod_mr3_enable`：启用 MR3 加时赛 (默认: 1)

完整配置文件位于：`cstrike/cfg/sourcemod/sm_mixmod.cfg`

## 注意事项

- 换图后请务必执行 `changelevel_next`，否则可能导致服务器崩溃。
- 插件默认支持常用比赛流程，支持自定义队名、密码、地图列表等。

## 许可证

本插件遵循 [GNU GPL v3](LICENSE) 协议开源发布。  
如需反馈或贡献，请访问 [项目主页](https://github.com/ZxYdzero/CS-S-Mixmod)。

---

如需详细开发文档或二次开发接口说明，请查阅源码注释及各模块文件。