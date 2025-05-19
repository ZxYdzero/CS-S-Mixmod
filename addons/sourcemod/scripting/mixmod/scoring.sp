/**
 * 积分系统模块
 */

#if defined _mixmod_scoring_included
  #endinput
#endif
#define _mixmod_scoring_included

/**
 * 显示当前比分
 *
 * @param client 显示比分的目标客户端
 */
void Mix_ShowScores(int client)
{
    if (client == 0 || !IsFakeClient(client)) {
        if (!g_bHasMixStarted) {
            PrintToChat(client, "\x04[%s]:\x03 比赛尚未开始...", MODNAME);
            return;
        }

        char teamAName[33];
        char teamBName[33];
        GetConVarString(g_hCvarCusomNameTeamCT, teamAName, sizeof(teamAName));
        GetConVarString(g_hCvarCusomNameTeamT, teamBName, sizeof(teamBName));

        if (g_iCurrentHalf == 1) {
            PrintToChat(client, "\x04[%s]:\x03 回合\x03 %d \x04- 半场\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_iCurrentRound, g_iCurrentHalf, teamAName, g_iCTScoreH1, teamBName, g_iTScoreH1);

            if (!g_bDidLiveStarted)
                PrintToChat(client, "\x04[%s]:\x03 尚未启动!", MODNAME);
        } else if (g_iCurrentHalf == 2) {
            PrintToChat(client, "\x04[%s]:\x03 回合\x03 %d \x04- 半场\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_iCurrentRound, g_iCurrentHalf, teamAName, g_iCTScore, teamBName, g_iTScore);

            if (GetConVarInt(g_hCvarMr3Enabled) == 1) {
                if ((g_iCTScore == 15) && (g_iTScore == 14))
                    PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s - \x04如果 %s 获胜，将加载Mr3!", MODNAME, teamAName, teamBName);
                else if ((g_iCTScore == 14) && (g_iTScore == 15))
                    PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s - \x04如果 %s 获胜，将加载Mr3!", MODNAME, teamBName, teamAName);
                else {
                    if (g_iCTScore == 15)
                        PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s", MODNAME, teamAName);
                    if (g_iTScore == 15)
                        PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s", MODNAME, teamBName);
                }
            } else {
                if (g_iCTScore == 15)
                    PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s", MODNAME, teamAName);
                if (g_iTScore == 15)
                    PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s", MODNAME, teamBName);
            }

            if (!g_bDidLiveStarted)
                PrintToChat(client, "\x04[%s]:\x03 尚未启动!", MODNAME);
        } else if (g_iCurrentHalf > 2) {
            PrintToChat(client, "\x04[%s]:\x03 回合\x03 %d \x04- 半场\x03 %d\x04 /\x03 4\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_iCurrentRound, g_iCurrentHalf, teamAName, g_iCTScore, teamBName, g_iTScore);

            if (g_iCTScore == 18)
                PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s", MODNAME, teamAName);
            if (g_iTScore == 18)
                PrintToChatAll("\x04[%s]:\x03 赛点 \x04for\x03 %s", MODNAME, teamBName);

            if (!g_bDidLiveStarted)
                PrintToChat(client, "\x04[%s]:\x03 尚未启动!", MODNAME);
        }
    }
}

/**
 * 显示队伍金钱和武器状况
 */
void Mix_ShowTeamMoneyAndWeapons()
{
    if (g_bHasMixStarted && g_iAccount != -1) {
        int show = GetConVarInt(g_hCvarShowCashInPanel);
        bool wasMaxed[MAXPLAYERS + 1] = {false, ...};

        if (show == 0) {  // 在聊天框中显示
            char name[MAX_NAME_LENGTH], msg[150];
            int team, money, i, max = 0, pos = -1;
            PrintToChatAll("----------------------------");

            while (max != -1) {
                max = -1;
                for (i = 1; i <= MaxClients; i++) {
                    if (wasMaxed[i])
                        continue;

                    if (!IsClientInGame(i) || !IsClientInGame(i)) {
                        wasMaxed[i] = true;
                        continue;
                    }

                    team = GetClientTeam(i);
                    if (team <= 1) {
                        wasMaxed[i] = true;
                        continue;
                    }

                    money = GetEntProp(i, Prop_Send, "m_iAccount");
                    if (max < money) {
                        max = money;
                        pos = i;
                    }
                }

                if (max == -1)  // 循环已结束
                    continue;

                GetClientName(pos, name, sizeof(name));
                if (GetPlayerWeaponSlot(pos, 0) != -1)
                    Format(msg, sizeof(msg), "\x04 %s:\x03 %d+", name, max);
                else
                    Format(msg, sizeof(msg), "\x04 %s:\x03 %d", name, max);

                team = GetClientTeam(pos);
                Mix_PrintToTeamChat(team, msg);
                wasMaxed[pos] = true;
            }
        } else if (show == 1) {  // 在面板中显示
            char name[MAX_NAME_LENGTH], msg[150];
            int team, money, i, max = 0, pos = -1;

            char teamAName[32], teamBName[32];
            GetConVarString(g_hCvarCusomNameTeamCT, teamAName, sizeof(teamAName));
            GetConVarString(g_hCvarCusomNameTeamT, teamBName, sizeof(teamBName));

            char titleCtFormat[64], titleTFormat[64];
            Format(titleCtFormat, sizeof(titleCtFormat), "%s cash: ", teamAName);
            Format(titleTFormat, sizeof(titleTFormat), "%s cash: ", teamBName);

            // 创建团队金钱面板
            Handle panelT = CreatePanel();
            Handle panelCT = CreatePanel();
            SetPanelTitle(panelT, MODNAME);
            DrawPanelText(panelT, titleTFormat);
            DrawPanelItem(panelT, "-------------------------", ITEMDRAW_SPACER);
            SetPanelTitle(panelCT, MODNAME);
            DrawPanelText(panelCT, titleCtFormat);
            DrawPanelItem(panelCT, "-------------------------", ITEMDRAW_SPACER);

            while (max != -1) {
                max = -1;
                for (i = 1; i <= MaxClients; i++) {
                    if (wasMaxed[i])
                        continue;

                    if (!IsClientInGame(i) || !IsClientInGame(i)) {
                        wasMaxed[i] = true;
                        continue;
                    }

                    team = GetClientTeam(i);
                    if (team <= 1) {
                        wasMaxed[i] = true;
                        continue;
                    }

                    money = GetEntProp(i, Prop_Send, "m_iAccount");
                    if (max < money) {
                        max = money;
                        pos = i;
                    }
                }

                if (max == -1)  // 循环已结束
                    continue;

                GetClientName(pos, name, sizeof(name));
                if (GetPlayerWeaponSlot(pos, 0) != -1)
                    Format(msg, sizeof(msg), "%s: %d+", name, max);
                else
                    Format(msg, sizeof(msg), "%s: %d", name, max);

                team = GetClientTeam(pos);

                if (team == TEAM_CT)
                    DrawPanelItem(panelCT, msg);
                else if (team == TEAM_T)
                    DrawPanelItem(panelT, msg);

                wasMaxed[pos] = true;
            }

            DrawPanelItem(panelT, "-------------------------", ITEMDRAW_SPACER);
            DrawPanelItem(panelT, "关闭", ITEMDRAW_CONTROL);
            SetPanelCurrentKey(panelT, 10);
            DrawPanelItem(panelCT, "-------------------------", ITEMDRAW_SPACER);
            DrawPanelItem(panelCT, "关闭", ITEMDRAW_CONTROL);
            SetPanelCurrentKey(panelCT, 10);

            for (int j = 1; j <= MaxClients; j++) {
                if (IsClientInGame(j) && !IsFakeClient(j)) {
                    team = GetClientTeam(j);
                    if (team == TEAM_T)
                        SendPanelToClient(panelT, j, Mix_HandleDoNothing, (GetConVarInt(g_hFreezeTime) - 1));
                    else if (team == TEAM_CT)
                        SendPanelToClient(panelCT, j, Mix_HandleDoNothing, (GetConVarInt(g_hFreezeTime) - 1));
                }
            }

            CloseHandle(panelT);
            CloseHandle(panelCT);
        }
    }
}

/**
 * 向特定队伍的所有成员发送消息
 *
 * @param team 目标队伍
 * @param message 要发送的消息
 */
void Mix_PrintToTeamChat(int team, const char[] message)
{
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && GetClientTeam(i) == team) {
            PrintToChat(i, "%s", message);
        }
    }
}

/**
 * 创建获胜队伍面板
 *
 * @param team 获胜队伍，1=平局，2=T获胜，3=CT获胜
 */
void Mix_CreateWinningTeamPanel(int team)
{
    if (g_hWinTeamPanel != INVALID_HANDLE) {
        CloseHandle(g_hWinTeamPanel);
    }

    // 输出调试信息
    PrintToChatAll("\x04[%s]:\x03 Mix_CreateWinningTeamPanel被调用，胜利队伍=%d", MODNAME, team);

    char teamAName[32];
    char teamBName[32];
    GetConVarString(g_hCvarCusomNameTeamCT, teamAName, sizeof(teamAName));
    GetConVarString(g_hCvarCusomNameTeamT, teamBName, sizeof(teamBName));

    char titleFormat[32];
    char teamNameFormat[150];
    Format(titleFormat, sizeof(titleFormat), "%s - 获胜队伍\n -", MODNAME);

    g_hWinTeamPanel = CreatePanel();
    SetPanelTitle(g_hWinTeamPanel, titleFormat);
    DrawPanelItem(g_hWinTeamPanel, "", ITEMDRAW_SPACER);

    if (team == 3)
        Format(teamNameFormat, sizeof(teamNameFormat), "--------------\n比赛结束\n\n *** 获胜者是 ***\n  -* %s *- \n------------", teamAName);
    else if (team == 2)
        Format(teamNameFormat, sizeof(teamNameFormat), "--------------\n比赛结束\n\n *** 获胜者是 ***\n  -* %s *- \n------------", teamBName);
    else if (team == 1)
        Format(teamNameFormat, sizeof(teamNameFormat), "--------------\n比赛结束\n\n *** 平局 ***\n \n------------");

    DrawPanelText(g_hWinTeamPanel, teamNameFormat);
    DrawPanelItem(g_hWinTeamPanel, "", ITEMDRAW_SPACER);

    SetPanelCurrentKey(g_hWinTeamPanel, 10);
    DrawPanelItem(g_hWinTeamPanel, "关闭", ITEMDRAW_CONTROL);

    for (int i = 1; i <= MaxClients; i++) {
        if(IsClientInGame(i) && !IsFakeClient(i)) {
            SendPanelToClient(g_hWinTeamPanel, i, Mix_HandleDoNothing, 30);
        }
    }

    // 调用API事件
    Mix_API_OnMixEnd(team, g_iCTScore, g_iTScore);

    CreateTimer(2.0, Mix_DisplayScores);
}

/**
 * 显示MVP和分数信息
 */
public Action Mix_DisplayScores(Handle timer)
{
    int max = 0;
    int winner = -1;

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientConnected(i)) {
            if (g_iScoresOfTheGame[i] >= max) {
                max = g_iScoresOfTheGame[i];
                winner = i;
            }
        }
    }

    if (winner < 1) {
        PrintToChatAll("\x04[%s]:\x03 尝试查找MVP玩家时出错...", MODNAME);
        return Plugin_Continue;
    }

    char winnerName[33];
    GetClientName(winner, winnerName, sizeof(winnerName));
    int kills = g_iScoresOfTheGame[winner];

    PrintToChatAll("\x04[%s]:\x03 击杀统计:", MODNAME);
    PrintToChatAll("------------------");
    PrintToChatAll("\x03 - \x01MVP:\x04 %s , \x03击杀数:\x04 %d \x03!", winnerName, kills);

    Mix_StopRecord(0, 0);  // 停止录制

    return Plugin_Continue;
}

/**
 * 显示玩家MVP信息
 *
 * @param client 目标客户端
 */
void Mix_ShowMVP(int client)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        if (!g_bHasMixStarted) {
            PrintToChat(client, "\x04[%s]:\x03 比赛尚未开始", MODNAME);
            return;
        }

        if (GetConVarInt(g_hCvarShowMVP) == 0) {
            PrintToChat(client, "\x04[%s]:\x03 MVP数据显示已禁用", MODNAME);
            return;
        }

        int max = 0;
        int index = -1;

        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientConnected(i)) {
                if (g_iScoresOfTheGame[i] >= max) {
                    max = g_iScoresOfTheGame[i];
                    index = i;
                }
            }
        }

        char mvpName[33];
        GetClientName(index, mvpName, sizeof(mvpName));
        int kills = g_iScoresOfTheGame[index];

        if (kills <= 0) {
            PrintToChat(client, "\x04[%s]:\x03 MVP尚未产生，请稍候", MODNAME);
            return;
        }

        PrintToChat(client, "\x04[%s]:\x03 MVP:", MODNAME);
        PrintToChat(client, "------------------");
        PrintToChat(client, "\x03 - \x01MVP:\x04 %s , 击杀数:\x04 %d 个敌人！", mvpName, kills);

        if (index == client)
            return;

        char clientName[33];
        GetClientName(client, clientName, sizeof(clientName));
        PrintToChat(client, "\x03 你击杀了 \x04 %d \x03 个敌人", g_iScoresOfTheGame[client]);
    }
}

/**
 * 创建比赛结束时的信息提示
 *
 * @param timer 定时器句柄
 * @param team  胜利的队伍
 */
public Action Mix_InformMatchEnd(Handle timer, int team)
{
    char teamAName[32];
    char teamBName[32];
    GetConVarString(g_hCvarCusomNameTeamCT, teamAName, sizeof(teamAName));
    GetConVarString(g_hCvarCusomNameTeamT, teamBName, sizeof(teamBName));

    // 输出调试信息
    PrintToChatAll("\x04[%s]:\x03 Mix_InformMatchEnd被调用，胜利队伍=%d", MODNAME, team);

    PrintToChatAll("\x04--- Mix-Plugin created by iDragon ---");
    PrintToChatAll("\x04[%s]:\x03 比赛结束", MODNAME);

    if (team == 3)
        PrintToChatAll("\x04[%s]: \x03获胜者是:\x04 %s", MODNAME, teamAName);
    else if (team == 2)
        PrintToChatAll("\x04[%s]: \x03获胜者是:\x04 %s", MODNAME, teamBName);
    else if (team == 1)
        PrintToChatAll("\x04[%s]: \x03平局.\x04 |IT'S A DRAW!", MODNAME);

    // 调用API事件
    Mix_API_OnMixEnd(team, g_iCTScore, g_iTScore);

    CreateTimer(2.0, Mix_DisplayScores);

    if (g_bIsBuyZoneDisabled) {
        if (Mix_EnableBuyZone()) {
            g_bIsBuyZoneDisabled = false;
        }
    }

    return Plugin_Continue;
}