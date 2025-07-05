/**
 * 团队管理模块
 *
 * 本模块包含与团队管理相关的功能，包括队伍交换、随机分配队伍等。
 * 所有函数都以 Mix_ 前缀开头，表示它们属于 Mixmod 插件。
 */

#if defined _mixmod_teams_included
  #endinput
#endif
#define _mixmod_teams_included

// =============================================================================
// 团队管理功能
// =============================================================================

/**
 * 交换队伍
 */
void Mix_SwapTeams()
{
    bool flag = false;
    if (g_bDidLiveStarted) {
        g_bDidLiveStarted = false;
        flag = true;
    }

    int team;
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i))
            continue;

        team = GetClientTeam(i);
        if (team == TEAM_T) {
            ChangeClientTeam(i, TEAM_CT);
            PrintToChat(i, "\x04[%s]:\x03 你已被调换至 \x01防守方\x03 队伍", MODNAME);
        } else if (team == TEAM_CT) {
            ChangeClientTeam(i, TEAM_T);
            PrintToChat(i, "\x04[%s]:\x03 你已被调换至 \x01进攻方\x03 队伍", MODNAME);
        }
    }
    PrintToChatAll("\x04[%s]:\x03 所有玩家已交换队伍", MODNAME);

    if (flag) {
        g_bDidLiveStarted = true;
    }
}

/**
 * 半场结束时交换队伍的定时器回调
 *
 * @param timer 触发此回调的计时器句柄
 * @return 计时器继续状态
 */
public Action Mix_SwapTimer(Handle timer)
{
    g_bDidLiveStarted = false; // 在交换队伍前禁用Live状态

    // 输出调试信息
    PrintToChatAll("\x04[%s]:\x03 交换队伍前分数: CT=%d, T=%d", MODNAME, g_iCTScore, g_iTScore);

    int team;
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client) && IsClientConnected(client)) {
            team = GetClientTeam(client);

            if (team == CS_TEAM_CT) {
                CS_SwitchTeam(client, CS_TEAM_T);
                // 不再设置模型，因为现在换边不需要选择模型
            } else if (team == CS_TEAM_T) {
                CS_SwitchTeam(client, CS_TEAM_CT);
                // 不再设置模型，因为现在换边不需要选择模型
            }
        }
    }

    // 确保分数已正确交换
    PrintToChatAll("\x04[%s]:\x03 交换队伍后分数: CT=%d, T=%d", MODNAME, g_iCTScore, g_iTScore);

    // 更新游戏记分板上的分数
    SetTeamScore(3, g_iCTScore);
    SetTeamScore(2, g_iTScore);
    PrintToChatAll("\x04[%s]:\x03 记分板已更新", MODNAME);

    if (GetConVarInt(g_hCvarHalfAutoLiveStart) == 1) {
        g_bDidLiveStarted = true;
    }

    return Plugin_Continue;
}

/**
 * 移除玩家的枪械
 *
 * @param client 目标客户端
 */
void Mix_RemovePlayerGuns(int client)
{
    int gunEnt;
    for (int i = 0; i < 5; i++) {
        if (i == 2) // 不移除刀
            continue;

        while ((gunEnt = GetPlayerWeaponSlot(client, i)) != -1) {
            RemovePlayerItem(client, gunEnt);
        }
    }
    // 切换到刀 - 当我重新给予武器时，它们会自动切换
    ClientCommand(client, "slot3");
}

/**
 * 随机分配CT队员
 */
void Mix_RandomizeCTPlayers()
{
    int numSwitched = 0;
    while (numSwitched < 5) {
        int client = Mix_GetRandomPlayer(TEAM_T);

        if (client != -1) {
            Mix_SwitchPlayerTeam(client, CS_TEAM_CT);

            if (IsPlayerAlive(client)) {
                CS_RespawnPlayer(client);
            }

            numSwitched++;
        } else {
            LogMessage("随机分配CT队员时出错...");
            PrintToChatAll("\x04[%s]:\x01 错误: 无法从T队伍中获取随机玩家!", MODNAME);
            break;
        }
    }
}

/**
 * 切换玩家队伍并设置相应的模型
 *
 * @param client 目标客户端索引
 * @param team   目标队伍
 */
void Mix_SwitchPlayerTeam(int client, int team)
{
    if (team > CS_TEAM_SPECTATOR) {
        CS_SwitchTeam(client, team);
        Mix_SetRandomModel(client, team);
    } else {
        ChangeClientTeam(client, team);
    }
}

/**
 * 设置随机模型
 *
 * @param client 目标客户端索引
 * @param team   目标队伍
 *
 * 注意：此函数已不再设置模型，因为现在换边不需要选择模型。
 * 保留此函数是为了向后兼容，避免其他模块调用此函数时出错。
 */
void Mix_SetRandomModel(int client, int team)
{
    // 不再设置模型，因为现在换边不需要选择模型
    // 此函数保留为空函数，以保持向后兼容性
    // 使用参数以避免编译警告
    if (client > 0 && team > 0) {
        // 仅为了使用参数，不执行任何操作
    }
}

/**
 * 获取指定队伍中的随机玩家
 *
 * @param team 目标队伍
 * @return     随机玩家索引，如果没有找到则返回-1
 */
int Mix_GetRandomPlayer(int team)
{
    int[] players = new int[MaxClients+1];
    int playerCount = 0;

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team) {
            players[playerCount++] = i;
        }
    }

    if (playerCount == 0) {
        return -1;
    } else {
        return players[GetRandomInt(0, playerCount-1)];
    }
}

/**
 * 禁用购买区
 *
 * @return 操作是否成功
 */
bool Mix_DisableBuyZone()
{
    int ent = -1;
    bool disabled = false;

    while ((ent = FindEntityByClassname(ent, "func_buyzone")) != -1) {
        AcceptEntityInput(ent, "Disable");
        disabled = true;
    }

    return disabled;
}

/**
 * 启用购买区
 *
 * @return 操作是否成功
 */
bool Mix_EnableBuyZone()
{
    int ent = -1;
    bool enabled = false;

    while ((ent = FindEntityByClassname(ent, "func_buyzone")) != -1) {
        AcceptEntityInput(ent, "Enable");
        enabled = true;
    }

    return enabled;
}

/**
 * 踢出指定队伍的玩家
 *
 * @param client         执行命令的管理员
 * @param team           要踢出的队伍
 * @param adminsImmunity 是否踢出管理员
 */
void Mix_KickTeam(int client, int team, int adminsImmunity)
{
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i) && (client != i) && (GetClientTeam(i) == team)) {
            if (adminsImmunity == 1) {
                if (GetUserAdmin(i) == INVALID_ADMIN_ID) {
                    KickClient(i, "[%s]: 你已被管理员踢出服务器!", MODNAME);
                }
            } else {
                KickClient(i, "[%s]: 你已被管理员踢出服务器!", MODNAME);
            }
        }
    }
}

/**
 * 处理刀局结束后的队伍选择投票
 */
public int Mix_HandleTeamsVoteMenu(Handle menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End) {
        CloseHandle(menu);
    } else if (action == MenuAction_VoteEnd) {
        if (param1 == 0) {  // 投票选择"是"
            // 输出调试信息
            PrintToChatAll("\x04[%s]:\x03 刀局后交换队伍，分数将重置", MODNAME);

            int team;
            for (int i = 1; i <= MaxClients; i++) {
                if (IsClientInGame(i)) {
                    team = GetClientTeam(i);
                    if (team == TEAM_T) {
                        CS_SwitchTeam(i, TEAM_CT);
                    } else if (team == TEAM_CT) {
                        CS_SwitchTeam(i, TEAM_T);
                    }
                }
            }
        }
        g_bIsKo3Running = false;
        PrintToChatAll("\x04[%s]:\x03 队伍已选择!", MODNAME);

        // 重置分数
        g_iCTScore = 0;
        g_iTScore = 0;
        g_iCTScoreH1 = 0;
        g_iTScoreH1 = 0;

        // 重置所有玩家的战绩和统计数据
        Mix_ResetAllStats();

        // 重置MVP系统的分数
        for (int i = 1; i <= MaxClients; i++) {
            g_iScoresOfTheRound[i] = 0;
            g_iScoresOfTheGame[i] = 0;
            g_iDeathsOfTheGame[i] = 0;
        }

        // 更新游戏记分板上的分数
        SetTeamScore(3, g_iCTScore);
        SetTeamScore(2, g_iTScore);
        PrintToChatAll("\x04[%s]:\x03 分数和所有玩家的战绩已重置", MODNAME);

        Mix_ExecuteMr12Config();
    }
    return 0;
}

/**
 * 随机分配队伍
 */
void Mix_RandomizeTeams()
{
    // 将所有人移至T队伍
    for(int i = 1; i <= MaxClients; i++) {
        if(IsClientInGame(i) && !IsFakeClient(i)) {
            Mix_SwitchPlayerTeam(i, CS_TEAM_T);
        }
    }

    // 随机选择5名T玩家并移至CT队伍
    Mix_RandomizeCTPlayers();
    PrintToChatAll("\x04[%s]:\x03 队伍已随机分配!", MODNAME);
}

/**
 * 将玩家移至观察者队伍
 *
 * @param client       执行命令的客户端
 * @param targetClient 目标客户端
 */
void Mix_MoveToSpectator(int client, int targetClient)
{
    ChangeClientTeam(targetClient, TEAM_SPEC);

    char targetName[MAX_NAME_LENGTH];
    GetClientName(targetClient, targetName, sizeof(targetName));

    PrintToChat(targetClient, "\x04[%s]:\x03 你已被移至观察者队伍!", MODNAME);
    PrintToChat(client, "\x04[%s]:\x03 %s 已被移至观察者队伍!", MODNAME, targetName);
}