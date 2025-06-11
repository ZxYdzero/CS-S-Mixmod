/**
 * 事件处理模块
 */

#if defined _mixmod_events_included
  #endinput
#endif
#define _mixmod_events_included

/**
 * 初始化事件钩子
 */
void Mix_InitEvents()
{
    // 注册游戏事件
    HookEvent("round_start", Mix_Event_RoundStart);
    HookEvent("round_end", Mix_Event_RoundEnd);
    HookEvent("bomb_exploded", Mix_Event_BombExploded);
    HookEvent("bomb_defused", Mix_Event_BombDefused);
    HookEvent("bomb_planted", Mix_Event_BombPlanted);
    HookEvent("player_spawn", Mix_Event_PlayerSpawn);
    HookEvent("player_hurt", Mix_Event_PlayerHurt);
    HookEvent("player_death", Mix_Event_PlayerDeath);
    HookEvent("player_disconnect", Mix_Event_PlayerDisconnect);
    HookEvent("weapon_fire", Mix_Event_WeaponFire);
}

/**
 * 玩家生成事件
 */
public Action Mix_Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if (g_bMutedPlayers[client]) {
        SetClientListeningFlags(client, VOICE_MUTED);
    }

    if (GetConVarInt(g_hCvarShowMVP) == 1) {
        g_iScoresOfTheRound[client] = 0;
    }

    if (g_bSaveClientsScore && (GetConVarInt(g_hCvarShowMVP) == 1)) {
        if (IsClientInGame(client)) {
            SetEntProp(client, Prop_Data, "m_iFrags", g_iScoresOfTheGame[client]);
            SetEntProp(client, Prop_Data, "m_iDeaths", g_iDeathsOfTheGame[client]);
        }
    }

    return Plugin_Continue;
}

/**
 * 回合开始事件
 */
public Action Mix_Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    Mix_HudUpdate();

    // 只有在比赛正式开始后才更新统计数据
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_Stats_OnRoundStart();
    }

    // 调用API事件
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_API_OnRoundStart(g_iCurrentRound, g_iCurrentHalf);
    }

    if (GetConVarInt(g_hCvarEnabled) == 1) {
        if (g_bIsKo3Running) {
            if (GetConVarInt(g_hCvarHalfAutoLiveStart) == 1) {
                PrintToChatAll("\x04[%s]:\x03 %t", MODNAME, "Knife Round Started");
            } else if (g_bHasMixStarted) {
                PrintToChatAll("\x04[%s]:\x03 %t", MODNAME, "Knife Round Started");
                PrintToChatAll("\x04[%s]:\x03 %t", MODNAME, "Type Live");
            }

            for (int i = 1; i <= MaxClients; i++) {
                if (!IsClientInGame(i) || !IsPlayerAlive(i)) {
                    continue;
                }
                Mix_RemovePlayerGuns(i);
                SetEntProp(i, Prop_Send, "m_bHasHelmet", 1);
                SetEntProp(i, Prop_Send, "m_ArmorValue", 100);
            }

            PrintToChatAll("\x04[%s]:\x03 %t", MODNAME, "Knife Round Info");
            return Plugin_Continue;
        }

        if (g_bHasMixStarted) {
            if (GetConVarInt(g_hCvarRemoveProps) == 1) {
                Mix_RemoveProps();
            }

            char teamAName[32];
            char teamBName[32];
            GetConVarString(g_hCvarCusomNameTeamCT, teamAName, sizeof(teamAName));
            GetConVarString(g_hCvarCusomNameTeamT, teamBName, sizeof(teamBName));

            if ((g_iTScoreH1 == -1) || (g_iCTScoreH1 == -1)) {
                g_iTScoreH1 = 0;
                g_iCTScoreH1 = 0;
            }

            // 确保记分板显示正确的分数
            SetTeamScore(3, g_iCTScoreH1);
            SetTeamScore(2, g_iTScoreH1);

            if (g_iCurrentHalf == 1) {
                if (g_iCurrentRound == 0) {
                    g_iCurrentRound = 1;
                }

                if (g_iCurrentRound > (g_iCTScoreH1 + g_iTScoreH1 + 1)) {
                    g_iCurrentRound--;
                }

                // 输出调试信息
                PrintToChatAll("\x04[%s]:\x03 第一半场 - 回合: %d, CT分数: %d, T分数: %d", MODNAME, g_iCurrentRound, g_iCTScoreH1, g_iTScoreH1);

                if (GetConVarInt(g_hCvarShowScores) == 1) {
                    // 使用多语言系统
                    for (int i = 1; i <= MaxClients; i++) {
                        if (IsClientInGame(i) && !IsFakeClient(i)) {
                            // 根据客户端语言设置翻译目标
                            SetGlobalTransTarget(i);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Round", g_iCurrentRound, g_iCurrentHalf, 2);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Score", teamAName, g_iCTScoreH1, teamBName, g_iTScoreH1);
                        }
                    }
                }

                if (!g_bDidLiveStarted) {
                    // 使用多语言系统
                    for (int i = 1; i <= MaxClients; i++) {
                        if (IsClientInGame(i) && !IsFakeClient(i)) {
                            SetGlobalTransTarget(i);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Not Live");
                        }
                    }
                }
            } else if (g_iCurrentHalf == 2) {
                if (g_iCurrentRound == 0) {
                    g_iCurrentRound = 1;
                }

                // 输出调试信息
                PrintToChatAll("\x04[%s]:\x03 第二半场 - 回合: %d, CT总分: %d, T总分: %d", MODNAME, g_iCurrentRound, g_iCTScore, g_iTScore);
                if (g_iCurrentRound == 1 ) {
                    // 重置玩家金钱为800
                    for (int client = 1; client <= MaxClients; client++) {
                        if (IsClientInGame(client) && !IsFakeClient(client) && IsClientConnected(client)) {
                            int team = GetClientTeam(client);

                            if (team > 1) {
                                SetEntProp(client, Prop_Send, "m_iAccount", 800);
                            }
                        }
                    }
                }
                // 检查比赛是否结束
                if ((g_iCTScore == 13) || (g_iTScore == 13) || ((g_iCTScore == 12) && (g_iTScore == 12) && (GetConVarInt(g_hCvarMr3Enabled) == 0))) {
                    // 输出调试信息
                    PrintToChatAll("\x04[%s]:\x03 比赛结束条件触发: CT=%d, T=%d", MODNAME, g_iCTScore, g_iTScore);

                    if (GetConVarInt(g_hCvarInformWinnerInPanel) == 1) {
                        if (g_iCTScore == 13) {
                            Mix_CreateWinningTeamPanel(3);
                        } else if (g_iTScore == 13) {
                            Mix_CreateWinningTeamPanel(2);
                        } else if (g_iCTScore == g_iTScore) {
                            Mix_CreateWinningTeamPanel(1);
                        }
                    } else {
                        if (g_iCTScore == 13) {
                            CreateTimer(3.0, Mix_InformMatchEnd, 3);
                        } else if (g_iTScore == 13) {
                            CreateTimer(3.0, Mix_InformMatchEnd, 2);
                        } else if (g_iCTScore == g_iTScore) {
                            CreateTimer(3.0, Mix_InformMatchEnd, 1);
                        }
                    }

                    // 输出调试信息
                    PrintToChatAll("\x04[%s]:\x03 正在重置比赛状态...", MODNAME);

                    g_bHasMixStarted = false;
                    g_bDidLiveStarted = false;

                    g_bIsItManual = true;
                    if (GetConVarInt(g_hCvarAutoMixEnabled) == 1) {
                        g_bAllowReady = true;
                        g_iReadyCount = 0;
                        g_bHasVoteMap = false;
                        g_bTenVoted = false;
                        for (int i = 0; i < MaxClients; i++) {
                            g_bReadyPlayers[i] = false;
                            g_iReadyPlayersData[i] = -1;
                        }
                    }

                    g_iCurrentRound = 1;
                    g_iCurrentHalf = 1;
                    g_iTScore = -1;
                    g_iCTScore = -1;

                    g_bSaveClientsScore = false;

                    SetConVarString(g_hHostName, g_szHostName);

                    Mix_ExecutePracConfig(0);

                    if (GetConVarInt(g_hCvarRemovePassWhenMixIsEnded) == 1) {
                        Mix_RemovePassword(0);
                    }
                } else {
                    if (g_iCurrentRound > (g_iCTScoreH1 + g_iTScoreH1 + 1)) {
                        g_iCurrentRound--;
                    }

                    if (GetConVarInt(g_hCvarShowScores) == 1) {
                        // 使用多语言系统
                        for (int i = 1; i <= MaxClients; i++) {
                            if (IsClientInGame(i) && !IsFakeClient(i)) {
                                SetGlobalTransTarget(i);
                                PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Round", g_iCurrentRound, g_iCurrentHalf, 2);
                                PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Score", teamAName, g_iCTScore, teamBName, g_iTScore);
                            }
                        }
                    }

                    // 检查是否需要开始MR3
                    if ((g_iCTScore == 12) && (g_iTScore == 12) && (GetConVarInt(g_hCvarMr3Enabled) == 1)) {
                        g_iCTScore2 = g_iCTScore;
                        g_iTScore2 = g_iTScore;

                        float time = GetConVarFloat(g_hCvarDelayBeforeSwapping);
                        if (time < 0.1) {
                            time = 0.1;
                        }
                        CreateTimer(time, Mix_SwapTimer);

                        g_iCurrentRound = 1;
                        g_iCurrentHalf = 3;
                        if ((GetConVarInt(g_hCvarHalfAutoLiveStart) == 0) && g_bIsItManual) {
                            g_bDidLiveStarted = false;
                        }

                        if (GetConVarInt(g_hCvarPlayTeamSwapedSound) == 1) {
                            EmitSoundToAll("ambient/misc/brass_bell_C.wav");
                        }
                        Mix_ExecuteMr3Config(0);

                        // 调用API事件
                        Mix_API_OnHalfTime(g_iCTScore, g_iTScore);

                        if (GetConVarInt(g_hCvarHalfAutoLiveStart) == 0) {
                            // 使用多语言系统
                            for (int i = 1; i <= MaxClients; i++) {
                                if (IsClientInGame(i) && !IsFakeClient(i)) {
                                    SetGlobalTransTarget(i);
                                    PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Teams Swapped");
                                    PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Type Live");
                                }
                            }
                        } else {
                            // 使用多语言系统
                            for (int i = 1; i <= MaxClients; i++) {
                                if (IsClientInGame(i) && !IsFakeClient(i)) {
                                    SetGlobalTransTarget(i);
                                    PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Teams Swapped");
                                }
                            }
                        }
                    } else {
                        if (g_iCTScore == 12) {
                            // 使用多语言系统
                            for (int i = 1; i <= MaxClients; i++) {
                                if (IsClientInGame(i) && !IsFakeClient(i)) {
                                    SetGlobalTransTarget(i);
                                    PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Match Point", teamAName);
                                }
                            }
                        }
                        if (g_iTScore == 12) {
                            // 使用多语言系统
                            for (int i = 1; i <= MaxClients; i++) {
                                if (IsClientInGame(i) && !IsFakeClient(i)) {
                                    SetGlobalTransTarget(i);
                                    PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Match Point", teamBName);
                                }
                            }
                        }
                    }
                }

                if (!g_bDidLiveStarted) {
                    // 使用多语言系统
                    for (int i = 1; i <= MaxClients; i++) {
                        if (IsClientInGame(i) && !IsFakeClient(i)) {
                            SetGlobalTransTarget(i);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Not Live");
                        }
                    }
                }
            } else if (g_iCurrentHalf > 2) {
                if (g_iCurrentRound == 0) {
                    g_iCurrentRound = 1;
                }

                if (g_iCurrentRound > (g_iCTScoreH1 + g_iTScoreH1 + 1)) {
                    g_iCurrentRound--;
                }

                if (GetConVarInt(g_hCvarShowScores) == 1) {
                    // 使用多语言系统
                    for (int i = 1; i <= MaxClients; i++) {
                        if (IsClientInGame(i) && !IsFakeClient(i)) {
                            SetGlobalTransTarget(i);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Round", g_iCurrentRound, g_iCurrentHalf, 4);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Score", teamAName, g_iCTScore, teamBName, g_iTScore);
                        }
                    }
                }

                if (g_iCTScore == 15) {
                    // 使用多语言系统
                    for (int i = 1; i <= MaxClients; i++) {
                        if (IsClientInGame(i) && !IsFakeClient(i)) {
                            SetGlobalTransTarget(i);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Match Point", teamAName);
                        }
                    }
                }
                if (g_iTScore == 15) {
                    // 使用多语言系统
                    for (int i = 1; i <= MaxClients; i++) {
                        if (IsClientInGame(i) && !IsFakeClient(i)) {
                            SetGlobalTransTarget(i);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Match Point", teamBName);
                        }
                    }
                }

                if (!g_bDidLiveStarted) {
                    // 使用多语言系统
                    for (int i = 1; i <= MaxClients; i++) {
                        if (IsClientInGame(i) && !IsFakeClient(i)) {
                            SetGlobalTransTarget(i);
                            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Not Live");
                        }
                    }
                }
            }

            if ((g_bHasMixStarted) && (g_bDidLiveStarted)) {
                g_iCurrentRound++;

                if ((g_iCurrentHalf == 1) && (g_iCurrentRound == 13)) {
                    g_bSwapNow = true;

                    if (GetConVarInt(g_hCvarShowSwitchInPanel) == 1) {
                        char titleFormat[32];
                        Format(titleFormat, sizeof(titleFormat), "%s: ", MODNAME);
                        Handle panel = CreatePanel();
                        SetPanelTitle(panel, titleFormat);
                        DrawPanelItem(panel, "", ITEMDRAW_SPACER);
                        char buffer[128];
                        Format(buffer, sizeof(buffer), "%t", "Teams Will Swap");
                        DrawPanelText(panel, buffer);
                        DrawPanelItem(panel, "", ITEMDRAW_SPACER);

                        SetPanelCurrentKey(panel, 10);
                        DrawPanelItem(panel, "关闭", ITEMDRAW_CONTROL);

                        for (int i = 1; i <= MaxClients; i++) {
                            if (IsClientInGame(i) && !IsFakeClient(i)) {
                                SendPanelToClient(panel, i, Mix_HandleDoNothing, (GetConVarInt(g_hFreezeTime) - 1));
                            }
                        }

                        CloseHandle(panel);
                    } else {
                        // 使用多语言系统
                        for (int i = 1; i <= MaxClients; i++) {
                            if (IsClientInGame(i) && !IsFakeClient(i)) {
                                SetGlobalTransTarget(i);
                                PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Teams Will Swap");
                            }
                        }
                    }
                } else if ((g_iCurrentHalf == 3) && (g_iCurrentRound == 4)) {
                    g_bSwapNow = true;

                    if (GetConVarInt(g_hCvarShowSwitchInPanel) == 1) {
                        char titleFormat[32];
                        Format(titleFormat, sizeof(titleFormat), "%s: ", MODNAME);
                        Handle panel = CreatePanel();
                        SetPanelTitle(panel, titleFormat);
                        DrawPanelItem(panel, "", ITEMDRAW_SPACER);
                        char buffer[128];
                        Format(buffer, sizeof(buffer), "%t", "Teams Will Swap");
                        DrawPanelText(panel, buffer);
                        DrawPanelItem(panel, "", ITEMDRAW_SPACER);

                        SetPanelCurrentKey(panel, 10);
                        DrawPanelItem(panel, "关闭", ITEMDRAW_CONTROL);

                        for (int i = 1; i <= MaxClients; i++) {
                            if (IsClientInGame(i) && !IsFakeClient(i)) {
                                SendPanelToClient(panel, i, Mix_HandleDoNothing, (GetConVarInt(g_hFreezeTime) - 1));
                            }
                        }

                        CloseHandle(panel);
                    } else {
                        // 使用多语言系统
                        for (int i = 1; i <= MaxClients; i++) {
                            if (IsClientInGame(i) && !IsFakeClient(i)) {
                                SetGlobalTransTarget(i);
                                PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Teams Will Swap");
                            }
                        }
                    }
                }
            }

            if (GetConVarInt(g_hCvarShowMoneyAndWeapons) == 1) {
                Mix_ShowTeamMoneyAndWeapons();
            }
        }
    }
    return Plugin_Continue;
}

/**
 * 回合结束事件
 */
public Action Mix_Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
    int winningTeam = GetEventInt(event, "winner");

    // 调用API事件
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_API_OnRoundEnd(winningTeam, g_iCTScore, g_iTScore);
    }

    if (g_bIsKo3Running) {
        if ((winningTeam == 2) || (winningTeam == 3)) {
            g_bIsKo3Running = false;

            if (GetConVarInt(g_hCvarKnifeWinTeamVote) == 1) {
                Handle teamVoteMenu = CreateMenu(Mix_HandleTeamsVoteMenu, MenuAction_VoteEnd | MenuAction_End | MenuAction_VoteCancel);
                SetMenuTitle(teamVoteMenu, "是否切换队伍?");
                AddMenuItem(teamVoteMenu, "yes", "是");
                AddMenuItem(teamVoteMenu, "no", "否");
                SetMenuExitButton(teamVoteMenu, false);
                VoteMenuToTeam(teamVoteMenu, winningTeam, 20);

                // 没有对应的翻译短语
                if (winningTeam == 2) {
                    PrintToChatAll("\x04[%s]:\x03 进攻方队伍赢得了刀局 - 正在进行队伍选择投票...", MODNAME);
                } else if (winningTeam == 3) {
                    PrintToChatAll("\x04[%s]:\x03 防守方队伍赢得了刀局 - 正在进行队伍选择投票...", MODNAME);
                }
            } else {
                Mix_ExecuteMr12Config(0);
            }
        }
    }

    if (g_bHasMixStarted && g_bDidLiveStarted && !g_bIsKo3Running) {
        if (winningTeam == 2) { // T Win
            g_iTScoreH1++;
            g_iTScore++;
            // 更新游戏记分板
            SetTeamScore(2, g_iTScore);
        } else if (winningTeam == 3) { // CT Win
            g_iCTScoreH1++;
            g_iCTScore++;
            // 更新游戏记分板
            SetTeamScore(3, g_iCTScore);
        }

        if (g_bSwapNow) {
            g_iCTScoreH1 = g_iCTScore;
            g_iTScoreH1 = g_iTScore;

            float time = GetConVarFloat(g_hCvarDelayBeforeSwapping);
            if (time < 0.1) {
                time = 0.1;
            }
            CreateTimer(time, Mix_SwapTimer);
            g_bSwapNow = false;
            g_iCurrentRound = 1;
            g_iCurrentHalf++;

            // 交换半场分数
            int temp = g_iCTScoreH1;
            g_iCTScoreH1 = g_iTScoreH1;
            g_iTScoreH1 = temp;

            // 交换总分数
            temp = g_iCTScore;
            g_iCTScore = g_iTScore;
            g_iTScore = temp;

            // 输出调试信息
            PrintToChatAll("\x04[%s]:\x03 队伍交换后分数更新: CT=%d, T=%d", MODNAME, g_iCTScore, g_iTScore);

            if ((GetConVarInt(g_hCvarHalfAutoLiveStart) == 0) && g_bIsItManual) {
                g_bDidLiveStarted = false;
            }

            if (GetConVarInt(g_hCvarPlayTeamSwapedSound) == 1) {
                EmitSoundToAll("ambient/misc/brass_bell_C.wav");
            }

            // 调用API事件
            Mix_API_OnHalfTime(g_iCTScore, g_iTScore);

            if (GetConVarInt(g_hCvarHalfAutoLiveStart) == 0) {
                // 使用多语言系统
                for (int i = 1; i <= MaxClients; i++) {
                    if (IsClientInGame(i) && !IsFakeClient(i)) {
                        SetGlobalTransTarget(i);
                        PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Teams Swapped");
                        PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Type Live");
                    }
                }
            } else {
                // 使用多语言系统
                for (int i = 1; i <= MaxClients; i++) {
                    if (IsClientInGame(i) && !IsFakeClient(i)) {
                        SetGlobalTransTarget(i);
                        PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Teams Swapped");
                    }
                }
            }
        }

        // 如果是MR3，检查比赛结束
        if ((g_iCurrentHalf > 2) && ((g_iCTScore - g_iCTScore2 >= 4) || (g_iTScore - g_iTScore2 >= 4) || ((g_iCTScore - g_iCTScore2 == 3) && (g_iTScore - g_iTScore2 == 3)))) {
            // 输出调试信息
            PrintToChatAll("\x04[%s]:\x03 MR3比赛结束条件触发: CT=%d (原始=%d), T=%d (原始=%d)", MODNAME, g_iCTScore, g_iCTScore2, g_iTScore, g_iTScore2);

            if (GetConVarInt(g_hCvarInformWinnerInPanel) == 1) {
                if (g_iCTScore >= 16) {
                    Mix_CreateWinningTeamPanel(3);
                } else if (g_iTScore >= 16) {
                    Mix_CreateWinningTeamPanel(2);
                } else if (g_iCTScore == g_iTScore) {
                    Mix_CreateWinningTeamPanel(1);
                }
            } else {
                if (g_iCTScore >= 16) {
                    CreateTimer(3.0, Mix_InformMatchEnd, 3);
                } else if (g_iTScore >= 16) {
                    CreateTimer(3.0, Mix_InformMatchEnd, 2);
                } else if (g_iCTScore == g_iTScore) {
                    CreateTimer(3.0, Mix_InformMatchEnd, 1);
                }
            }

            // 输出调试信息
            PrintToChatAll("\x04[%s]:\x03 MR3模式下正在重置比赛状态...", MODNAME);

            g_bHasMixStarted = false;
            g_bDidLiveStarted = false;

            g_bIsItManual = true;
            if (GetConVarInt(g_hCvarAutoMixEnabled) == 1) {
                g_bAllowReady = true;
                g_iReadyCount = 0;
                g_bHasVoteMap = false;
                g_bTenVoted = false;
                for (int i = 0; i < MaxClients; i++) {
                    g_bReadyPlayers[i] = false;
                    g_iReadyPlayersData[i] = -1;
                }
            }

            g_iCurrentRound = 1;
            g_iCurrentHalf = 1;
            g_iTScore = -1;
            g_iCTScore = -1;

            g_bSaveClientsScore = false;

            SetConVarString(g_hHostName, g_szHostName);

            Mix_ExecutePracConfig(0);

            if (GetConVarInt(g_hCvarRemovePassWhenMixIsEnded) == 1) {
                Mix_RemovePassword(0);
            }
        }
    }

    return Plugin_Continue;
}

/**
 * C4爆炸事件
 */
public Action Mix_Event_BombExploded(Handle event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    int client = GetClientOfUserId(userid);

    // 更新统计系统
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_Stats_OnBombPlanted(client);
    }

    return Plugin_Continue;
}

/**
 * C4拆除事件
 */
public Action Mix_Event_BombDefused(Handle event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    int client = GetClientOfUserId(userid);

    // 更新统计系统
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_Stats_OnBombDefused(client);
    }

    return Plugin_Continue;
}

/**
 * 玩家受伤事件
 */
public Action Mix_Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    int attacker = GetEventInt(event, "attacker");
    int damage = GetEventInt(event, "dmg_health");
    bool headshot = GetEventBool(event, "hitgroup") == true;

    int victimId = GetClientOfUserId(userid);
    int attackerId = GetClientOfUserId(attacker);

    // 只有在比赛正式开始后才更新统计数据
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_Stats_OnPlayerHurt(attackerId, victimId, damage, headshot);
    }

    // 显示队友伤害消息
    if (GetConVarInt(g_hCvarShowTkMessage) == 1) {
        // 检查是否是队友伤害
        if (IsValidClient(victimId) && IsValidClient(attackerId) && victimId != attackerId) {
            if (GetClientTeam(victimId) == GetClientTeam(attackerId)) {
                char attackerName[MAX_NAME_LENGTH];
                char victimName[MAX_NAME_LENGTH];
                GetClientName(attackerId, attackerName, sizeof(attackerName));
                GetClientName(victimId, victimName, sizeof(victimName));

                // 使用多语言系统
                for (int i = 1; i <= MaxClients; i++) {
                    if (IsClientInGame(i) && !IsFakeClient(i)) {
                        SetGlobalTransTarget(i);
                        PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Team Damage", attackerName, victimName, damage);
                    }
                }
            }
        }
    }

    return Plugin_Continue;
}

/**
 * 玩家死亡事件
 */
public Action Mix_Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    int attacker = GetEventInt(event, "attacker");
    bool headshot = GetEventBool(event, "headshot");

    int victimId = GetClientOfUserId(userid);
    int attackerId = GetClientOfUserId(attacker);

    // 只有在比赛正式开始后才更新统计数据
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_Stats_OnPlayerDeath(attackerId, victimId, headshot);
    }

    if (IsValidClient(victimId) && IsValidClient(attackerId) && victimId != attackerId) {
        if (GetClientTeam(victimId) != GetClientTeam(attackerId)) {
            if (GetConVarInt(g_hCvarShowMVP) == 1) {
                // 增加击杀数（保留原有功能）
                g_iScoresOfTheRound[attackerId]++;
                g_iScoresOfTheGame[attackerId]++;
                g_iDeathsOfTheGame[victimId]++;
            }
        }
    }

    return Plugin_Continue;
}

/**
 * 玩家断开连接事件
 */
public Action Mix_Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    // 更新准备系统
    if (g_bReadyPlayers[client]) {
        g_bReadyPlayers[client] = false;
        g_iReadyCount--;
    }

    g_bHidePanel[client] = false;
    g_bGaggedPlayers[client] = false;
    g_bMutedPlayers[client] = false;

    return Plugin_Continue;
}

/**
 * 武器开火事件
 */
public Action Mix_Event_WeaponFire(Handle event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    int client = GetClientOfUserId(userid);

    // 只有在比赛正式开始后才更新统计数据
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_Stats_OnWeaponFire(client);
    }

    return Plugin_Continue;
}

/**
 * 炸弹安装事件
 */
public Action Mix_Event_BombPlanted(Handle event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    int client = GetClientOfUserId(userid);

    // 只有在比赛正式开始后才更新统计数据
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        Mix_Stats_OnBombPlanted(client);
    }

    return Plugin_Continue;
}

/**
 * 面板处理函数（无操作）
 */
public int Mix_HandleDoNothing(Handle menu, MenuAction action, int param1, int param2)
{
    // 这个函数什么都不做，仅用于满足回调需求
    return 0;
}

/**
 * 验证客户端是否有效
 */
bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client));
}

/**
 * 更新HUD显示
 */
void Mix_HudUpdate()
{
    if (g_hHudTimer != INVALID_HANDLE) {
        KillTimer(g_hHudTimer);
        g_hHudTimer = INVALID_HANDLE;
    }

    g_hHudTimer = CreateTimer(1.0, Mix_HudTimer, _, TIMER_REPEAT);
}

/**
 * HUD定时器回调
 */
public Action Mix_HudTimer(Handle timer)
{
    if (!g_bHasMixStarted) {
        Mix_CreateReadyPanel();
    }

    return Plugin_Continue;
}

/**
 * 玩家进入比赛时提示
 */
public Action Mix_InformPlayerAboutTheMix(Handle timer, int client)
{
    if (IsClientInGame(client) && !IsFakeClient(client)) {
        // 这里使用硬编码的消息，因为没有对应的翻译短语
        // 可以在翻译文件中添加"Match In Progress Do Not Disturb"短语
        SetGlobalTransTarget(client);
        PrintToChat(client, "\x04[%s]:\x03 %t", MODNAME, "Match In Progress");
    }

    return Plugin_Continue;
}

/**
 * 移除地图道具
 */
bool Mix_RemoveProps()
{
    if (g_bIsMapValidToRemoveProps) {
        int entity = -1;
        int removed = 0;

        // 移除鸡、可打碎物体和屏幕等
        char classList[][] = {
            "chicken",
            "func_breakable",
            "prop_dynamic",
            "prop_physics",
            "prop_physics_multiplayer"
        };

        for (int i = 0; i < sizeof(classList); i++) {
            while ((entity = FindEntityByClassname(entity, classList[i])) != -1) {
                AcceptEntityInput(entity, "Kill");
                removed++;
            }
            entity = -1;
        }

        if (removed > 0) {
            // 这里使用硬编码的消息，因为没有对应的翻译短语
            // 可以在翻译文件中添加"Props Removed"短语
            PrintToChatAll("\x04[%s]:\x03 已移除 %d 个物品", MODNAME, removed);
            return true;
        }
    }

    return false;
}