/**
 * 统计系统模块
 *
 * 本模块提供更详细的玩家统计功能，包括击杀、死亡、助攻、爆头率、伤害等数据。
 * 同时提供API接口，允许其他插件访问这些统计数据。
 */

#if defined _mixmod_stats_included
  #endinput
#endif
#define _mixmod_stats_included

// =============================================================================
// 统计数据结构
// =============================================================================

enum struct PlayerStats {
    int kills;             // 击杀数
    int deaths;            // 死亡数
    int assists;           // 助攻数
	    int headshots;         // 爆头数
	    int damage;            // 总伤害
	    int clutches;          // 残局获胜次数（保留旧字段名兼容API）
	    int clutch_losses;     // 残局失败次数
	    int rounds_played;     // 参与的回合数
    int shots_fired;       // 开火次数
    int shots_hit;         // 命中次数
    int bomb_plants;       // 安装炸弹次数
    int bomb_defuses;      // 拆除炸弹次数

    // 重置统计数据
    void Reset() {
        this.kills = 0;
        this.deaths = 0;
        this.assists = 0;
	        this.headshots = 0;
	        this.damage = 0;
	        this.clutches = 0;
	        this.clutch_losses = 0;
	        this.rounds_played = 0;
        this.shots_fired = 0;
        this.shots_hit = 0;
        this.bomb_plants = 0;
        this.bomb_defuses = 0;
    }

    // 计算K/D比率
    float GetKDRatio() {
        return (this.deaths > 0) ? float(this.kills) / float(this.deaths) : float(this.kills);
    }

    // 计算爆头率
    float GetHeadshotPercentage() {
        return (this.kills > 0) ? (float(this.headshots) / float(this.kills)) * 100.0 : 0.0;
    }

    // 计算平均每回合伤害(ADR)
    float GetADR() {
        return (this.rounds_played > 0) ? float(this.damage) / float(this.rounds_played) : 0.0;
    }

    // 计算命中率
    float GetAccuracy() {
        return (this.shots_fired > 0) ? (float(this.shots_hit) / float(this.shots_fired)) * 100.0 : 0.0;
    }
}

// 玩家统计数据数组
PlayerStats g_PlayerStats[MAXPLAYERS + 1];

// 回合伤害数据（用于计算助攻）
int g_RoundDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];

// 是否启用统计系统
bool g_bStatsEnabled = true;

// =============================================================================
// 初始化和命令
// =============================================================================

/**
 * 初始化统计系统
 */
void Mix_InitStats()
{
    // 创建统计相关的ConVars
    ConVar cvar_stats_enabled = CreateConVar("sm_mixmod_stats_enabled", "1", "是否启用统计系统 (0=禁用, 1=启用)", FCVAR_NOTIFY);

    // 设置初始值
    g_bStatsEnabled = GetConVarBool(cvar_stats_enabled);

    // 添加变更钩子
    HookConVarChange(cvar_stats_enabled, OnStatsEnabledChanged);

    // 注册统计命令
    RegConsoleCmd("sm_stats", Mix_Command_Stats, "显示玩家统计信息");

    // 初始化所有玩家的统计数据
    for (int i = 1; i <= MaxClients; i++) {
        g_PlayerStats[i].Reset();
    }
}

/**
 * 统计命令处理
 */
public Action Mix_Command_Stats(int client, int args)
{
    if (!g_bStatsEnabled) {
        SetGlobalTransTarget(client);
        PrintToChat(client, "\x04[%s]:\x03 %t", MODNAME, "Stats System Disabled");
        return Plugin_Handled;
    }

    if (args == 0) {
        // 显示自己的统计信息
        Mix_ShowPlayerStats(client, client);
    } else {
        // 查找目标玩家
        char arg[MAX_NAME_LENGTH];
        GetCmdArg(1, arg, sizeof(arg));

        int target = FindTarget(client, arg, true, false);
        if (target != -1) {
            Mix_ShowPlayerStats(client, target);
        }
    }

    return Plugin_Handled;
}

/**
 * 显示玩家统计信息
 *
 * @param client 查看统计信息的客户端
 * @param target 目标玩家
 */
void Mix_ShowPlayerStats(int client, int target)
{
    if (!IsClientInGame(target)) {
        return;
    }

    char targetName[MAX_NAME_LENGTH];
    GetClientName(target, targetName, sizeof(targetName));

    // 向客户端发送统计信息
    SetGlobalTransTarget(client);

    // 发送标题
    PrintToChat(client, "\x04[%s]:\x03 %s 的统计信息:", MODNAME, targetName);

    // 发送统计数据
    PrintToChat(client, "\x04[%s]:\x03 击杀: \x04%d\x03  死亡: \x04%d\x03  K/D比率: \x04%.2f",
        MODNAME, g_PlayerStats[target].kills, g_PlayerStats[target].deaths, g_PlayerStats[target].GetKDRatio());

    PrintToChat(client, "\x04[%s]:\x03 爆头: \x04%d\x03 (%.1f%%)  助攻: \x04%d",
        MODNAME, g_PlayerStats[target].headshots, g_PlayerStats[target].GetHeadshotPercentage(), g_PlayerStats[target].assists);

	    PrintToChat(client, "\x04[%s]:\x03 有效伤害: \x04%d\x03  ADR: \x04%.1f\x03  命中率: \x04%.1f%%",
	        MODNAME, g_PlayerStats[target].damage, g_PlayerStats[target].GetADR(), g_PlayerStats[target].GetAccuracy());

	    PrintToChat(client, "\x04[%s]:\x03 残局: \x04%d胜\x03 / \x04%d负",
	        MODNAME, g_PlayerStats[target].clutches, g_PlayerStats[target].clutch_losses);

	    PrintToChat(client, "\x04[%s]:\x03 安装炸弹: \x04%d\x03  拆除炸弹: \x04%d",
	        MODNAME, g_PlayerStats[target].bomb_plants, g_PlayerStats[target].bomb_defuses);
}

// =============================================================================
// 事件处理
// =============================================================================

/**
 * 回合开始时重置回合伤害数据
 */
void Mix_Stats_OnRoundStart()
{
    Mix_ResetClutchRoundState();

    if (!g_bStatsEnabled) {
        return;
    }

	    // 重置回合伤害数据
	    for (int i = 1; i <= MaxClients; i++) {
	        for (int j = 1; j <= MaxClients; j++) {
	            g_RoundDamage[i][j] = 0;
	        }

	        g_iLastKnownHealth[i] = 0;
	    }

    // 增加参与回合数
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) > 1) {
            g_PlayerStats[i].rounds_played++;
            g_iLastKnownHealth[i] = GetClientHealth(i);
        }
    }
}

/**
 * 重置当前回合的残局状态。
 */
void Mix_ResetClutchRoundState()
{
    g_bClutchActive = false;
    g_iClutchPlayer = 0;
    g_iClutchUserId = 0;
    g_iClutchTeam = 0;
    g_iClutchEnemyCount = 0;
}

/**
 * 玩家生成时记录初始血量，供 player_hurt 中计算真实 HP 伤害。
 */
void Mix_Stats_OnPlayerSpawn(int client)
{
    if (!IsValidClient(client)) {
        return;
    }

    g_iLastKnownHealth[client] = GetClientHealth(client);
}

/**
 * 将 player_hurt 的 raw dmg_health 转换为真实有效 HP 伤害。
 *
 * CS:S 的 dmg_health 可能包含超出受害者剩余血量的过量伤害。
 * ADR 应按对手实际被扣掉的 HP 计算，因此用上一次记录的 HP
 * 减去事件后的 health，并进行边界夹取。
 */
int Mix_CalculateActualHealthDamage(int victim, int rawDamage, int remainingHealth)
{
    if (rawDamage <= 0) {
        return 0;
    }

    if (!IsValidClient(victim)) {
        return rawDamage;
    }

    if (remainingHealth < 0) {
        remainingHealth = 0;
    }

    int previousHealth = g_iLastKnownHealth[victim];
    if (previousHealth <= 0) {
        previousHealth = remainingHealth + rawDamage;
        if (previousHealth > 100) {
            previousHealth = 100;
        }
    }

    int actualDamage = previousHealth - remainingHealth;
    if (actualDamage < 0) {
        actualDamage = 0;
    }
    if (actualDamage > rawDamage) {
        actualDamage = rawDamage;
    }
    if (actualDamage > previousHealth) {
        actualDamage = previousHealth;
    }

    g_iLastKnownHealth[victim] = remainingHealth;
    return actualDamage;
}

/**
 * 处理玩家伤害事件
 *
 * @param attacker 攻击者ID
 * @param victim 受害者ID
 * @param damage 实际扣除的 HP 伤害值
 * @param headshot 是否爆头
 */
void Mix_Stats_OnPlayerHurt(int attacker, int victim, int damage)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (!IsValidClient(attacker) || !IsValidClient(victim) || attacker == victim) {
        return;
    }

    if (GetClientTeam(attacker) == GetClientTeam(victim)) {
        return;
    }

    // 记录伤害
    g_PlayerStats[attacker].damage += damage;
    g_RoundDamage[attacker][victim] += damage;

    // 记录命中
    g_PlayerStats[attacker].shots_hit++;
}

/**
 * 处理玩家开火事件
 *
 * @param client 客户端ID
 */
void Mix_Stats_OnWeaponFire(int client)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (!IsValidClient(client)) {
        return;
    }

    // 增加开火次数
    g_PlayerStats[client].shots_fired++;
}

/**
 * 处理玩家死亡事件
 *
 * @param attacker 攻击者ID
 * @param victim 受害者ID
 * @param headshot 是否爆头
 */
void Mix_Stats_OnPlayerDeath(int attacker, int victim, bool headshot)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (!IsValidClient(victim)) {
        return;
    }

    g_iLastKnownHealth[victim] = 0;

    // 记录死亡
    g_PlayerStats[victim].deaths++;

    if (!IsValidClient(attacker) || attacker == victim || GetClientTeam(attacker) == GetClientTeam(victim)) {
        return;
    }

    // 记录击杀
    g_PlayerStats[attacker].kills++;

    // 记录爆头
    if (headshot) {
        g_PlayerStats[attacker].headshots++;
    }

	    // 检查助攻
	    for (int i = 1; i <= MaxClients; i++) {
	        if (IsValidClient(i) && i != attacker && i != victim && GetClientTeam(i) == GetClientTeam(attacker)) {
	            if (g_RoundDamage[i][victim] >= 40) {
	                g_PlayerStats[i].assists++;
	            }
	        }
	    }
}

/**
 * 检查死亡事件后是否进入 1vX 残局。
 *
 * 这里按传统满十统计口径，只记录 1v2 及以上；1v1 不计入残局，
 * 避免双方同时被标记为残局。
 */
void Mix_Stats_CheckClutchAfterDeath()
{
    if (!g_bStatsEnabled || g_bClutchActive) {
        return;
    }

    int aliveCounts[4];
    int lastAlivePlayers[4];
    Mix_GetAliveTeamState(aliveCounts, lastAlivePlayers);

    if (aliveCounts[CS_TEAM_T] == 1 && aliveCounts[CS_TEAM_CT] >= 2) {
        Mix_StartClutch(lastAlivePlayers[CS_TEAM_T], CS_TEAM_T, aliveCounts[CS_TEAM_CT]);
    } else if (aliveCounts[CS_TEAM_CT] == 1 && aliveCounts[CS_TEAM_T] >= 2) {
        Mix_StartClutch(lastAlivePlayers[CS_TEAM_CT], CS_TEAM_CT, aliveCounts[CS_TEAM_T]);
    }
}

/**
 * 统计当前 T/CT 存活人数和每队最后一个存活玩家。
 */
void Mix_GetAliveTeamState(int aliveCounts[4], int lastAlivePlayers[4])
{
    Mix_GetAliveTeamStateIgnoring(aliveCounts, lastAlivePlayers, 0);
}

/**
 * 统计存活人数时排除指定客户端，用于断线事件顺序差异的保护。
 */
void Mix_GetAliveTeamStateIgnoring(int aliveCounts[4], int lastAlivePlayers[4], int ignoredClient)
{
    for (int team = 0; team < 4; team++) {
        aliveCounts[team] = 0;
        lastAlivePlayers[team] = 0;
    }

    for (int i = 1; i <= MaxClients; i++) {
        if (i == ignoredClient || !IsValidClient(i) || !IsPlayerAlive(i)) {
            continue;
        }

        int team = GetClientTeam(i);
        if (team == CS_TEAM_T || team == CS_TEAM_CT) {
            aliveCounts[team]++;
            lastAlivePlayers[team] = i;
        }
    }
}

/**
 * 非死亡事件导致人数变化后，补齐残局检测或即时结算。
 */
void Mix_Stats_RecheckClutchState()
{
    Mix_Stats_RecheckClutchStateIgnoring(0);
}

/**
 * 非死亡事件导致人数变化后，排除指定客户端再重算残局。
 */
void Mix_Stats_RecheckClutchStateIgnoring(int ignoredClient)
{
    if (!g_bStatsEnabled) {
        return;
    }

    int aliveCounts[4];
    int lastAlivePlayers[4];
    Mix_GetAliveTeamStateIgnoring(aliveCounts, lastAlivePlayers, ignoredClient);

    if (!g_bClutchActive) {
        if (aliveCounts[CS_TEAM_T] == 1 && aliveCounts[CS_TEAM_CT] >= 2) {
            Mix_StartClutch(lastAlivePlayers[CS_TEAM_T], CS_TEAM_T, aliveCounts[CS_TEAM_CT]);
        } else if (aliveCounts[CS_TEAM_CT] == 1 && aliveCounts[CS_TEAM_T] >= 2) {
            Mix_StartClutch(lastAlivePlayers[CS_TEAM_CT], CS_TEAM_CT, aliveCounts[CS_TEAM_T]);
        }
        return;
    }

    if (g_iClutchTeam != CS_TEAM_T && g_iClutchTeam != CS_TEAM_CT) {
        Mix_ResetClutchRoundState();
        return;
    }

    int enemyTeam = (g_iClutchTeam == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T;
    if (aliveCounts[g_iClutchTeam] <= 0) {
        Mix_Stats_ResolveClutch(enemyTeam);
    } else if (aliveCounts[enemyTeam] <= 0) {
        Mix_Stats_ResolveClutch(g_iClutchTeam);
    }
}

/**
 * 标记当前回合的残局玩家。
 */
void Mix_StartClutch(int client, int team, int enemyCount)
{
    if (!IsValidClient(client)) {
        return;
    }

    g_bClutchActive = true;
    g_iClutchPlayer = client;
    g_iClutchUserId = GetClientUserId(client);
    g_iClutchTeam = team;
    g_iClutchEnemyCount = enemyCount;

    char playerName[MAX_NAME_LENGTH];
    GetClientName(client, playerName, sizeof(playerName));

    PrintToChatAll("\x04[%s]:\x03 %s 进入了 1v%d 残局", MODNAME, playerName, enemyCount);
}

/**
 * 回合结束时结算残局胜负。
 */
void Mix_Stats_ResolveClutch(int winningTeam)
{
    if (!g_bStatsEnabled || !g_bClutchActive) {
        return;
    }

    if (g_iClutchPlayer < 1 || g_iClutchPlayer > MaxClients || (winningTeam != CS_TEAM_T && winningTeam != CS_TEAM_CT)) {
        Mix_ResetClutchRoundState();
        return;
    }

    char playerName[MAX_NAME_LENGTH];
    if (IsClientInGame(g_iClutchPlayer)) {
        GetClientName(g_iClutchPlayer, playerName, sizeof(playerName));
    } else {
        strcopy(playerName, sizeof(playerName), "离线玩家");
    }

    if (winningTeam == g_iClutchTeam) {
        g_PlayerStats[g_iClutchPlayer].clutches++;
        PrintToChatAll("\x04[%s]:\x03 %s 赢下了 1v%d 残局", MODNAME, playerName, g_iClutchEnemyCount);
    } else {
        g_PlayerStats[g_iClutchPlayer].clutch_losses++;
        PrintToChatAll("\x04[%s]:\x03 %s 输掉了 1v%d 残局", MODNAME, playerName, g_iClutchEnemyCount);
    }

    Mix_ResetClutchRoundState();
}

/**
 * 残局玩家断线时立即按失败结算，避免回合结束时 slot 被复用后记错人。
 */
void Mix_Stats_HandleClutchDisconnect(int client, int userid)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (g_bClutchActive) {
        if (client != g_iClutchPlayer && userid != g_iClutchUserId) {
            Mix_Stats_RecheckClutchStateIgnoring(client);
            return;
        }

        if (g_iClutchPlayer >= 1 && g_iClutchPlayer <= MaxClients) {
            g_PlayerStats[g_iClutchPlayer].clutch_losses++;
        }

        PrintToChatAll("\x04[%s]:\x03 残局玩家断开连接，记为 1v%d 残局失败", MODNAME, g_iClutchEnemyCount);
        Mix_ResetClutchRoundState();
        return;
    }

    Mix_Stats_RecheckClutchStateIgnoring(client);
}

/**
 * 残局期间玩家换队或进观察者时更新残局状态。
 */
void Mix_Stats_HandleClutchTeamChange(int client, int userid, int oldTeam, int newTeam)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (oldTeam != CS_TEAM_T && oldTeam != CS_TEAM_CT && newTeam != CS_TEAM_T && newTeam != CS_TEAM_CT) {
        return;
    }

    if (g_bClutchActive && (client == g_iClutchPlayer || userid == g_iClutchUserId) && newTeam != g_iClutchTeam) {
        if (g_iClutchPlayer >= 1 && g_iClutchPlayer <= MaxClients) {
            g_PlayerStats[g_iClutchPlayer].clutch_losses++;
        }
        PrintToChatAll("\x04[%s]:\x03 残局玩家离开原队伍，记为 1v%d 残局失败", MODNAME, g_iClutchEnemyCount);
        Mix_ResetClutchRoundState();
        return;
    }

    Mix_Stats_RecheckClutchState();
}

/**
 * 处理炸弹安装事件
 *
 * @param client 客户端ID
 */
void Mix_Stats_OnBombPlanted(int client)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (!IsValidClient(client)) {
        return;
    }

    // 记录炸弹安装
    g_PlayerStats[client].bomb_plants++;
}

/**
 * 处理炸弹拆除事件
 *
 * @param client 客户端ID
 */
void Mix_Stats_OnBombDefused(int client)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (!IsValidClient(client)) {
        return;
    }

    // 记录炸弹拆除
    g_PlayerStats[client].bomb_defuses++;
}

/**
 * 向所有玩家显示所有玩家的统计数据
 */
void Mix_ShowAllPlayersStats()
{
    if (!g_bStatsEnabled) {
        return;
    }

    // 创建一个数组来存储所有玩家的统计数据，按击杀数排序
    int playerCount = 0;
    int playerIds[MAXPLAYERS+1];

    // 收集所有有效玩家
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            playerIds[playerCount++] = i;
        }
    }

    // 按击杀数排序
    SortCustom1D(playerIds, playerCount, SortByKills);

    // 向所有玩家发送消息
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            SetGlobalTransTarget(i);
            PrintToChat(i, "\x04[%s]:\x03 %t", MODNAME, "Match Stats");
            PrintToChat(i, "\x04[%s]:\x03 %-20s %5s %5s %5s %5s %5s %6s", MODNAME, "玩家", "击杀", "死亡", "助攻", "爆头", "K/D", "残局");

            for (int j = 0; j < playerCount; j++) {
                int playerId = playerIds[j];
                char playerName[MAX_NAME_LENGTH];
                GetClientName(playerId, playerName, sizeof(playerName));

                // 如果名字太长，截断并添加...
                if (strlen(playerName) > 17) {
                    playerName[17] = '.';
                    playerName[18] = '.';
                    playerName[19] = '.';
                    playerName[20] = '\0';
                }

                char clutchText[16];
                Format(clutchText, sizeof(clutchText), "%d-%d", g_PlayerStats[playerId].clutches, g_PlayerStats[playerId].clutch_losses);

                PrintToChat(i, "\x04[%s]:\x03 %-15s %5d %5d %5d %5d %5.2f %6s",
                    MODNAME,
                    playerName,
                    g_PlayerStats[playerId].kills,
                    g_PlayerStats[playerId].deaths,
                    g_PlayerStats[playerId].assists,
                    g_PlayerStats[playerId].headshots,
                    g_PlayerStats[playerId].GetKDRatio(),
                    clutchText);
            }
        }
    }
}

/**
 * 按击杀数排序的比较函数
 */
public int SortByKills(int elem1, int elem2, const int[] array, Handle hndl)
{
    // 首先按击杀数排序
    if (g_PlayerStats[elem1].kills > g_PlayerStats[elem2].kills) return -1;
    if (g_PlayerStats[elem1].kills < g_PlayerStats[elem2].kills) return 1;

    // 如果击杀数相同，按死亡数排序（死亡少的排前面）
    if (g_PlayerStats[elem1].deaths < g_PlayerStats[elem2].deaths) return -1;
    if (g_PlayerStats[elem1].deaths > g_PlayerStats[elem2].deaths) return 1;

    return 0;
}

/**
 * 重置所有玩家的统计数据
 */
void Mix_ResetAllStats()
{
    Mix_ResetClutchRoundState();

    for (int i = 1; i <= MaxClients; i++) {
        g_PlayerStats[i].Reset();
        g_iLastKnownHealth[i] = 0;
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            SetEntProp(i, Prop_Data, "m_iFrags", 0);
            SetEntProp(i, Prop_Data, "m_iDeaths", 0);
        }
    }
}

/**
 * ConVar变更回调：统计系统启用状态
 */
public void OnStatsEnabledChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_bStatsEnabled = StringToInt(newValue) == 1;
    if (!g_bStatsEnabled) {
        Mix_ResetClutchRoundState();
    }
}
