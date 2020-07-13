
--[[------------------------------------------------------------------------------------------
    Half-Life 2 Roleplay Hub - Global Ban Plugin

    If you require support, have suggestions, questions, or concerns, please join our discord:
    https://discord.gg/hyPtDAF
--]]------------------------------------------------------------------------------------------

local PLUGIN = PLUGIN;
local Clockwork = Clockwork;

-- Called when a player initially spawns.
function PLUGIN:PlayerInitialSpawn(player) -- It'd be better to do this at CheckPassword()
    local plyName = player:Name(); -- But then we'd have to hook onto the DB to check for bans and it's just not worth the hussle.
    local plyID = player:SteamID64();
    local plyIp = player:IPAddress();
    local banList;

    http.Fetch("https://dl.dropboxusercontent.com/s/j08c341boqj5x8w/hgb_ban_list.txt", function(body)
        banList = body;
        MsgC(Color(231, 148, 60), "[HGB] Comparing SteamID64 '"..plyID.."' with HHub Global Ban list...\n");
        if (string.find(banList, plyID, nil, true)) then
            if (PLUGIN:IsWhitelisted(plyID)) then
                MsgC(Color(231, 148, 60), "[HGB] "..plyName.." is in the HHub Global Ban list but is whitelisted.\n");
            else
                if (serverguard) then
                    serverguard:BanPlayer(nil, plyID, 0, "Autobanned by HHubGlobalBan");
                    -- No need to add it to the chatbox since SG does it on it's own anyway.
                elseif (ULib) then
                    ULib.ban(plyID, 0, "Autobanned by HHubGlobalBan");
                    -- No need to add it to the chatbox since ULX does it on it's own anyway.
                else
                    Clockwork.bans:Add(plyID, 0, "Autobanned by HHubGlobalBan", function()
                        local listeners = {};
                            
                        for k, v in pairs(cwPlayer.GetAll()) do
                            if (v:IsUserGroup("operator") or v:IsAdmin() or v:IsSuperAdmin()) then
                                listeners[#listeners + 1] = v;
                            end;
                        end;
                        
                        Clockwork.chatBox:SendColored(listeners, Color(231, 76, 60), "[HGB] "..plyName.." was automatically banned for being in the HHub Global Ban list.");
                        MsgC(Color(231, 76, 60), "[HGB] "..plyName.." was automatically banned for being in the HHub Global Ban list.\n");
                    end);
                    
                    Clockwork.bans:Add(plyIp, 0, "Autobanned by HHubGlobalBan"); -- Ban their IP too just to be sure.
                end;
            end;
        else
            MsgC(Color(46, 204, 113), "[HGB] "..plyName.." is not in the Global Ban list.\n");
        end;
    end);
end;
