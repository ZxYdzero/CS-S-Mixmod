/**
 * 核心功能模块
 */

#if defined _mixmod_core_included
  #endinput
#endif
#define _mixmod_core_included

/**
 * 初始化ConVars
 */
void Mix_InitConVars()
{
    // 载入翻译文件
    LoadTranslations("common.phrases");

    // 创建ConVars
    g_hCvarEnabled = CreateConVar("sm_mixmod_enable", "1", "启用或禁用此插件及其功能: 0 - 禁用, 1 - 启用");
    g_hCvarShowMoneyAndWeapons = CreateConVar("sm_mixmod_showmoney", "1", "显示玩家的金钱和武器信息给队友? 0 - 否, 1 - 是");
    g_hCvarShowScores = CreateConVar("sm_mixmod_showscores", "1", "在回合开始时显示比分? 0 - 否, 1 - 是");
    g_hCvarEnableRRCommand = CreateConVar("sm_mixmod_enable_rr_command", "1", "启用sm_rr命令? 0 - 否, 1 - 是");
    g_hCvarPlayTeamSwapedSound = CreateConVar("sm_mixmod_enable_st_sound", "1", "半场结束时播放队伍切换音效? 0 - 否, 1 - 是");
    g_hCvarCusomNameTeamCT = CreateConVar("sm_mixmod_custom_name_ct", "Team A", "设置CT队伍自定义名称 (最长32个字符)");
    g_hCvarCusomNameTeamT = CreateConVar("sm_mixmod_custom_name_t", "Team B", "设置T队伍自定义名称 (最长32个字符)");
    g_hCvarRestartTimeInLiveCommand = CreateConVar("sm_mixmod_live_restart_time", "5", "设置live命令中mp_restartgame的时间 (秒)");
    g_hCvarUseZBMatchCommand = CreateConVar("sm_mixmod_use_zb_lo3", "0", "使用zb_lo3命令代替mp_restartgame? 0 - 否, 1 - 是");
    g_hCvarMr3Enabled = CreateConVar("sm_mixmod_mr3_enable", "1", "启用或禁用mr3设置(12-12平局时): 0 - 禁用, 1 - 启用");
    g_hCvarStopCustomCfg = CreateConVar("sm_mixmod_custom_stop_cfg", "0", "使用stop.cfg代替prac/warmup配置? 0 - 否, 1 - 是");
    g_hCvarShowSwitchInPanel = CreateConVar("sm_mixmod_show_swap_in_panel", "1", "半场最后一回合提示不要切换队伍的方式: 0 - 聊天框, 1 - 面板");
    g_hCvarShowCashInPanel = CreateConVar("sm_mixmod_show_cash_in_panel", "0", "回合开始时显示玩家金钱的方式: 0 - 聊天框, 1 - 面板");
    g_hCvarHalfAutoLiveStart = CreateConVar("sm_mixmod_half_auto_live", "1", "半场开始时自动开始live? 0 - 否, 1 - 是");
    g_hCvarCustomLiveCfg = CreateConVar("sm_mixmod_custom_live_cfg", "mr12.cfg", "mr12配置文件的自定义名称");
    g_hCvarCustomPracCfg = CreateConVar("sm_mixmod_custom_prac_cfg", "prac.cfg", "练习配置文件的自定义名称");
    g_hCvarCustomMr3Cfg = CreateConVar("sm_mixmod_custom_mr3_cfg", "mr3.cfg", "mr3配置文件的自定义名称");
    g_hCvarKickAdmins = CreateConVar("sm_mixmod_kick_admins", "0", "使用sm_kickct或sm_kickt时也踢出管理员? 0 - 否, 1 - 是");
    g_hCvarDisableSayCommand = CreateConVar("sm_mixmod_disable_public_chat", "0", "禁用公共聊天? 0 - 否, 1 - 是, 2 - 仅在live时");
    g_hCvarEnableKnifeRound = CreateConVar("sm_mixmod_enable_knife_round", "0", "比赛开始前进行刀局? 0 - 禁用, 1 - 启用");
    g_hCvarUseKo3Command = CreateConVar("sm_mixmod_use_zb_ko3", "0", "使用zb_ko3命令代替mp_restartgame? 0 - 否, 1 - 是");
    g_hCvarInformWinnerInPanel = CreateConVar("sm_mixmod_show_winner_in", "1", "比赛结束时显示获胜队伍的方式: 0 - 聊天框, 1 - 面板");
    g_hCvarRpwShowPass = CreateConVar("sm_mixmod_rpw_show_pass", "1", "向所有人显示随机密码? 0 - 否(仅向管理员显示), 1 - 是");
    g_hCvarRemoveProps = CreateConVar("sm_mixmod_remove_props", "0", "比赛运行时移除地图上的道具? 0 - 否, 1 - 是");
    g_hCvarAutoMixEnabled = CreateConVar("sm_mixmod_auto_warmod_enable", "1", "启用自动战局和准备系统? 0 - 否, 1 - 是");
    g_hCvarAutoMixRandomize = CreateConVar("sm_mixmod_auto_warmod_random", "0", "10名玩家准备好后随机分配队伍并开始? 0 - 否, 1 - 是");
    g_hCvarEnableAutoSourceTVRecord = CreateConVar("sm_mixmod_autorecord_enable", "0", "比赛live后自动录制? 0 - 否, 1 - 是");
    g_hCvarAutoSourceTVRecordSaveDir = CreateConVar("sm_mixmod_autorecord_save_dir", "mix_records", "自动录制的保存目录");
    g_hCvarKnifeWinTeamVote = CreateConVar("sm_mixmod_knife_round_win_vote", "1", "允许刀局获胜队伍选择队伍? 0 - 否, 1 - 是");
    g_hCvarEnablePasswords = CreateConVar("sm_mixmod_password_commands_enable", "0", "启用密码相关命令? 0 - 否, 1 - 是");
    g_hCvarAllowManualSwitching = CreateConVar("sm_mixmod_manual_switch_enable", "1", "允许玩家在比赛进行时手动切换队伍? 0 - 否, 1 - 是");
    g_hCvarDelayBeforeSwapping = CreateConVar("sm_mixmod_time_before_swapping_teams", "0.1", "半场结束时等待多少秒后交换队伍");
    g_hCvarShowTkMessage = CreateConVar("sm_mixmod_show_tk_damage", "1", "在服务器中通知所有玩家友伤情况? 0 - 否, 1 - 是");
    g_hCvarRemovePassWhenMixIsEnded = CreateConVar("sm_mixmod_remove_password_on_mix_end", "1", "比赛结束时移除密码? 0 - 否, 1 - 是");
    g_hCvarShowMVP = CreateConVar("sm_mixmod_show_mvp", "1", "显示MVP? 0 - 否, 1 - 是");
    g_hCvarDontRemovePropsMaps = CreateConVar("sm_mixmod_dont_remove_props_maplist", "de_inferno,", "不移除道具的地图列表");
    g_hCvarEnableVoiceCommands = CreateConVar("sm_mixmod_enable_voice_commands", "1", "启用sm_mmute和sm_mgag命令? 0 - 否, 1 - 是");
    g_hFogDelete = CreateConVar("sm_mixmod_delete_fog", "1", "移除地图上的雾效果? 0 - 否, 1 - 是");
    g_hCvarOpenAutoKick = CreateConVar("sm_mixmod_auto_kick", "0", "在双方满十个人的时候自动踢出未准备玩家? 0 - 否, 1 - 是");

    // 插件版本控制
    g_hPluginVersion = CreateConVar("sm_mixmod_version", PLUGIN_VERSION, "满十插件版本", FCVAR_SS_ADDED|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
    SetConVarString(g_hPluginVersion, PLUGIN_VERSION);

    // 监听版本改变
    HookConVarChange(g_hPluginVersion, Mix_OnVersionChanged);

    // 查找游戏偏移量和ConVars
    Mix_FindGameOffsets();
}

/**
 * 查找游戏偏移量和ConVars
 */
void Mix_FindGameOffsets()
{
    // 查找玩家金钱偏移量
    g_iAccount = FindSendPropInfo("CCSPlayer", "m_iAccount");
    if (g_iAccount == -1) {
        // 这里使用硬编码的消息，因为没有对应的翻译短语
        // 可以在翻译文件中添加"Account Offset Not Found"短语
        PrintToChatAll("\x04[%s]:\x03 无法找到m_iAccount偏移! - 金钱信息将不会显示!", MODNAME);
    }

    // 查找游戏重启ConVar
    g_hRestartGame = FindConVar("mp_restartgame");
    if (g_hRestartGame == INVALID_HANDLE) {
        // 这里使用硬编码的消息，因为没有对应的翻译短语
        // 可以在翻译文件中添加"Restart Game ConVar Not Found"短语
        PrintToChatAll("\x04[%s]:\x03 无法找到mp_restartgame变量!", MODNAME);
        SetFailState("[%s]: 无法找到mp_restartgame变量!", MODNAME);
    }
    HookConVarChange(g_hRestartGame, Mix_OnGameRestarted);

    // 查找冻结时间ConVar
    g_hFreezeTime = FindConVar("mp_freezetime");
    if (g_hFreezeTime == INVALID_HANDLE) {
        // 这里使用硬编码的消息，因为没有对应的翻译短语
        // 可以在翻译文件中添加"Freeze Time ConVar Not Found"短语
        PrintToChatAll("\x04[%s]:\x03 无法找到mp_freezetime变量!", MODNAME);
        SetFailState("[%s]: 无法找到mp_freezetime变量!", MODNAME);
    }

    // 查找服务器密码ConVar
    g_hPassword = FindConVar("sv_password");

    // 查找服务器名称ConVar
    g_hHostName = FindConVar("hostname");
    GetConVarString(g_hHostName, g_szHostName, sizeof(g_szHostName));
}

/**
 * 地图开始时调用
 */
void Mix_OnMapStart()
{
    if (g_bIsBuyZoneDisabled) {
        if (Mix_EnableBuyZone()) {
            g_bIsBuyZoneDisabled = false;
        }
    }

    // 移除雾效果
    if (GetConVarInt(g_hFogDelete) == 1) {
        int fogController = FindEntityByClassname(-1, "env_fog_controller");
        if (fogController != -1) {
            DispatchKeyValue(fogController, "fogenable", "false");
            AcceptEntityInput(fogController, "TurnOff");
        }
    }

    // 预加载声音
    PrecacheSound("ambient/misc/brass_bell_C.wav", true);

    // 重置地图投票相关变量
    if (g_bHasVoteMap == true && g_bTenVoted == true) {
        g_bHasVoteMap = false;
        Mix_ResetReadySystem();
    }

    // 重置玩家状态
    for (int i = 0; i <= MaxClients; i++) {
        g_bGaggedPlayers[i] = false;
        g_bMutedPlayers[i] = false;
    }

    // 重置插件状态
    g_bHasMixStarted = false;
    g_bDidLiveStarted = false;
    g_bIsKo3Running = false;
    g_bIsItManual = true;
    g_bIsRandomBeingUsed = false;

    // 重置最后进入玩家信息
    g_szLastEntered_SteamID = "NOT_VALID";
    g_szLastEntered_Name = "NOT_VALID";

    // 重新查找金钱偏移量
    g_iAccount = FindSendPropInfo("CCSPlayer", "m_iAccount");
    if (g_iAccount == -1) {
        // 这里使用硬编码的消息，因为没有对应的翻译短语
        // 可以在翻译文件中添加"Account Offset Not Found"短语
        PrintToChatAll("\x04[%s]:\x03 无法找到m_iAccount偏移! - 金钱信息将不会显示!", MODNAME);
    }

    // 重新查找游戏重启ConVar
    g_hRestartGame = FindConVar("mp_restartgame");
    if (g_hRestartGame == INVALID_HANDLE) {
        // 这里使用硬编码的消息，因为没有对应的翻译短语
        // 可以在翻译文件中添加"Restart Game ConVar Not Found"短语
        PrintToChatAll("\x04[%s]:\x03 无法找到mp_restartgame变量!", MODNAME);
        SetFailState("[%s]: 无法找到mp_restartgame变量!", MODNAME);
    }
    HookConVarChange(g_hRestartGame, Mix_OnGameRestarted);

    // 获取服务器名称
    GetConVarString(g_hHostName, g_szHostName, sizeof(g_szHostName));

    // 重置地图列表状态
    g_bIsMapListGenerated = false;
    Mix_CreateMapList();

    // 检查当前地图是否可以移除道具
    Mix_CheckPropsForCurrentMap();
}

/**
 * 地图结束时调用
 */
void Mix_OnMapEnd()
{
    if (GetConVarInt(g_hCvarEnableAutoSourceTVRecord) == 1) {
        ServerCommand("tv_enable 1");
    }

    g_bIsRecording = false;
    g_bIsRecordManual = false;

    // 为防止换图后玩家数量变化，重置相关变量
    if (g_bHasVoteMap == false && g_bTenVoted == true) {
        g_bHasVoteMap = false;
        g_bTenVoted = false;
    }
}

/**
 * 当插件卸载时调用
 *
 * 此函数在插件被卸载前调用，用于清理资源和恢复游戏状态。
 */
void Mix_OnPluginEnd()
{
    // 停止任何正在进行的录制
    if (g_bIsRecording) {
        ServerCommand("tv_stoprecord");
        g_bIsRecording = false;
    }

    // 恢复购买区
    if (g_bIsBuyZoneDisabled) {
        Mix_EnableBuyZone();
    }

    // 关闭所有计时器
    if (g_hHudTimer != INVALID_HANDLE) {
        KillTimer(g_hHudTimer);
        g_hHudTimer = INVALID_HANDLE;
    }

    if (g_hReadyStatus != INVALID_HANDLE) {
        CloseHandle(g_hReadyStatus);
        g_hReadyStatus = INVALID_HANDLE;
    }

    // 关闭所有菜单句柄
    if (g_hMapListMenu != INVALID_HANDLE) {
        CloseHandle(g_hMapListMenu);
        g_hMapListMenu = INVALID_HANDLE;
    }

    if (g_hMixMenu != INVALID_HANDLE) {
        CloseHandle(g_hMixMenu);
        g_hMixMenu = INVALID_HANDLE;
    }

    if (g_hHelpPanel != INVALID_HANDLE) {
        CloseHandle(g_hHelpPanel);
        g_hHelpPanel = INVALID_HANDLE;
    }

    if (g_hWinTeamPanel != INVALID_HANDLE) {
        CloseHandle(g_hWinTeamPanel);
        g_hWinTeamPanel = INVALID_HANDLE;
    }

    // 移除服务器密码（如果启用了密码功能）
    if (GetConVarInt(g_hCvarEnablePasswords) == 1) {
        ServerCommand("sv_password \"\"");
    }
}

/**
 * 当游戏帧更新时调用
 *
 * 此函数在每个游戏帧更新时调用，可用于实现需要持续检查的功能。
 * 注意：此函数会被频繁调用，应避免在此执行耗时操作。
 */
void Mix_OnGameFrame()
{
    // 目前没有需要在每帧执行的操作
    // 保留此函数以便将来可能的扩展
}

/**
 * 版本改变时的回调
 */
public void Mix_OnVersionChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    SetConVarString(convar, PLUGIN_VERSION);
}

/**
 * 检查当前地图是否可以移除道具
 */
void Mix_CheckPropsForCurrentMap()
{
    char mapName[64];
    char propMaplist[2048];
    GetCurrentMap(mapName, sizeof(mapName));
    GetConVarString(g_hCvarDontRemovePropsMaps, propMaplist, sizeof(propMaplist));

    g_bIsMapValidToRemoveProps = true;
    if (StrContains(propMaplist, mapName) != -1) {
        g_bIsMapValidToRemoveProps = false;
    }
}

/**
 * 当客户端授权时调用
 */
void Mix_OnClientAuthorized(int client, const char[] auth)
{
    if (!IsFakeClient(client)) {
        char name[35];
        char auth2[35];
        GetClientName(client, name, sizeof(name));

        // 复制STEAM ID
        Format(auth2, sizeof(auth2), "%s", auth);

        // 记录最后进入的玩家信息
        g_szLastEntered_SteamID = auth2;
        g_szLastEntered_Name = name;

        if (g_bHasMixStarted) {
            // 通知玩家比赛正在进行
            CreateTimer(60.0, Mix_InformPlayerAboutTheMix, client);
        }
    }
}