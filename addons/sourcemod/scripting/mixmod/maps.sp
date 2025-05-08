/**
 * 地图管理模块
 */

#if defined _mixmod_maps_included
  #endinput
#endif
#define _mixmod_maps_included

/**
 * 初始化地图系统
 */
void Mix_InitMaps()
{
    if (g_hMapListMenu != INVALID_HANDLE) {
        CloseHandle(g_hMapListMenu);
        g_hMapListMenu = INVALID_HANDLE;
    }
    
    g_bIsMapListGenerated = false;
    Mix_CreateMapList();
}

/**
 * 创建地图列表
 */
void Mix_CreateMapList()
{
    if (!g_bIsMapListGenerated) {
        int mapCount = 0;
        
        // 清空地图名称数组
        for (int i = 0; i < MAX_MAPS; i++) {
            g_szMapNames[i] = "";
        }
        
        if (GetConVarInt(g_hCvarMapListFrom) == 0) {
            // 从maps目录生成地图列表
            Handle dirHandle = OpenDirectory("maps");
            if (dirHandle != INVALID_HANDLE) {
                char fileName[64];
                char mapName[64];
                FileType fileType;
                
                while (ReadDirEntry(dirHandle, fileName, sizeof(fileName), fileType)) {
                    if (fileType == FileType_File) {
                        int len = strlen(fileName);
                        if (len > 4 && StrEqual(fileName[len-4], ".bsp", false)) {
                            fileName[len-4] = '\0';
                            
                            if (StrContains(fileName, "de_", false) == 0 || 
                                StrContains(fileName, "cs_", false) == 0 || 
                                StrContains(fileName, "aim_", false) == 0) {
                                strcopy(mapName, sizeof(mapName), fileName);
                                strcopy(g_szMapNames[mapCount++], 32, mapName);
                                
                                if (mapCount >= MAX_MAPS) {
                                    break;
                                }
                            }
                        }
                    }
                }
                CloseHandle(dirHandle);
            }
        } else {
            // 从mapcycle.txt生成地图列表
            Handle mapCycleFile = OpenFile("mapcycle.txt", "r");
            if (mapCycleFile != INVALID_HANDLE) {
                char readData[64];
                
                while (!IsEndOfFile(mapCycleFile) && ReadFileLine(mapCycleFile, readData, sizeof(readData))) {
                    TrimString(readData);
                    
                    if (strlen(readData) > 0 && readData[0] != '/' && readData[0] != '#') {
                        strcopy(g_szMapNames[mapCount++], 32, readData);
                        
                        if (mapCount >= MAX_MAPS) {
                            break;
                        }
                    }
                }
                CloseHandle(mapCycleFile);
            }
        }
        
        if (mapCount <= 0) {
            PrintToChatAll("\x04[%s]:\x03 创建地图列表失败! 请联系管理员", MODNAME);
            return;
        }
        
        g_bIsMapListGenerated = true;
        
        // 创建地图列表菜单
        if (g_hMapListMenu != INVALID_HANDLE) {
            CloseHandle(g_hMapListMenu);
            g_hMapListMenu = INVALID_HANDLE;
        }
        
        g_hMapListMenu = CreateMenu(Mix_HandleMapListMenu);
        SetMenuTitle(g_hMapListMenu, "选择地图:");
        
        for (int i = 0; i < mapCount; i++) {
            AddMenuItem(g_hMapListMenu, g_szMapNames[i], g_szMapNames[i]);
        }
        
        SetMenuExitButton(g_hMapListMenu, true);
    }
}

/**
 * 地图列表菜单处理
 */
public int Mix_HandleMapListMenu(Handle menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select) {
        char mapName[32];
        GetMenuItem(menu, param2, mapName, sizeof(mapName));
        
        g_szMatchMap = mapName;
        
        char adminName[MAX_NAME_LENGTH];
        GetClientName(param1, adminName, sizeof(adminName));
        
        PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03选择了地图 \x04%s", MODNAME, adminName, mapName);
        
        // 延迟更换地图
        CreateTimer(3.0, Mix_ChangeMap, param1);
    } else if (action == MenuAction_End) {
        // 菜单关闭，不需要额外操作
    }
    
    return 0;
}

/**
 * 更换地图定时器回调
 */
public Action Mix_ChangeMap(Handle timer, int client)
{
    if (strlen(g_szMatchMap) > 0) {
        PrintToChatAll("\x04[%s]:\x03 正在更换地图到 \x04%s", MODNAME, g_szMatchMap);
        ServerCommand("changelevel %s", g_szMatchMap);
    } else {
        PrintToChat(client, "\x04[%s]:\x03 地图名称无效!", MODNAME);
    }
    
    return Plugin_Continue;
}

/**
 * 执行mr12配置
 */
void Mix_ExecuteMr12Config(int client)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        char customCfg[32];
        GetConVarString(g_hCvarCustomLiveCfg, customCfg, sizeof(customCfg));
        
        PrintToChatAll("\x04[%s]:\x03 正在执行 \x04%s \x03...", MODNAME, customCfg);
        
        ServerCommand("exec %s", customCfg);
        Mix_StartRecord(client);
    }
}

/**
 * 执行练习配置
 */
void Mix_ExecutePracConfig(int client)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        char customCfg[32];
        if (GetConVarInt(g_hCvarStopCustomCfg) == 1) {
            customCfg = "prac.cfg";
        } else {
            GetConVarString(g_hCvarCustomPracCfg, customCfg, sizeof(customCfg));
        }
        Mix_ResetMatchState();
        if (client != 0) {
            char name[33];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03执行了 \x04%s", MODNAME, name, customCfg);
        } else {
            PrintToChatAll("\x04[%s]:\x03 正在执行 \x04%s \x03...", MODNAME, customCfg);
        }
        
        ServerCommand("exec %s", customCfg);
        Mix_StopRecord(client, 1);
    }
}

/**
 * 执行mr3配置
 */
void Mix_ExecuteMr3Config(int client)
{
    if (GetConVarInt(g_hCvarEnabled) == 1) {
        char customCfg[32];
        GetConVarString(g_hCvarCustomMr3Cfg, customCfg, sizeof(customCfg));
        
        if (client != 0) {
            char name[33];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03执行了 \x04%s", MODNAME, name, customCfg);
        } else {
            PrintToChatAll("\x04[%s]:\x03 正在执行 \x04%s \x03...", MODNAME, customCfg);
        }
        
        ServerCommand("exec %s", customCfg);
    }
}

/**
 * 开始录制
 */
void Mix_StartRecord(int client)
{
    if (GetConVarInt(g_hCvarEnableAutoSourceTVRecord) == 1 && !g_bIsRecording) {
        char mapName[64];
        char teamAName[32];
        char teamBName[32];
        char date[32];
        char timeStr[32];
        char folder[64];
        char filePath[128];
        
        GetCurrentMap(mapName, sizeof(mapName));
        GetConVarString(g_hCvarCusomNameTeamCT, teamAName, sizeof(teamAName));
        GetConVarString(g_hCvarCusomNameTeamT, teamBName, sizeof(teamBName));
        GetConVarString(g_hCvarAutoSourceTVRecordSaveDir, folder, sizeof(folder));
        
        FormatTime(date, sizeof(date), "%Y-%m-%d", GetTime());
        FormatTime(timeStr, sizeof(timeStr), "%H-%M", GetTime());
        
        Format(filePath, sizeof(filePath), "%s/%s_%s-vs-%s_%s_%s", folder, mapName, teamAName, teamBName, date, timeStr);
        
        if (client == 0) {
            if (g_bIsItManual) {
                PrintToChatAll("\x04[%s]:\x03 开始录制比赛 \x04%s \x03到文件 \x04%s", MODNAME, mapName, filePath);
            }
        } else {
            char name[33];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03开始录制", MODNAME, name);
        }
        
        ServerCommand("tv_record %s", filePath);
        g_bIsRecording = true;
        
        if (client != 0) {
            g_bIsRecordManual = true;
        }
    }
}

/**
 * 停止录制
 */
void Mix_StopRecord(int client, int inform)
{
    if (GetConVarInt(g_hCvarEnableAutoSourceTVRecord) == 1 && g_bIsRecording) {
        if (client == 0) {
            if (g_bIsItManual && inform != 0) {
                PrintToChatAll("\x04[%s]:\x03 停止录制", MODNAME);
            }
        } else {
            char name[33];
            GetClientName(client, name, sizeof(name));
            PrintToChatAll("\x04[%s]:\x03 管理员 \x04%s \x03停止录制", MODNAME, name);
        }
        
        ServerCommand("tv_stoprecord");
        g_bIsRecording = false;
        g_bIsRecordManual = false;
    }
}

/**
 * 投票更换地图
 */
void Mix_VoteMap()
{
    if (!g_bIsMapListGenerated) {
        Mix_CreateMapList();
    }
    
    if (!g_bIsMapListGenerated) {
        PrintToChatAll("\x04[%s]:\x03 未能创建地图列表!", MODNAME);
        return;
    }
    
    Handle mapVoteMenu = CreateMenu(Mix_HandleMapVoteMenu);
    SetMenuTitle(mapVoteMenu, "选择地图:");
    
    int mapCount = 0;
    for (int i = 0; i < MAX_MAPS; i++) {
        if (strlen(g_szMapNames[i]) > 0) {
            AddMenuItem(mapVoteMenu, g_szMapNames[i], g_szMapNames[i]);
            mapCount++;
        }
    }
    
    if (mapCount <= 0) {
        PrintToChatAll("\x04[%s]:\x03 地图列表为空!", MODNAME);
        CloseHandle(mapVoteMenu);
        return;
    }
    
    SetMenuExitButton(mapVoteMenu, false);
    Mix_VoteMenuToAll(mapVoteMenu, 20, 0);
    
    PrintToChatAll("\x04[%s]:\x03 开始地图投票", MODNAME);
    g_bHasVoteMap = true;
}

/**
 * 地图投票菜单处理
 */
public int Mix_HandleMapVoteMenu(Handle menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End) {
        CloseHandle(menu);
    } else if (action == MenuAction_VoteEnd) {
        char mapName[32];
        GetMenuItem(menu, param1, mapName, sizeof(mapName));
        
        g_szMatchMap = mapName;
        PrintToChatAll("\x04[%s]:\x03 投票结果: \x04%s\x03, 准备更换地图...", MODNAME, mapName);
        
        // 延迟更换地图
        CreateTimer(3.0, Mix_ChangeMap, 0);
    }
    
    return 0;
} 