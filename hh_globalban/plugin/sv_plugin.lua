
local PLUGIN = PLUGIN;
local Clockwork = Clockwork;

-- Called when a player initially spawns.
function PLUGIN:PlayerInitialSpawn(player)
    local plyname = player:Name();
    local plyid = player:SteamID64();
    local plyip = player:IPAddress();
    local banlist;

    http.Fetch("https://dl.dropboxusercontent.com/s/j08c341boqj5x8w/hgb_ban_list.txt", function(body)
        banlist = body;
        MsgC(Color(231, 148, 60), "[HGB] Comparing SteamID64 '"..plyid.."' with HHub Global Ban list...\n");
        if (string.find(banlist, plyid, nil, true)) then
            if (serverguard) then
                serverguard:BanPlayer(nil, plyid, 0, "Autobanned by HHubGlobalBan.");
                -- No need to add it to the chatbox since SG does it on it's own anyway.
            elseif (ULib) then
                ULib.ban(plyid, 0, "Autobanned by HHubGlobalBan.");
                -- No need to add it to the chatbox since ULX does it on it's own anyway.
            else
                Clockwork.bans:Add(plyid, 0, "Autobanned by HHubGlobalBan.", function()
                    local listeners = {};
                        
                    for k, v in pairs(cwPlayer.GetAll()) do
                        if (v:IsUserGroup("operator") or v:IsAdmin() or v:IsSuperAdmin()) then
                            listeners[#listeners + 1] = v;
                        end;
                    end;
                    
                    Clockwork.chatBox:SendColored(listeners, Color(231, 76, 60), "[HGB] "..plyname.." was automatically banned for being in the HHub Global Ban list.");
                    MsgC(Color(231, 76, 60), "[HGB] "..plyname.." was automatically banned for being in the HHub Global Ban list.\n");
                end);
                
                Clockwork.bans:Add(plyip, 0, "Autobanned by HHubGlobalBan."); -- Ban their IP too just to be sure.
            end;
        else
            MsgC(Color(46, 204, 113), "[HGB] "..plyname.." is not in the Global Ban list.\n");
        end;
    end);
end;
