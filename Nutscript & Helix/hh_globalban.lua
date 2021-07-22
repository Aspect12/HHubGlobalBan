
--[[------------------------------------------------------------------------------------------
	Half-Life 2 Roleplay Hub - Global Ban Plugin

	If you require support, have suggestions, questions, or concerns, please join our discord:
	https://discord.gg/hyPtDAF
--]]------------------------------------------------------------------------------------------

local PLUGIN = PLUGIN

PLUGIN.name = "HHub Global Ban"
PLUGIN.author = "Half-Life 2 Roleplay Hub"
PLUGIN.description = "A plugin which automatically bans malicious individuals based on a Global Ban list."
PLUGIN.version = "v6"

--[[
	Add people's Steam64IDs to this list to allow them to join your server regardless if they are in the Ban List or not.
	Please use causion when utilizing this feature - people are not added to the list for no reason.
	It is highly ill-advised to use this feature.

	Here is how your list should look:
	PLUGIN.whitelist = {
		["12345678901234567"] = true,
		["12345678901234567"] = true,
		["12345678901234567"] = true,
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
		MsgC(Color(231, 148, 60), "[HGB] Local Version: " .. self.version .. "\n")
		MsgC(Color(231, 148, 60), "[HGB] Fetching for updates...\n")

		http.Fetch("https://hl2rp.net/hgb/hgb_version_control_nut.txt", function(body)
			local info = string.Explode("\n", body)
			local versions = {}

			for _, v in pairs(info) do
				local version_info = string.Explode(": ", v)
				versions[version_info[1]] = version_info[2]
			end

			if (versions["nutHHubGlobalBan"]) then
				if (versions["nutHHubGlobalBan"] == self.version) then
					MsgC(Color(46, 204, 113), "[HGB] The HHub Global Ban plugin is up to date!\n")
				else
					MsgC(Color(231, 76, 60), "[HGB] The HHub Global Ban plugin is out of date! Please install the latest version at your earliest convenience.\nYou may acquire the latest version from here: https://discord.gg/hyPtDAF\n")
					MsgC(Color(231, 76, 60), "[HGB] Local version: " .. self.version .. "\n")
					MsgC(Color(231, 76, 60), "[HGB] Newest version: " .. versions["nutHHubGlobalBan"] .. "\n")
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

	local kickReason = [[
		The HHub Global Ban system has denied your access to this server.

		This can happen for several reasons, including, but not limited to:
		- Using cheats in a server.
		- Server-griefing in any way (exploits, backdoors, etc).
		- Participating in targeted harassment (Doxing, DDoSing, etc).
		- Practicing sexual behavior with a minor in any way.

		If you believe this is a mistake, appeal your ban on the HHub Discord server, here:
		https://discord.gg/hyPtDAF]]
	
	-- Called when a player connects to allow the Lua system to check the password.
	function PLUGIN:CheckPassword(steamID64, ipAddress, svPassword, clPassword, name)
		http.Fetch("https://hl2rp.net/hgb/hgb_ban_list.txt", function(body)
			MsgC(Color(231, 148, 60), "[HGB] Comparing SteamID64 '" .. steamID64 .. "' (" .. name .. ") with HHub Global Ban list...\n")

			local _, endPos = string.find(body, steamID64, nil, true)

			if (endPos) then
				if (PLUGIN:IsWhitelisted(steamID64)) then
					MsgC(Color(231, 148, 60), "[HGB] " .. name .. " is in the HHub Global Ban list but is whitelisted.\n")
				else
					if (body[endPos + 1] == ")") then
						for _, client in ipairs(player.GetAll()) do
							if (client:IsAdmin()) then
								client:ChatNotify("[HGB] Warning: Potentially malicious player (" .. name .. ") has connected to the server!")
							end
						end
					else
						local steamID = util.SteamIDFrom64(steamID64)

						game.KickID(steamID, kickReason)
						MsgC(Color(231, 76, 60), "[HGB] " .. name .. " was automatically kicked for being in the HHub Global Ban list.\n")
					end
				end
			else
				MsgC(Color(46, 204, 113), "[HGB] " .. name .. " is not in the Global Ban list.\n")
			end
		end)
	end
end
