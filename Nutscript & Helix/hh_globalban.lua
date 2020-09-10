
--[[------------------------------------------------------------------------------------------
    Half-Life 2 Roleplay Hub - Global Ban Plugin

    If you require support, have suggestions, questions, or concerns, please join our discord:
    https://discord.gg/hyPtDAF
--]]------------------------------------------------------------------------------------------

PLUGIN.name = "HHub Global Ban"
PLUGIN.author = "Half-Life 2 Roleplay Hub"
PLUGIN.description = "A plugin which automatically bans malicious individuals based on a Global Ban list."
PLUGIN.version = "v4"

--[[
    Add people's Steam64IDs to this list to allow them to join your server regardless if they are in the Ban List or not.
    Please use causion when utilizing this feature - people are not added to the list for no reason.
    It is highly ill-advised using this feature.

    Here is how your list should look:
    PLUGIN.whitelist = {
        ["12345678901234567"] = true,
        ["12345678901234567"] = true,
        ["12345678901234567"] = true
    }
--]]

PLUGIN.whitelist = {}

-- A function to check if the player is whitelisted from the ban list.
function PLUGIN:IsWhitelisted(plyID)
    return PLUGIN.whitelist[plyID]
end

if (SERVER) then
	function PLUGIN:CheckVersion()
		MsgC(Color(231, 148, 60), "[HGB] The HHub Global Ban plugin has been initialized.\n")
		MsgC(Color(231, 148, 60), "[HGB] Local Version: "..self.version.."\n")
		MsgC(Color(231, 148, 60), "[HGB] Fetching for updates...\n")
		http.Fetch("https://hl2rp.org/hgb/hgb_version_control_nut.txt", function(body)
			local info = string.Explode("\n", body)
			local versions = {}
			for k,v in pairs(info) do
				local version_info = string.Explode(": ", v)
				versions[version_info[1]] = version_info[2]
			end

			if (versions["nutHHubGlobalBan"]) then
				if (versions["nutHHubGlobalBan"] == self.version) then
					MsgC(Color(46, 204, 113), "[HGB] The HHub Global Ban plugin is up to date!\n")
				else
					MsgC(Color(231, 76, 60), "[HGB] The HHub Global Ban plugin is out of date! Please install the latest version at your earliest convenience.\nYou may acquire the latest version from here: https://discord.gg/hyPtDAF\n")
					MsgC(Color(231, 76, 60), "[HGB] Local version: "..self.version.."\n")
					MsgC(Color(231, 76, 60), "[HGB] Newest version: "..versions["nutHHubGlobalBan"].."\n")
				end
			else
				MsgC(Color(231, 76, 60), "[HGB] Failed to fetch local version information!\n")
			end
		end, function()
			MsgC(Color(231, 76, 60), "[HGB] Failed to connect with Version Tracker!\n")
		end)
	end

	local initialized = false -- Ensure the plugin is initialized.
	function PLUGIN:Think() -- This shouldn't be done this way but it's the only way possible with ISteamHTTP.
		if (!initialized) then
			self:CheckVersion()
			initialized = true
		end
    end
    
    -- Called when a player initially spawns.
    function PLUGIN:PlayerInitialSpawn(player) -- It'd be better to do this at CheckPassword()
        local plyName = player:Name() -- But then we'd have to hook onto the DB to check for bans and it's just not worth the hussle.
        local plyID = player:SteamID64()
        local plyIp = player:IPAddress()
        local banlist

        http.Fetch("https://hl2rp.org/hgb/hgb_ban_list.txt", function(body)
			banlist = body
			MsgC(Color(231, 148, 60), "[HGB] Comparing SteamID64 '"..plyID.."' with HHub Global Ban list...\n")
			if (string.find(banlist, plyID, nil, true)) then
				if (PLUGIN:IsWhitelisted(plyID)) then
					MsgC(Color(231, 148, 60), "[HGB] "..plyName.." is in the HHub Global Ban list but is whitelisted.\n")
				else
					if (serverguard) then
						serverguard:BanPlayer(nil, plyID, 0, "Autobanned by HHubGlobalBan.")
						-- No need to add it to the chatbox since SG does it on its own anyway.
					elseif (ULib) then
						ULib.ban(plyID, 0, "Autobanned by HHubGlobalBan.")
						-- No need to add it to the chatbox since ULX does it on its own anyway.
					else
						player:Ban(0, true)
						RunConsoleCommand("addip", 0, plyIp) -- Ban their IP too just to be sure.
						MsgC(Color(231, 76, 60), "[HGB] "..plyName.." was automatically banned for being in the HHub Global Ban list.\n")
					end
				end
            else
                MsgC(Color(46, 204, 113), "[HGB] "..plyName.." is not in the Global Ban list.\n")
            end
        end)
    end
end
