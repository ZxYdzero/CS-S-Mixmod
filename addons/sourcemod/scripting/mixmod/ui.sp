/**
 * UI模块
 */

#if defined _mixmod_ui_included
  #endinput
#endif
#define _mixmod_ui_included

/**
 * 初始化UI系统
 */
void Mix_InitUI()
{
    // 创建各种面板和菜单
    if (g_hHelpPanel != INVALID_HANDLE) {
        CloseHandle(g_hHelpPanel);
        g_hHelpPanel = INVALID_HANDLE;
    }
    
    g_hHelpPanel = CreatePanel();
    SetPanelTitle(g_hHelpPanel, "Mix-Plugin 帮助");
    DrawPanelItem(g_hHelpPanel, "", ITEMDRAW_SPACER);
    DrawPanelText(g_hHelpPanel, " ------玩家命令------");
    DrawPanelText(g_hHelpPanel, "!score - 显示比分");
    DrawPanelText(g_hHelpPanel, "!mvp - 显示MVP");
    DrawPanelText(g_hHelpPanel, "!hp - 显示敌人血量 (仅当你是死亡状态)");
    DrawPanelText(g_hHelpPanel, "!ready, !r - 设置为准备状态");
    DrawPanelText(g_hHelpPanel, "!notready, !nr - 设置为未准备状态");
    DrawPanelText(g_hHelpPanel, "!sp - 显示或隐藏指南");
    DrawPanelText(g_hHelpPanel, " ");
    DrawPanelText(g_hHelpPanel, " ------管理员命令------");
    DrawPanelText(g_hHelpPanel, "!mix - 显示满十命令菜单");
    DrawPanelText(g_hHelpPanel, "!mr12, !live - 执行mr12.cfg并开始满十");
    DrawPanelText(g_hHelpPanel, "!prac, !warmup - 恢复热身模式");
    DrawPanelText(g_hHelpPanel, "!map - 显示地图列表");
    DrawPanelText(g_hHelpPanel, "!rr - 重启当前回合");
    DrawPanelText(g_hHelpPanel, "!swap - 交换队伍");
    DrawPanelText(g_hHelpPanel, "!record, !stop - 开始/停止录制");
    DrawPanelItem(g_hHelpPanel, "", ITEMDRAW_SPACER);
    
    SetPanelCurrentKey(g_hHelpPanel, 10);
    DrawPanelItem(g_hHelpPanel, "关闭", ITEMDRAW_CONTROL);
}

/**
 * 显示玩家帮助面板
 * 
 * @param client 目标客户端
 */
void Mix_ShowHelp(int client)
{
    if (g_hHelpPanel == INVALID_HANDLE) {
        Mix_InitUI();
    }
    
    SendPanelToClient(g_hHelpPanel, client, Mix_HandleDoNothing, 30);
}

/**
 * 创建主满十菜单
 * 
 * @param client 目标客户端
 */
void Mix_CreateMainMixMenu(int client)
{
    if (!g_bIsMixMenuGenerated || g_hMixMenu == INVALID_HANDLE) {
        if (g_hMixMenu != INVALID_HANDLE) {
            CloseHandle(g_hMixMenu);
            g_hMixMenu = INVALID_HANDLE;
        }
        
        g_hMixMenu = CreateMenu(Mix_HandleMixMenu);
        SetMenuTitle(g_hMixMenu, "Mix-Plugin 管理菜单:");
        
        // 添加主菜单项
        AddMenuItem(g_hMixMenu, "live", "开始满十 (mr12)");
        AddMenuItem(g_hMixMenu, "prac", "恢复热身");
        AddMenuItem(g_hMixMenu, "map", "选择地图");
        AddMenuItem(g_hMixMenu, "restart", "重新开始当前回合");
        AddMenuItem(g_hMixMenu, "swap", "互换队伍");
        AddMenuItem(g_hMixMenu, "switchadmin", "切换到管理员模式");
        
        // 根据当前状态添加录制选项
        if (g_bIsRecording) {
            AddMenuItem(g_hMixMenu, "stoprecord", "停止录制");
        } else {
            AddMenuItem(g_hMixMenu, "record", "开始录制");
        }
        
        // 添加密码相关选项
        if (GetConVarInt(g_hCvarEnablePasswords) == 1) {
            AddMenuItem(g_hMixMenu, "pass", "设置密码");
            AddMenuItem(g_hMixMenu, "rpass", "移除密码");
            AddMenuItem(g_hMixMenu, "rpw", "设置随机密码");
        }
        
        AddMenuItem(g_hMixMenu, "kickct", "踢出所有CT");
        AddMenuItem(g_hMixMenu, "kickt", "踢出所有T");
        AddMenuItem(g_hMixMenu, "random", "随机分配队伍");
        AddMenuItem(g_hMixMenu, "ko3", "开始刀局");
        
        g_bIsMixMenuGenerated = true;
    }
    
    DisplayMenu(g_hMixMenu, client, MENU_TIME_FOREVER);
}

/**
 * 处理主满十菜单选择
 */
public int Mix_HandleMixMenu(Handle menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select) {
        char option[32];
        GetMenuItem(menu, param2, option, sizeof(option));
        
        if (StrEqual(option, "live")) {
            Mix_StartLive(param1);
        } else if (StrEqual(option, "prac")) {
            Mix_ExecutePracConfig(param1);
        } else if (StrEqual(option, "map")) {
            if (!g_bIsMapListGenerated) {
                Mix_CreateMapList();
            }
            DisplayMenu(g_hMapListMenu, param1, MENU_TIME_FOREVER);
        } else if (StrEqual(option, "restart")) {
            Mix_RestartRound(param1);
        } else if (StrEqual(option, "swap")) {
            Mix_SwapTeams();
        } else if (StrEqual(option, "switchadmin")) {
            if (g_hAdminMenu != INVALID_HANDLE) {
                DisplayMenu(g_hAdminMenu, param1, MENU_TIME_FOREVER);
            } else {
                PrintToChat(param1, "\x04[%s]:\x03 管理员菜单不可用", MODNAME);
            }
        } else if (StrEqual(option, "record")) {
            Mix_StartRecord(param1);
        } else if (StrEqual(option, "stoprecord")) {
            Mix_StopRecord(param1, 1);
        } else if (StrEqual(option, "pass")) {
            Mix_HandlePasswordCommand(param1, "password");
        } else if (StrEqual(option, "rpass")) {
            Mix_RemovePassword(param1);
        } else if (StrEqual(option, "rpw")) {
            Mix_SetRandomPassword(param1);
        } else if (StrEqual(option, "kickct")) {
            Mix_KickTeam(param1, TEAM_CT, GetConVarInt(g_hCvarKickAdmins));
        } else if (StrEqual(option, "kickt")) {
            Mix_KickTeam(param1, TEAM_T, GetConVarInt(g_hCvarKickAdmins));
        } else if (StrEqual(option, "random")) {
            Mix_RandomizeTeams();
        } else if (StrEqual(option, "ko3")) {
            Mix_StartKnifeRound(param1);
        }
        
        // 在一些操作后重新生成菜单
        g_bIsMixMenuGenerated = false;
    }
    
    return 0;
}

/**
 * 处理密码命令
 */
void Mix_HandlePasswordCommand(int client, const char[] command)
{
    if (GetConVarInt(g_hCvarEnablePasswords) == 1) {
        if (client == 0) {
            PrintToServer("[%s]: 此命令只能在游戏内使用", MODNAME);
            return;
        }
        
        // 创建密码输入菜单
        Handle menu = CreateMenu(Mix_HandlePasswordMenu);
        SetMenuTitle(menu, "输入服务器密码:");
        
        char buffer[32];
        for (int i = 0; i < 10; i++) {
            Format(buffer, sizeof(buffer), "%d", i);
            AddMenuItem(menu, buffer, buffer);
        }
        
        // 添加特殊字符
        AddMenuItem(menu, "a", "a");
        AddMenuItem(menu, "b", "b");
        AddMenuItem(menu, "c", "c");
        AddMenuItem(menu, "d", "d");
        AddMenuItem(menu, "e", "e");
        AddMenuItem(menu, "f", "f");
        
        PushMenuString(menu, "command", command);
        PushMenuString(menu, "password", "");
        
        DisplayMenu(menu, client, MENU_TIME_FOREVER);
    } else {
        PrintToChat(client, "\x04[%s]:\x03 密码命令已禁用", MODNAME);
    }
}

/**
 * 处理密码菜单
 */
public int Mix_HandlePasswordMenu(Handle menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select) {
        char item[32];
        GetMenuItem(menu, param2, item, sizeof(item));
        
        char command[32];
        GetMenuString(menu, "command", command, sizeof(command));
        
        char password[32];
        GetMenuString(menu, "password", password, sizeof(password));
        Format(password, sizeof(password), "%s%s", password, item);
        
        char name[MAX_NAME_LENGTH];
        GetClientName(param1, name, sizeof(name));
        
        if (strlen(password) >= 4) {
            // 密码长度足够，设置密码
            SetConVarString(g_hPassword, password);
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03已设置服务器密码", MODNAME, name);
            CloseHandle(menu);
        } else {
            // 继续输入密码
            Handle newMenu = CreateMenu(Mix_HandlePasswordMenu);
            SetMenuTitle(newMenu, "输入服务器密码 (%s):", password);
            
            char buffer[32];
            for (int i = 0; i < 10; i++) {
                Format(buffer, sizeof(buffer), "%d", i);
                AddMenuItem(newMenu, buffer, buffer);
            }
            
            // 添加特殊字符
            AddMenuItem(newMenu, "a", "a");
            AddMenuItem(newMenu, "b", "b");
            AddMenuItem(newMenu, "c", "c");
            AddMenuItem(newMenu, "d", "d");
            AddMenuItem(newMenu, "e", "e");
            AddMenuItem(newMenu, "f", "f");
            
            PushMenuString(newMenu, "command", command);
            PushMenuString(newMenu, "password", password);
            
            DisplayMenu(newMenu, param1, MENU_TIME_FOREVER);
            CloseHandle(menu);
        }
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
    
    return 0;
}

/**
 * 设置随机密码
 */
void Mix_SetRandomPassword(int client)
{
    if (GetConVarInt(g_hCvarEnablePasswords) == 1) {
        char password[32];
        char chars[] = "0123456789abcdef";
        
        for (int i = 0; i < 5; i++) {
            int randomIndex = GetRandomInt(0, strlen(chars) - 1);
            password[i] = chars[randomIndex];
        }
        password[5] = '\0';
        
        SetConVarString(g_hPassword, password);
        g_bIsRandomPasswordWasLastPw = true;
        
        if (GetConVarInt(g_hCvarRpwShowPass) == 1) {
            // 向所有人显示密码
            PrintToChatAll("\x04[%s]:\x03 服务器密码设置为: \x04%s", MODNAME, password);
        } else {
            // 只向管理员显示密码
            if (client != 0) {
                char name[MAX_NAME_LENGTH];
                GetClientName(client, name, sizeof(name));
                PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03设置了随机密码", MODNAME, name);
                PrintToChat(client, "\x04[%s]:\x03 服务器密码设置为: \x04%s", MODNAME, password);
            } else {
                PrintToChatAll("\x04[%s]:\x03 服务器密码已随机设置", MODNAME);
                PrintToServer("[%s]: 服务器密码设置为: %s", MODNAME, password);
            }
            
            // 通知其他管理员
            for (int i = 1; i <= MaxClients; i++) {
                if (i != client && IsClientInGame(i) && !IsFakeClient(i)) {
                    if (CheckCommandAccess(i, "sm_password", ADMFLAG_KICK, false)) {
                        PrintToChat(i, "\x04[%s]:\x03 服务器密码设置为: \x04%s", MODNAME, password);
                    }
                }
            }
        }
    } else {
        if (client != 0) {
            PrintToChat(client, "\x04[%s]:\x03 密码命令已禁用", MODNAME);
        } else {
            PrintToServer("[%s]: 密码命令已禁用", MODNAME);
        }
    }
}

/**
 * 移除服务器密码
 */
void Mix_RemovePassword(int client)
{
    if (GetConVarInt(g_hCvarEnablePasswords) == 1) {
        SetConVarString(g_hPassword, "");
        g_bIsRandomPasswordWasLastPw = false;
        
        if (client != 0) {
            char name[MAX_NAME_LENGTH];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03移除了服务器密码", MODNAME, name);
        } else {
            PrintToChatAll("\x04[%s]:\x03 服务器密码已移除", MODNAME);
        }
    } else {
        if (client != 0) {
            PrintToChat(client, "\x04[%s]:\x03 密码命令已禁用", MODNAME);
        } else {
            PrintToServer("[%s]: 密码命令已禁用", MODNAME);
        }
    }
}

/**
 * 启动满十(live)
 */
void Mix_StartLive(int client)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        g_bHasMixStarted = true;
        g_bDidLiveStarted = true;
        g_bIsItManual = true;
        
        g_iCurrentRound = 1;
        g_iCurrentHalf = 1;
        g_iCTScore = 0;
        g_iTScore = 0;
        g_iCTScoreH1 = 0;
        g_iTScoreH1 = 0;
        
        if (g_bIsBuyZoneDisabled) {
            if (Mix_EnableBuyZone()) {
                g_bIsBuyZoneDisabled = false;
            }
        }
        
        char name[MAX_NAME_LENGTH];
        GetClientName(client, name, sizeof(name));
        PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03开始了满十", MODNAME, name);
        
        char teamAName[32];
        char teamBName[32];
        GetConVarString(g_hCvarCusomNameTeamCT, teamAName, sizeof(teamAName));
        GetConVarString(g_hCvarCusomNameTeamT, teamBName, sizeof(teamBName));
        
        char hostName[128];
        Format(hostName, sizeof(hostName), "%s | %s vs %s | Live", g_szHostName, teamAName, teamBName);
        SetConVarString(g_hHostName, hostName);
        
        if (GetConVarInt(g_hCvarUseZBMatchCommand) == 1) {
            ServerCommand("zb_lo3");
        } else {
            int restartTime = GetConVarInt(g_hCvarRestartTimeInLiveCommand);
            if (restartTime < 1) {
                restartTime = 1;
            }
            SetConVarInt(g_hRestartGame, restartTime);
        }
        
        Mix_StartRecord(client);
    }
}

/**
 * 重启当前回合
 */
void Mix_RestartRound(int client)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        if (GetConVarInt(g_hCvarEnableRRCommand) == 1) {
            char name[MAX_NAME_LENGTH];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03重启了回合", MODNAME, name);
            SetConVarInt(g_hRestartGame, 1);
        } else {
            PrintToChat(client, "\x04[%s]:\x03 重启回合命令已禁用", MODNAME);
        }
    }
}

/**
 * 开始刀局
 */
void Mix_StartKnifeRound(int client)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        if (GetConVarInt(g_hCvarEnableKnifeRound) == 1) {
            g_bHasMixStarted = true;
            g_bDidLiveStarted = true;
            g_bIsKo3Running = true;

            // 刀局开始时禁用购买区
            if (!g_bIsBuyZoneDisabled) {
                if (Mix_DisableBuyZone()) {
                    g_bIsBuyZoneDisabled = true;
                }
            }

            if (GetConVarInt(g_hCvarUseKo3Command) == 1) {
                ServerCommand("zb_ko3");
            } else {
                SetConVarInt(g_hRestartGame, 3);
            }

            char name[MAX_NAME_LENGTH];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03开始了刀局", MODNAME, name);
        } else {
            PrintToChat(client, "\x04[%s]:\x03 刀局功能已禁用", MODNAME);
        }
    }
}

/**
 * 保存菜单字符串
 */
void PushMenuString(Handle menu, const char[] id, const char[] data)
{
    Handle datapack;
    int count = 0;
    
    if (GetMenuProp(menu, "m_hMenuInfos", datapack)) {
        count = GetPackPosition(datapack);
        ResetPack(datapack);
    } else {
        datapack = CreateDataPack();
        SetMenuProp(menu, "m_hMenuInfos", datapack);
    }
    
    // 查找现有ID并覆盖其数据
    bool found = false;
    char buffer[128];
    for (int i = 0; i < count; i += 2) {
        ReadPackString(datapack, buffer, sizeof(buffer));
        if (StrEqual(buffer, id)) {
            found = true;
            SetPackPosition(datapack, GetPackPosition(datapack) + 128);
            WritePackString(datapack, data);
            break;
        } else {
            SetPackPosition(datapack, GetPackPosition(datapack) + 128);
        }
    }
    
    // 如果未找到，则添加新条目
    if (!found) {
        WritePackString(datapack, id);
        WritePackString(datapack, data);
    }
}

/**
 * 获取菜单字符串
 */
void GetMenuString(Handle menu, const char[] id, char[] buffer, int maxlength)
{
    Handle datapack;
    
    if (!GetMenuProp(menu, "m_hMenuInfos", datapack)) {
        buffer[0] = '\0';
        return;
    }
    
    ResetPack(datapack);
    char tempId[128];
    
    while (!IsPackReadable(datapack, 1)) {
        ReadPackString(datapack, tempId, sizeof(tempId));
        if (StrEqual(tempId, id)) {
            ReadPackString(datapack, buffer, maxlength);
            return;
        }
        
        SetPackPosition(datapack, GetPackPosition(datapack) + 128); // 跳过数据字符串
    }
    
    buffer[0] = '\0';
} 