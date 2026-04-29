-- UCHIWA Loader | UCHIWA-V4I9NAFS
getgenv().Key = "UCHIWA-V4I9NAFS"
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
loadstring(game:HttpGet("https://python-flask-server--yassin98087.replit.app/aj.lua?key=" .. getgenv().Key .. "&hwid=" .. hwid))()
