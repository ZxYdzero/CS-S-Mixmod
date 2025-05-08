/**
 * 准备系统模块
 */

#if defined _mixmod_ready_included
  #endinput
#endif
#define _mixmod_ready_included

/**
 * 更新准备系统状态
 */
void Mix_UpdateReadySystem()
{
    if (GetConVarInt(g_hCvarAutoMixEnabled) == 1 && !g_bHasMixStarted) {
        // 如果已有10名玩家准备就绪
        if (g_iReadyCount >= 10) {
            if (GetConVarInt(g_hCvarAutoMixRandomize) == 1) {
                PrintToChatAll("\x04[%s]:\x03 10名玩家已准备就绪，正在随机分配队伍...", MODNAME);
                Mix_RandomizeTeams();
                
                g_bIsItManual = false;
                Mix_StartLive(0);
            } else if (!g_bHasVoteMap && !g_bTenVoted) {
                PrintToChatAll("\x04[%s]:\x03 10名玩家已准备就绪，开始地图投票...", MODNAME);
                Mix_VoteMap();
                g_bTenVoted = true;
            }
        }
    }
}

Action Mix_CreateReadyPanel() 
{ 
    if (g_hReadyStatus != INVALID_HANDLE) { 
        CloseHandle(g_hReadyStatus); 
        g_hReadyStatus = INVALID_HANDLE; 
    }
    g_hReadyStatus = CreatePanel(); 
    
    char title[64]; 
    Format(title, sizeof(title), "%s - 准备系统", MODNAME); 
    SetPanelTitle(g_hReadyStatus, title); 
    DrawPanelItem(g_hReadyStatus, "", ITEMDRAW_SPACER);

    // 可用指令 (整合并扩展自 UpdateReadyPanel 和 Mix_CreateReadyPanel)
    DrawPanelText(g_hReadyStatus, "=====<- 指令与状态 ->=====");
    DrawPanelText(g_hReadyStatus, "输入 !ready 或 !r 准备"); 
    DrawPanelText(g_hReadyStatus, "输入 !notready 或 !nr 取消准备");
    DrawPanelText(g_hReadyStatus, "输入 !sp 切换菜单显示");
    DrawPanelText(g_hReadyStatus, "提示: 十人准备后可投票换图 ");
    DrawPanelText(g_hReadyStatus, "无 RTV / Nominate 功能");

    DrawPanelItem(g_hReadyStatus, "", ITEMDRAW_SPACER); 

    char readyLine[128]; 

    DrawPanelText(g_hReadyStatus, readyLine); 
    DrawPanelText(g_hReadyStatus, "\n"); // 添加一些间隔


    decl String:sReadyPlayersList[512];     // 存储已准备玩家列表的字符串
    decl String:sNotReadyPlayersList[512];  // 存储未准备玩家列表的字符串
    decl String:sSpectatorsList[512];       // 存储观察者列表的字符串
    decl String:sPlayerName[MAX_NAME_LENGTH]; // 存储单个玩家名称

    // 初始化列表字符串为空
    Format(sReadyPlayersList, sizeof(sReadyPlayersList), "");
    Format(sNotReadyPlayersList, sizeof(sNotReadyPlayersList), "");
    Format(sSpectatorsList, sizeof(sSpectatorsList), "");


    for (new i = 1; i <= MaxClients; i++) 
    { 
        if (IsClientInGame(i) && !IsClientSourceTV(i) && !IsClientReplay(i))
        { 
            GetClientName(i, sPlayerName, sizeof(sPlayerName)); 
            
            if (GetClientTeam(i) == CS_TEAM_SPECTATOR) { 
                Format(sSpectatorsList, sizeof(sSpectatorsList), "%s%s\n", sSpectatorsList, sPlayerName); 
            } else {
                if (g_bReadyPlayers[i]) 
                { 
                    Format(sReadyPlayersList, sizeof(sReadyPlayersList), "%s%s\n", sReadyPlayersList, sPlayerName); 
                    // actualReadyCount++;
                } 
                else 
                { 
                    Format(sNotReadyPlayersList, sizeof(sNotReadyPlayersList), "%s%s\n", sNotReadyPlayersList, sPlayerName); 
                }
            }
        } 
    }


    // 显示已准备玩家列表
    DrawPanelItem(g_hReadyStatus, "--- 已准备 ---");
    if (sReadyPlayersList[0] == '\0') {
        DrawPanelText(g_hReadyStatus, "(无)");
    } else {
        DrawPanelText(g_hReadyStatus, sReadyPlayersList);
    }
    DrawPanelText(g_hReadyStatus, "\n");

    // 显示未准备玩家列表
    DrawPanelItem(g_hReadyStatus, "--- 未准备 ---");
    if (sNotReadyPlayersList[0] == '\0') {
        DrawPanelText(g_hReadyStatus, "(无)");
    } else {
        DrawPanelText(g_hReadyStatus, sNotReadyPlayersList);
    }
    DrawPanelText(g_hReadyStatus, "\n");

    // 显示观察者列表
    DrawPanelItem(g_hReadyStatus, "--- 观察者 ---");
    if (sSpectatorsList[0] == '\0') {
        DrawPanelText(g_hReadyStatus, "(无)");
    } else {
        DrawPanelText(g_hReadyStatus, sSpectatorsList);
    }
    
    DrawPanelItem(g_hReadyStatus, "", ITEMDRAW_SPACER); 

    DrawPanelItem(g_hReadyStatus, "", ITEMDRAW_SPACER); 
    // 将面板显示给所有符合条件的客户端 
    for (int i = 1; i <= MaxClients; i++) { 
        if (IsClientInGame(i) && !IsFakeClient(i) && !g_bHidePanel[i]) { 
            SendPanelToClient(g_hReadyStatus, i, Mix_HandleDoNothing, 1); 
        } 
    } 
}

/**
 * 重置所有玩家的准备状态
 */
void Mix_ResetReadySystem()
{
    g_bAllowReady = true;
    g_iReadyCount = 0;
    
    for (int i = 1; i <= MaxClients; i++) {
        g_bReadyPlayers[i] = false;
        g_iReadyPlayersData[i] = -1;
    }
}

/**
 * 准备系统倒计时定时器
 * 用于在达到10名准备玩家后，倒计时踢出未准备的玩家
 */
public Action Mix_ReadyCountdownTimer(Handle timer, any data)
{
    if (g_iSecond <= 0) {
        // 倒计时结束，踢出未准备的玩家
        if (!g_bIsKicked) {
            g_bIsKicked = true;
            
            for (int i = 1; i <= MaxClients; i++) {
                if (IsClientInGame(i) && !IsFakeClient(i)) {
                    if (!g_bReadyPlayers[i]) {
                        KickClient(i, "[%s]: 你没有准备就绪，已被踢出服务器!", MODNAME);
                    }
                }
            }
        }
        
        return Plugin_Stop;
    } else {
        // 更新倒计时并通知所有玩家
        PrintCenterTextAll("未准备玩家将在 %d 秒后被踢出", g_iSecond);
        g_iSecond--;
        
        return Plugin_Continue;
    }
}
