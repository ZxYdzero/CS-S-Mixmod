/* Mixmod Created by iDragon *
Updates:
	2025/1/5 by Sparkle: (v5.3)
		1.修复选图菜单问题 删除Cvar

	2025/7/27 by Sparkle: (v5.2)
		1.添加了满十个人自动T人的Cvar (默认0 不开启)
		2.现在会正确显示玩家统计信息了
		3.修复残局状态

	2025/7/5 by Sparkle: (v5.1)
		修复了已知问题:
		1.自动录制demo
		2.换边之后包没了
		3.无限加时直到尽头

	2025/7/1 by Sparkle: (v5.1)
		修复了已知问题:
		1.加时的换边金钱要重置为10000
		2.换边武器重置
		3.热身后的战绩重置

    2025/5/8 by Sparkle:
        重构了代码，使用了新的语法并且通过Ai把所有模块分出去

======================================

- 11-14-24 (by Sparkle)
	* 添加了!show与!hide用来开关准备菜单

- 11-10-24 (by Sparkle)
	* 添加一下功能：
		除去雾气(sm_mixmod_delete_fog)
		满人自动踢出未准备玩家
		更改赛制为Mr12

- 3-17-24 (by Sparkle)
	* 现在可以补位了
	* 修复了第一次满10个人并且进入准备倒计时后 再次满10个人不会触发准备倒计时的bug
	* 平衡队伍在特定情况造成插件堆栈爆炸

- 3-7-24 (by Sparkle)
	* 修复了满十未开始时候在每回合结束时不会CloseTimer导致用户网络堆栈溢出被服务器T出
	* 现在换边不需要选择模型了

- 2-4-24 (by Sparkle)
	* 出现莫名其妙准备人数与实际不符 已添加修正debug并寻找原因中.....
	* 减少文本数量 降低usermessage

- 1-26-24 (by Sparkle)
	* 添加满十个人之后没准备直接踢出
	* 添加更换地图之后的提示
	* 零星的优化

- 1-13-24 (by Sparkle)
	* 添加十个人之后投票换图的逻辑 （感谢pug插件）

- 1-6-24 (by Sparkle)
	* 更换准备hud
	* 去除swaptimer中某一个 if 的 g_IsItManual，强制半场自动live开始

- 8-8-23 (by Sparkle)
	* 修复了内存泄漏的情况

- 29-07-12 (v4.3)
	* Fixed a bug with sm_mmute command! - Sometimes, when players spawn, the mute is gone.
	* Add command to enable/disable the commands: sm_mmute / sm_mgag:
	- 	sm_mixmod_enable_voice_commands (Default: "1")

- 20-07-12 (v4.3)
	* Fixed a bug with the MVP system - When RR'ing mvp scores weren't reseted.
	* Support for not removing props from specified maplist has been added.
	- 	sm_mixmod_dont_remove_props_maplist (Default: "de_inferno,")
	* Fixed a bug with sm_ko3 command - which caused the plugin to swap teams at the end of the first round.

- 08-07-12 (v4.2b)
	* sm_last has been added - This command will show the last player that joined steamid and name.

- 07-06-12 (v4.2)
	* sm_mvp has been added to show mvp kills during a game.

- 02-06-12 (v4.1b):
	* Fixed a bug with auto-recording. (A new record wasn't started right after a mix ended).

- 19-05-12 (V4.1):
	* Fixed a bug with sm_pause (Gives 0$ and no gun to a player who joins the game when sm_pause is being used!)
	* Added sm_mgag and sm_mungag.

- 17-05-12 (V4.0):
	* sm_st will not decrease scores when sm_pcw running!
	* Warn the user that entered in the middle of a mix, that mix is running.
	* 3 Score points added when defusing the bomb.
	* 3 Score points added when the bomb explodes.

- 16-05-12 (V3.9):
	* MVP Display at round End will show only from 3 kills or above...
	* TK won't be counted as a score/death.
	* Random Teams bug (Only CT players can be randomized - not spec) has been fixed.

- 13-05-12 (V3.8a):
	* MVP System Will show now if an ace was done.
	* sm_random Fixed! (Creating random teams)
	* Added sm_mmute and sm_munmute. - I've got about 5 requests to add these commands...
	* Fixed the MVP System.
	* sm_pcw Added to Mix-Help menu. (sm_pcw - Will remember the game scores, even after RR).
	* Enable/Disable MVP Stats has been added to admin menu.

- 12-05-12 (V3.8):
	* Added support for MVP.
	- 	sm_mixmod_show_mvp (Default: "1")
	* Can remove the password automaticaly when mix is ending (not by sm_stop command).
	- 	sm_mixmod_remove_password_on_mix_end (Default: "1")

- 04-06-2011 - 11-05-12 (v3.6-v3.7b)
	* Some changes. I don't remember them...

- 03-09-2011 (v3.5):
	* Fixed some problems that musosoft helped me find (I don't remember them - few days has left already and I forgot to note them).
	* TK-Damage is now showing the armor damage that has been done too!
	* TK-Damage not showing the self-damage that has been done (self-grenade damage and etc...)

- 30-08-2011 (v3.4c):
	* TK-damage wasn't working properly ... Now it's fixed!

- 30-08-2011 (v3.4b):
	* The plugin is using now MaxClients instead of the variable maxClients

- 29-08-2011 (v3.4):
	* Option to see that a player is attacking another player in his same team has been added!
	- 	sm_mixmod_show_tk_damage (Default: "1")

- 19-08-2011 (v3.3):
	* Fixed an issue with disabling players ability to change their team (when player is retrying to the server, he get stuck in the spec team).
	* Fixed compile warnings! (in v3.2, I didn't try to compile the plugin so I haven't notice all the warnings).

- 15-08-2011 (v3.2):
	* The plugin will wait now <sm_mixmod_time_before_swapping_teams> seconds before swapping teams when half ends!
	- 	sm_mixmod_time_before_swapping_teams (Default: "0.1")
	* Option to disable players ability to change their team (jointeam command) when mix is running has been added! (When disabled, only admins can change players team).
	- 	sm_mixmod_manual_switch_enable (Default: "1" - They can change their team).
	* Knife vote (for the winning team of the knife round) is now enabled only when sm_start has been used! if the admin just used !ko3, the vote will not be a vote.

- 14-08-2011 (v3.1):
	* Bug found! - When removing props in de_inferno, some objects are removed, but they are still there invisible (I hope to fix it soon),
	* Command to see all the admin and player commands (and how to use them) has been added!
	- 	sm_mixhelp
	* After knife round (ko3) has ended, if auto-half-live is on, the live will start automatically.
	* When knife round (ko3) is running, only knife can be used.
	* sm_st and sm_swapteams has been updated! now admin can change player team with them!
	-sm_st <player> [team] (legal teams: ct/t/spec/1/2/3)
	* Fixed: when random password is shown only to admins, players can use sm_pw to see the password.

- 12-08-2011 (v3.0):
	* New admin commands has been added!
	- 	sm_record (start a record).
	- 	sm_stoprecord (stop the record).
	* Option to let the winning team in knife round to choose their team has been added!
	- 	sm_mixmod_knife_round_win_vote (Default: "0")
	* Auto-Record option has been added!
	- 	sm_mixmod_autorecord_enable (Default: "0")
	- 	sm_mixmod_autorecord_save_dir (Default: "mix_records")

- 07-08-2011 (v3.0Beta):
	* When player is disconnecting from the server when Auto-Mix is running, option to ban him has been added!
	- 	sm_mixmod_auto_warmod_ban <time> (time in minutes) (Default: "-1")
	(If <time> is negative (< 0) it won't ban, if <time> its 0 it will permanently ban, if time is positive (> 0) it will ban for <time> minutes)
	* Sub system has been added, but it's disabled in this version.
	* Option to random the team players when there are 10 ready players has been added!
	- 	sm_mixmod_auto_warmod_random (Default: "1")
	* sm_teams has been added! players can see the teams in auto-war.
	* sm_pw and sm_password has been changed! now any player can type them to see the server password (only admins can change password).
	* Ready system has been added (Beta system).

- 04-08-2011(v2.6):
	* Players money list at round_start is now sorted! (from highest to lowest).
	* Option to remove all props from the map (every round_start) when mix is running has been added!
	- 	sm_mixmod_remove_props (Default: "1")

- 02-08-2011(v2.5):
	* I forgot to save the vest and armor in the sm_pause command... (Has been added).
	* sm_pause is now working correctly! scores, weapons and client money is now being saved and will be regained the next round.
	* sm_npw has been added! Password can be removed now through this command. (v2.4)

- 27-07-2011 (v2.3):
	* Big issue with wrong team scores has been fixed!
	* Option to show random password to everyone or only to the admin who performed the sm_rpw has been added:
	- 	sm_mixmod_rpw_show_pass (Default: "1")
	* sm_pause is working now (it didn't work before).

- 26-07-2011 (v2.2):
	* After switching teams in half1 zb_lo3 or mp_restartgame will be executed to give some time to "breathe".
	* Text has been changed to ko3 round.
	* Bug fixed: wrong round number in the first round of half 2
	* Mr3 fixed (- Can now be played like it supposed to be played). - TY karil.
	* sm_pause added: see the info above.
	* sm_disablechat added: disable or enable public chat (view info above).

- 25-07-2011 (v2.1):
	* Fixed an issue: Score has been added to the "winning team" when swapping teams at the end of half1 (swapping teams slays all the players).
	* Option added: When mix has ended, the winning team could be displayed in panel or in chat (0 - chat, 1 - panel).
	- 	sm_mixmod_show_winner_in (Default: "1")
	* Bug fixed: After the mix has ended, it told that there was a DRAW instead of telling the name of the winning team.
	* Bug fixed: the plugin wrote that sm_live is needed to start the match although <sm_mixmod_half_auto_live> is set to "1".
	* Fixed an issue with wrong round number (round 2 after !nl, !live and !rr) (v2.0)
	* sm_mix command has been added (opens a menu)
	* Option to Use zb_ko3 instead of mp_restartgame when knife round starts has been added:
	- 	sm_mixmod_use_zb_ko3 (Default: "0")
	* Option to start the match with knife round has been added (sm_live after knife round is finished):
	- 	sm_mixmod_enable_knife_round (Default: "0")
	* sm_spec , sm_ko3 , sm_knifes added (v1.9)

- 24-07-2011 (v1.8):
	* sm_kickct , sm_kickt , sm_maps has been added.
	- 	sm_mixmod_kick_admins (Default: "0")
	* Cvars for using custom names cfg are added (Beta) (v1.7)
	- 	sm_mixmod_custom_mr12_cfg (Default: "mr12.cfg")
	- 	sm_mixmod_custom_prac_cfg (Default: "prac.cfg")
	- 	sm_mixmod_custom_mr3_cfg (Default: "mr3.cfg")

- 23-07-2011 (v1.6):
	* Hook to freeze-time end event, has been removed.
	* You can choose now if you want the sm_live command to be auto-performed when new half begins, or the admin should type sm_live to start the new half.
	- 	sm_mixmod_half_auto_live (Default: "0")
	* You can choose now where to display the money of each team, through chat, or through panel (menu).
	- 	sm_mixmod_show_cash_in_panel (Default: "0")
	* You can now decide in which way the plugin will tell the people not to change their teams (Through chat, or through panel (menu)).
	- 	sm_mixmod_show_swap_in_panel (Default: "1")
	* When using sm_stop command, stop.cfg could be loaded instead of prac / warmup config.
	- 	sm_mixmod_custom_stop_cfg (Default: "0")
	* Fixed bug: when all the players in one have been died in freeze-time, the round has been "skipped".
	* Mr3 can now be played when there is a tie (15-15):
	- 	sm_mixmod_mr3_enable (Default: "1")

- 21-07-2011 (v1.4):
	* Fixed bug: The version of this plugin wasn't being updated.
	* Added option to run zb_lo3 instead of mp_restartgame if zb_warmode is enabled (Version updated: v1.4):
	- 	sm_mixmod_use_zb_lo3 (Default: "0")
	* Restarts the game after <sm_mixmod_live_restart_time> seconds (Version updated: 1.3)
	* Custom team name added (Version updated: 1.2):
	- 	sm_mixmod_custom_name_ct (Default: "Team A")
	- 	sm_mixmod_custom_name_t (Default: "Team B")
	* Fixed bug: When restarting the game in the middle of freeze-time, 1 is being added to the current round (first round = 2nd round in the plugin).

- 18-07-2011 (v1.0):
	* Loose idantation warnings when compiling - fixed!

- 17-07-2011 (v1.0):
	* Released this plugin.


*/
#pragma newdecls required
#pragma semicolon 1

// =============================================================================
// 基础包含文件
// =============================================================================
#include <sourcemod>
#include <sdktools>
#include <cstrike>

// =============================================================================
// 模块化包含文件
// =============================================================================
#include "mixmod/constants.sp"       // 常量定义
#include "mixmod/globals.sp"         // 全局变量
#include "mixmod/core.sp"            // 核心功能
#include "mixmod/teams.sp"           // 队伍管理
#include "mixmod/scoring.sp"         // 得分系统
#include "mixmod/maps.sp"            // 地图管理
#include "mixmod/commands.sp"        // 命令处理
#include "mixmod/events.sp"          // 事件处理
#include "mixmod/ready.sp"           // 准备系统
#include "mixmod/ui.sp"              // 用户界面
#include "mixmod/util.sp"            // 辅助功能
#include "mixmod/stats.sp"           // 统计系统
#include "mixmod/api.sp"             // API接口

// =============================================================================
// 插件信息
// =============================================================================
public Plugin myinfo =
{
    name = "Mix-Plugin",
    author = "iDragon, Sparkle (Updates), Refactored Version",
    description = "提供完整的比赛管理系统，包括队伍管理、比分记录和地图选择",
    version = PLUGIN_VERSION,
    url = "https://github.com/ZxYdzero/CS-S-Mixmod"
};

/**
 * 插件加载前注册 Native。
 *
 * 按 SourceMod API 要求，CreateNative/RegPluginLibrary 应在 AskPluginLoad2
 * 阶段完成，保证依赖本插件 API 的其他插件能稳定发现 natives。
 */
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    Mix_RegisterAPI();
    return APLRes_Success;
}

// =============================================================================
// 插件入口点
// =============================================================================

/**
 * 插件初始化
 *
 * 此函数在插件加载时调用，负责初始化所有子系统和注册必要的钩子。
 */
public void OnPluginStart()
{
    // 初始化所有子系统（按依赖顺序）
    Mix_InitConstants();     // 初始化常量（必须最先初始化）
    Mix_InitGlobals();       // 初始化全局变量
    Mix_InitConVars();       // 创建ConVars（在命令和事件之前初始化）
    // 加载翻译文件
    LoadTranslations("mixmod.phrases");
    Mix_InitStats();         // 初始化统计系统
    Mix_InitAPI();           // 初始化API接口
    Mix_InitCommands();      // 注册命令
    Mix_InitEvents();        // 注册事件钩子
    Mix_InitMaps();          // 初始化地图系统
    Mix_InitUI();            // 初始化UI（依赖于其他系统）

    // 自动生成配置文件
    AutoExecConfig(true, CONFIG_FILENAME);

    // 输出插件加载信息
    LogMessage("Mix-Plugin v%s 已成功加载", PLUGIN_VERSION);
    PrintToServer("[%s] Mix-Plugin v%s 已成功加载", MODNAME, PLUGIN_VERSION);

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            SetGlobalTransTarget(i);
            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Plugin Loaded", PLUGIN_VERSION);
        }
    }
}

/**
 * 当地图结束时
 *
 * 此函数在地图结束时调用，负责清理与当前地图相关的资源。
 */
public void OnMapEnd()
{
    Mix_OnMapEnd();
}

/**
 * 当地图开始时
 *
 * 此函数在新地图加载完成时调用，负责初始化与地图相关的功能。
 */
public void OnMapStart()
{
    Mix_OnMapStart();
}

/**
 * 当客户端授权时
 *
 * 此函数在玩家连接并通过授权后调用，用于记录玩家信息和处理相关逻辑。
 *
 * @param client 客户端索引
 * @param auth   客户端的授权ID（通常是Steam ID）
 */
public void OnClientAuthorized(int client, const char[] auth)
{
    Mix_OnClientAuthorized(client);
}

/**
 * 当游戏帧更新时
 *
 * 此函数在每个游戏帧更新时调用，可用于实现需要持续检查的功能。
 */
public void OnGameFrame()
{
    Mix_OnGameFrame();
}

/**
 * 当插件卸载时
 *
 * 此函数在插件被卸载前调用，负责清理资源和恢复游戏状态。
 */
public void OnPluginEnd()
{
    Mix_OnPluginEnd();
}
