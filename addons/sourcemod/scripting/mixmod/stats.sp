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
    int clutches;          // 残局获胜次数
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

    PrintToChat(client, "\x04[%s]:\x03 伤害: \x04%d\x03  ADR: \x04%.1f\x03  命中率: \x04%.1f%%",
        MODNAME, g_PlayerStats[target].damage, g_PlayerStats[target].GetADR(), g_PlayerStats[target].GetAccuracy());

    PrintToChat(client, "\x04[%s]:\x03 残局获胜: \x04%d\x03  安装炸弹: \x04%d\x03  拆除炸弹: \x04%d",
        MODNAME, g_PlayerStats[target].clutches, g_PlayerStats[target].bomb_plants, g_PlayerStats[target].bomb_defuses);
}

// =============================================================================
// 事件处理
// =============================================================================

/**
 * 回合开始时重置回合伤害数据
 */
void Mix_Stats_OnRoundStart()
{
    if (!g_bStatsEnabled) {
        return;
    }

    // 重置回合伤害数据
    for (int i = 1; i <= MaxClients; i++) {
        for (int j = 1; j <= MaxClients; j++) {
            g_RoundDamage[i][j] = 0;
        }

        // 重置残局状态
        g_bInClutchSituation[i] = false;
        g_iClutchEnemyCount[i] = 0;
    }

    // 增加参与回合数
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) > 1) {
            g_PlayerStats[i].rounds_played++;
        }
    }
}

/**
 * 处理玩家伤害事件
 *
 * @param attacker 攻击者ID
 * @param victim 受害者ID
 * @param damage 伤害值
 * @param headshot 是否爆头
 */
void Mix_Stats_OnPlayerHurt(int attacker, int victim, int damage, bool headshot)
{
    if (!g_bStatsEnabled) {
        return;
    }

    if (!IsValidClient(attacker) || !IsValidClient(victim) || attacker == victim) {
        return;
    }

    // 记录伤害
    g_PlayerStats[attacker].damage += damage;
    g_RoundDamage[attacker][victim] += damage;

    // 记录爆头
    if (damage >= 100 && headshot) {
        g_PlayerStats[attacker].headshots ++;
    }

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

    // 记录死亡
    g_PlayerStats[victim].deaths++;

    if (!IsValidClient(attacker) || attacker == victim) {
        // 即使是自杀或无效击杀，也需要检查残局情况
        CheckClutchSituation();
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

    // 检查是否有玩家进入残局情况
    CheckClutchSituation();

    // 检查是否有玩家赢得残局
    CheckClutch(attacker);
}

// 残局相关函数

/**
 * 检查是否进入残局情况
 * 在每次玩家死亡时调用，检查是否有玩家进入残局情况
 */
void CheckClutchSituation()
{
    // 首先重置所有玩家的残局状态
    for (int i = 1; i <= MaxClients; i++) {
        g_bInClutchSituation[i] = false;
        g_iClutchEnemyCount[i] = 0;
    }

    // 检查T队和CT队
    for (int team = 2; team <= 3; team++) {
        // 计算队伍中存活的玩家数
        int aliveCount = 0;
        int lastAlivePlayer = -1;

        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == team) {
                aliveCount++;
                lastAlivePlayer = i;
            }
        }

        // 如果只有一名玩家存活，可能是残局情况
        if (aliveCount == 1 && lastAlivePlayer != -1) {
            // 计算敌队存活的玩家数
            int enemyTeam = (team == 2) ? 3 : 2;
            int enemyAliveCount = 0;

            for (int i = 1; i <= MaxClients; i++) {
                if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == enemyTeam) {
                    enemyAliveCount++;
                }
            }

            // 如果敌队至少有2名玩家，则标记为残局情况
            if (enemyAliveCount >= 2) {
                g_bInClutchSituation[lastAlivePlayer] = true;
                g_iClutchEnemyCount[lastAlivePlayer] = enemyAliveCount;

                char playerName[MAX_NAME_LENGTH];
                GetClientName(lastAlivePlayer, playerName, sizeof(playerName));

                // 通知玩家进入残局
                PrintToChatAll("\x04[%s]:\x03 %s 进入了1v%d残局情况!", MODNAME, playerName, enemyAliveCount);
            }
        }
    }
}

/**
 * 检查是否是残局获胜
 *
 * @param client 客户端ID
 */
void CheckClutch(int client)
{
    if (!IsValidClient(client)) {
        return;
    }

    int team = GetClientTeam(client);
    if (team <= 1) {
        return;
    }

    // 如果玩家不在残局情况中，直接返回
    if (!g_bInClutchSituation[client]) {
        return;
    }

    // 计算敌队存活的玩家数
    int enemyTeam = (team == 2) ? 3 : 2;
    int enemyAliveCount = 0;

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == enemyTeam) {
            enemyAliveCount++;
        }
    }

    // 如果敌队已经全部被消灭，则玩家赢得了残局
    if (enemyAliveCount == 0) {
        // 记录残局获胜
        g_PlayerStats[client].clutches++;

        char playerName[MAX_NAME_LENGTH];
        GetClientName(client, playerName, sizeof(playerName));

        // 输出残局获胜信息
        PrintToChatAll("\x04[%s]:\x03 %s 赢得了1v%d残局!", MODNAME, playerName, g_iClutchEnemyCount[client]);

        for (int j = 1; j <= MaxClients; j++) {
            if (IsClientInGame(j) && !IsFakeClient(j)) {
                SetGlobalTransTarget(j);
                PrintToChat(j, "\x04[%s]:\x03 %t", MODNAME, "Clutch Win", playerName, g_iClutchEnemyCount[client]);
            }
        }

        // 重置残局状态
        g_bInClutchSituation[client] = false;
        g_iClutchEnemyCount[client] = 0;
    }
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
            PrintToChat(i, "\x04[%s]:\x03 %-20s %5s %5s %5s %5s %5s", MODNAME, "玩家", "击杀", "死亡", "助攻", "爆头", "K/D");

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

                PrintToChat(i, "\x04[%s]:\x03 %-15s %5d %5d %5d %5d %5.2f",
                    MODNAME,
                    playerName,
                    g_PlayerStats[playerId].kills,
                    g_PlayerStats[playerId].deaths,
                    g_PlayerStats[playerId].assists,
                    g_PlayerStats[playerId].headshots,
                    g_PlayerStats[playerId].GetKDRatio());
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
    for (int i = 1; i <= MaxClients; i++) {
        g_PlayerStats[i].Reset();
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
}
