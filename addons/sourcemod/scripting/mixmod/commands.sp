/**
 * 命令处理模块
 */

#if defined _mixmod_commands_included
  #endinput
#endif
#define _mixmod_commands_included

/**
 * 初始化命令系统
 */
void Mix_InitCommands()
{
    // 玩家命令
    RegConsoleCmd("sm_score", Mix_Command_Score, "显示当前比分");
    RegConsoleCmd("sm_mvp", Mix_Command_MVP, "显示当前MVP");
    RegConsoleCmd("sm_ready", Mix_Command_Ready, "设置为准备状态");
    RegConsoleCmd("sm_r", Mix_Command_Ready, "设置为准备状态 (缩写)");
    RegConsoleCmd("sm_notready", Mix_Command_NotReady, "设置为未准备状态");
    RegConsoleCmd("sm_nr", Mix_Command_NotReady, "设置为未准备状态 (缩写)");
    RegConsoleCmd("sm_sp", Mix_Command_ShowHidePanel, "显示或隐藏指南");
    RegConsoleCmd("sm_help", Mix_Command_Help, "显示帮助");
    
    // 管理员命令
    RegAdminCmd("sm_mix", Mix_Command_Mix, ACCESS_FLAG, "显示Mix管理菜单");
    RegAdminCmd("sm_mr12", Mix_Command_Mr12, ACCESS_FLAG, "执行mr12.cfg并开始满十");
    RegAdminCmd("sm_live", Mix_Command_Mr12, ACCESS_FLAG, "执行mr12.cfg并开始满十");
    RegAdminCmd("sm_prac", Mix_Command_Prac, ACCESS_FLAG, "恢复热身模式");
    RegAdminCmd("sm_warmup", Mix_Command_Prac, ACCESS_FLAG, "恢复热身模式 (别名)");
    RegAdminCmd("sm_map", Mix_Command_Map, ACCESS_FLAG, "显示地图列表");
    RegAdminCmd("sm_rr", Mix_Command_RestartRound, ACCESS_FLAG, "重启当前回合");
    RegAdminCmd("sm_swap", Mix_Command_SwapTeams, ACCESS_FLAG, "交换队伍");
    RegAdminCmd("sm_record", Mix_Command_Record, ACCESS_FLAG, "开始录制");
    RegAdminCmd("sm_stop", Mix_Command_StopRecord, ACCESS_FLAG, "停止录制");
    RegAdminCmd("sm_kickct", Mix_Command_KickCT, ACCESS_FLAG, "踢出所有CT");
    RegAdminCmd("sm_kickt", Mix_Command_KickT, ACCESS_FLAG, "踢出所有T");
    RegAdminCmd("sm_random", Mix_Command_Random, ACCESS_FLAG, "随机分配队伍");
    RegAdminCmd("sm_ko3", Mix_Command_Ko3, ACCESS_FLAG, "开始刀局");
    RegAdminCmd("sm_forceready", Mix_Command_ForceReady, ACCESS_FLAG, "强制所有玩家准备");
    RegAdminCmd("sm_mapvote", Mix_Command_MapVote, ACCESS_FLAG, "管理员强制开启地图投票");
    
    // 密码相关命令
    RegAdminCmd("sm_password", Mix_Command_Password, ACCESS_FLAG, "设置服务器密码");
    RegAdminCmd("sm_removepassword", Mix_Command_RemovePassword, ACCESS_FLAG, "移除服务器密码");
    RegAdminCmd("sm_rpass", Mix_Command_RemovePassword, ACCESS_FLAG, "移除服务器密码 (别名)");
    RegAdminCmd("sm_rpw", Mix_Command_RandomPassword, ACCESS_FLAG, "设置随机密码");
    
    // 玩家管理命令
    RegAdminCmd("sm_spec", Mix_Command_Spec, ACCESS_FLAG, "将玩家移至观察者");
    RegAdminCmd("sm_mmute", Mix_Command_Mute, ACCESS_FLAG, "静音指定玩家");
    RegAdminCmd("sm_mgag", Mix_Command_Gag, ACCESS_FLAG, "禁言指定玩家");
}

// ...existing code...

/**
 * 显示比分命令
 */
public Action Mix_Command_Score(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_ShowScores(client);
    }
    return Plugin_Handled;
}

/**
 * 显示MVP命令
 */
public Action Mix_Command_MVP(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_ShowMVP(client);
    }
    return Plugin_Handled;
}

/**
 * 准备命令
 */
public Action Mix_Command_Ready(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1 && GetConVarInt(g_hCvarAutoMixEnabled) == 1) {
        if (!g_bAllowReady) {
            PrintToChat(client, "\x04[%s]:\x03 准备系统当前已禁用", MODNAME);
            return Plugin_Handled;
        }
        if (g_bHasMixStarted) {
            PrintToChat(client, "\x04[%s]:\x03 比赛已在进行中", MODNAME);
            return Plugin_Handled;
        }
        if (!g_bReadyPlayers[client]) {
            g_bReadyPlayers[client] = true;
            g_iReadyCount++;
            char name[MAX_NAME_LENGTH];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 %s 已准备就绪! (%d/10)", MODNAME, name, g_iReadyCount);

            if (g_iReadyCount >= 10) {
                Mix_HideReadyPanel();
                if (!g_bTenVoted) {
                    PrintToChatAll("\x04[%s]:\x03 10名玩家已准备，开始地图投票...", MODNAME);
                    Mix_VoteMap();
                    g_bTenVoted = true;
                } else {
                    PrintToChatAll("\x04[%s]:\x03 10名玩家再次准备完毕...", MODNAME);
                    // 分队/拼刀
                    if (GetConVarInt(g_hCvarAutoMixRandomize) == 1) {
                        PrintToChatAll("\x04[%s]:\x03 正在随机分配队伍...", MODNAME);
                        Mix_RandomizeTeams();
                        g_bIsItManual = false;
                        if (GetConVarInt(g_hCvarEnableKnifeRound) == 1) {
                            PrintToChatAll("\x04[%s]:\x03 进入拼刀选边...", MODNAME);
                            Mix_StartKnifeRound(0);
                        } else {
                            Mix_StartLive(0);
                        }
                    } else {
                        if (GetConVarInt(g_hCvarEnableKnifeRound) == 1) {
                            PrintToChatAll("\x04[%s]:\x03 进入拼刀选边...", MODNAME);
                            Mix_StartKnifeRound(0);
                        } else {
                            Mix_StartLive(0);
                        }
                    }
                    g_bTenVoted = false;
                }
            } else {
                Mix_ShowReadyPanel();
            }
        } else {
            PrintToChat(client, "\x04[%s]:\x03 你已经准备就绪了!", MODNAME);
        }
    }
    return Plugin_Handled;
}

/**
 * 取消准备命令
 */
public Action Mix_Command_NotReady(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1 && GetConVarInt(g_hCvarAutoMixEnabled) == 1) {
        if (!g_bAllowReady) {
            PrintToChat(client, "\x04[%s]:\x03 准备系统当前已禁用", MODNAME);
            return Plugin_Handled;
        }
        if (g_bHasMixStarted) {
            PrintToChat(client, "\x04[%s]:\x03 比赛已在进行中", MODNAME);
            return Plugin_Handled;
        }
        if (g_bReadyPlayers[client]) {
            g_bReadyPlayers[client] = false;
            g_iReadyCount--;
            char name[MAX_NAME_LENGTH];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 %s 取消了准备状态! (%d/10)", MODNAME, name, g_iReadyCount);
            Mix_ShowReadyPanel(); // 有人取消准备，重新显示面板
        } else {
            PrintToChat(client, "\x04[%s]:\x03 你还未准备!", MODNAME);
        }
    }
    return Plugin_Handled;
}

/**
 * 显示/隐藏面板命令
 */
public Action Mix_Command_ShowHidePanel(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        g_bHidePanel[client] = !g_bHidePanel[client];
        
        if (g_bHidePanel[client]) {
            PrintToChat(client, "\x04[%s]:\x03 面板已隐藏", MODNAME);
        } else {
            PrintToChat(client, "\x04[%s]:\x03 面板已显示", MODNAME);
        }
    }
    return Plugin_Handled;
}

/**
 * 显示帮助命令
 */
public Action Mix_Command_Help(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_ShowHelp(client);
    }
    return Plugin_Handled;
}

/**
 * 显示Mix菜单命令
 */
public Action Mix_Command_Mix(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_CreateMainMixMenu(client);
    }
    return Plugin_Handled;
}

/**
 * 开始Mr12配置命令
 */
public Action Mix_Command_Mr12(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_StartLive(client);
    }
    return Plugin_Handled;
}

/**
 * 恢复热身命令
 */
public Action Mix_Command_Prac(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_ExecutePracConfig(client);
    }
    return Plugin_Handled;
}

/**
 * 显示地图列表命令
 */
public Action Mix_Command_Map(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        if (!g_bIsMapListGenerated) {
            Mix_CreateMapList();
        }
        if (g_hMapListMenu != INVALID_HANDLE) {
            CloseHandle(g_hMapListMenu);
            g_hMapListMenu = INVALID_HANDLE; // 重置为无效
        }
        DisplayMenu(g_hMapListMenu, client, MENU_TIME_FOREVER);
    }
    return Plugin_Handled;
}

/**
 * 管理员强制开启地图投票命令
 */
public Action Mix_Command_MapVote(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_VoteMap();
    }
    return Plugin_Handled;
}

/**
 * 重启回合命令
 */
public Action Mix_Command_RestartRound(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_RestartRound(client);
    }
    return Plugin_Handled;
}

/**
 * 交换队伍命令
 */
public Action Mix_Command_SwapTeams(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_SwapTeams();
    }
    return Plugin_Handled;
}

/**
 * 开始录制命令
 */
public Action Mix_Command_Record(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_StartRecord(client);
    }
    return Plugin_Handled;
}

/**
 * 停止录制命令
 */
public Action Mix_Command_StopRecord(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_StopRecord(client, 1);
    }
    return Plugin_Handled;
}

/**
 * 踢出CT命令
 */
public Action Mix_Command_KickCT(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_KickTeam(client, TEAM_CT, GetConVarInt(g_hCvarKickAdmins));
    }
    return Plugin_Handled;
}

/**
 * 踢出T命令
 */
public Action Mix_Command_KickT(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_KickTeam(client, TEAM_T, GetConVarInt(g_hCvarKickAdmins));
    }
    return Plugin_Handled;
}

/**
 * 随机分配队伍命令
 */
public Action Mix_Command_Random(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_RandomizeTeams();
    }
    return Plugin_Handled;
}

/**
 * 开始刀局命令
 */
public Action Mix_Command_Ko3(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_StartKnifeRound(client);
    }
    return Plugin_Handled;
}

/**
 * 强制所有玩家准备命令
 */
public Action Mix_Command_ForceReady(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1 && GetConVarInt(g_hCvarAutoMixEnabled) == 1) {
        int added = 0;
        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && !IsFakeClient(i) && !g_bReadyPlayers[i]) {
                // 让每个未准备玩家都走一遍Mix_Command_Ready流程
                Mix_Command_Ready(i, 0);
                added++;
            }
        }
        PrintToChatAll("\x04[%s]:\x03 管理员已强制所有玩家准备!", MODNAME);
    }
    return Plugin_Handled;
}

/**
 * 设置密码命令
 */
public Action Mix_Command_Password(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_HandlePasswordCommand(client, "password");
    }
    return Plugin_Handled;
}

/**
 * 移除密码命令
 */
public Action Mix_Command_RemovePassword(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_RemovePassword(client);
    }
    return Plugin_Handled;
}

/**
 * 设置随机密码命令
 */
public Action Mix_Command_RandomPassword(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        Mix_SetRandomPassword(client);
    }
    return Plugin_Handled;
}

/**
 * 将玩家移至观察者命令
 */
public Action Mix_Command_Spec(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        if (args < 1) {
            PrintToChat(client, "\x04[%s]:\x03 用法: !spec <玩家名称/ID>", MODNAME);
            return Plugin_Handled;
        }
        
        char arg[64];
        GetCmdArg(1, arg, sizeof(arg));
        
        int target = FindTarget(client, arg);
        if (target != -1) {
            Mix_MoveToSpectator(client, target);
        }
    }
    return Plugin_Handled;
}

/**
 * 静音玩家命令
 */
public Action Mix_Command_Mute(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1 && GetConVarInt(g_hCvarEnableVoiceCommands) == 1) {
        if (args < 1) {
            PrintToChat(client, "\x04[%s]:\x03 用法: !mmute <玩家名称/ID>", MODNAME);
            return Plugin_Handled;
        }
        
        char arg[64];
        GetCmdArg(1, arg, sizeof(arg));
        
        int target = FindTarget(client, arg);
        if (target != -1) {
            g_bMutedPlayers[target] = !g_bMutedPlayers[target];
            
            char name[MAX_NAME_LENGTH];
            GetClientName(target, name, sizeof(name));
            
            if (g_bMutedPlayers[target]) {
                SetClientListeningFlags(target, VOICE_MUTED);
                PrintToChatAll("\x04[%s]:\x03 %s 被静音了", MODNAME, name);
            } else {
                SetClientListeningFlags(target, VOICE_NORMAL);
                PrintToChatAll("\x04[%s]:\x03 %s 取消了静音", MODNAME, name);
            }
        }
    }
    return Plugin_Handled;
}

/**
 * 禁言玩家命令
 */
public Action Mix_Command_Gag(int client, int args)
{
    if (GetConVarInt(g_hCvarEnabled) == 1 && GetConVarInt(g_hCvarEnableVoiceCommands) == 1) {
        if (args < 1) {
            PrintToChat(client, "\x04[%s]:\x03 用法: !mgag <玩家名称/ID>", MODNAME);
            return Plugin_Handled;
        }
        
        char arg[64];
        GetCmdArg(1, arg, sizeof(arg));
        
        int target = FindTarget(client, arg);
        if (target != -1) {
            g_bGaggedPlayers[target] = !g_bGaggedPlayers[target];
            
            char name[MAX_NAME_LENGTH];
            GetClientName(target, name, sizeof(name));
            
            if (g_bGaggedPlayers[target]) {
                PrintToChatAll("\x04[%s]:\x03 %s 被禁言了", MODNAME, name);
            } else {
                PrintToChatAll("\x04[%s]:\x03 %s 取消了禁言", MODNAME, name);
            }
        }
    }
    return Plugin_Handled;
}

/**
 * 游戏重启事件回调
 */
public void Mix_OnGameRestarted(ConVar convar, const char[] oldValue, const char[] newValue)
{
    int value = StringToInt(newValue);
    if (value > 0) {
        if (g_bHasMixStarted && g_bDidLiveStarted && !g_bIsKo3Running) {
            g_bSaveClientsScore = true;
            
            for (int i = 1; i <= MaxClients; i++) {
                if (IsClientInGame(i)) {
                    g_iScoresOfTheGame[i] = GetEntProp(i, Prop_Data, "m_iFrags");
                    g_iDeathsOfTheGame[i] = GetEntProp(i, Prop_Data, "m_iDeaths");
                }
            }
        }
    }
}