
local PLUGIN = PLUGIN;
local Clockwork = Clockwork;

Clockwork.kernel:IncludePrefixed("sv_plugin.lua");

PLUGIN:SetGlobalAlias("cwHHubGlobalBan");
PLUGIN.version = "v3"

if (SERVER) then
	function PLUGIN:CheckVersion()
		MsgC(Color(231, 148, 60), "[HGB] The HHub Global Ban plugin has been initialized.\n");
		MsgC(Color(231, 148, 60), "[HGB] Local Version: "..self.version.."\n");
		MsgC(Color(231, 148, 60), "[HGB] Fetching for updates...\n");
		http.Fetch("https://dl.dropboxusercontent.com/s/yp60kr87u1kavny/hgb_version_control.txt", function(body)
			local info = string.Explode("\n", body);
			local versions = {};
			for k,v in pairs(info) do
				local version_info = string.Explode(": ", v);
				versions[version_info[1]] = version_info[2];
			end

			if (versions["cwHHubGlobalBan"]) then
				if (versions["cwHHubGlobalBan"] == self.version) then
					MsgC(Color(46, 204, 113), "[HGB] The HHub Global Ban plugin is up to date!\n");
				else
					MsgC(Color(231, 76, 60), "[HGB] The HHub Global Ban plugin is out of date! Please install the latest version at your earliest convenience.\n");
					MsgC(Color(231, 76, 60), "[HGB] Local version: "..self.version.."\n");
					MsgC(Color(231, 76, 60), "[HGB] Newest version: "..versions["cwHHubGlobalBan"].."\n");
				end;
			else
				MsgC(Color(231, 76, 60), "[HGB] Failed to fetch local version information!\n");
			end;
		end, function()
			MsgC(Color(231, 76, 60), "[HGB] Failed to connect with Version Tracker!\n");
		end);
	end;

	local Initialized = false -- Ensure the plugin is initialized.
	function PLUGIN:Think()
		if (!Initialized) then
			self:CheckVersion()
			Initialized = true;
		end;
	end;
end;