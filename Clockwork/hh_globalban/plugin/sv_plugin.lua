
--[[------------------------------------------------------------------------------------------
    Half-Life 2 Roleplay Hub - Global Ban Plugin

    If you require support, have suggestions, questions, or concerns, please join our discord:
    https://discord.gg/hyPtDAF
--]]------------------------------------------------------------------------------------------

local PLUGIN = PLUGIN;
local Clockwork = Clockwork;

local kickReason = [[
    The HHub Global Ban system has denied your access to this server.

    This can happen for several reasons, including, but not limited to:
    - Using cheats in a server.
    - Server-griefing in any way (exploits, backdoors, etc).
    - Participating in targeted harassment (Doxing, DDoSing, etc).
    - Practicing sexual behavior with a minor in any way.

    If you believe this is a mistake, appeal your ban on the HHub Discord server, here:
    https://discord.gg/hyPtDAF]];

-- Called when a player connects to allow the Lua system to check the password.
function PLUGIN:CheckPassword(steamID64, ipAddress, svPassword, clPassword, name)
    http.Fetch("https://hl2rp.net/hgb/hgb_ban_list.txt", function(body)
        MsgC(Color(231, 148, 60), "[HGB] Comparing SteamID64 '"..steamID64.."' ("..name..") with HHub Global Ban list...\n");

        local _, endPos = string.find(body, steamID64, nil, true);

        if (endPos) then
            if (PLUGIN:IsWhitelisted(steamID64)) then
                MsgC(Color(231, 148, 60), "[HGB] "..name.." is in the HHub Global Ban list but is whitelisted.\n");
            else
                if (body[endPos + 1] == ")") then
                    for _, player in ipairs(player.GetAll()) do
                        if (player:IsAdmin()) then
                            player:ChatPrint("[HGB] Warning: Potentially malicious player ("..name..") has connected to the server!");
                        end;
                    end;
                else
                    local steamID = util.SteamIDFrom64(steamID64);

                    game.KickID(steamID, kickReason);
                    MsgC(Color(231, 76, 60), "[HGB] "..name.." was automatically kicked for being in the HHub Global Ban list.\n");
                end;
            end;
        else
            MsgC(Color(46, 204, 113), "[HGB] "..name.." is not in the Global Ban list.\n");
        end;
    end);
end;
