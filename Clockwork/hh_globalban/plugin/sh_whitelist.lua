
--[[------------------------------------------------------------------------------------------
    Half-Life 2 Roleplay Hub - Global Ban Plugin

    If you require support, have suggestions, questions, or concerns, please join our discord:
    https://discord.gg/hyPtDAF
--]]------------------------------------------------------------------------------------------

local PLUGIN = PLUGIN;

--[[
	Add people's Steam64IDs to this list to allow them to join your server regardless if they are in the Ban List or not.
	Please use causion when utilizing this feature - people are not added to the list for no reason.
	It is highly ill-advised to use this feature.

	Here is how your list should look:
	PLUGIN.whitelist = {
		["12345678901234567"] = true,
		["12345678901234567"] = true,
		["12345678901234567"] = true,
	};
--]]

PLUGIN.whitelist = {};

-- A function to check if the player is whitelisted from the ban list.
function PLUGIN:IsWhitelisted(playerID)
    return PLUGIN.whitelist[playerID];
end;
