-- [[ V18 ANTI-UI ERROR & FORCE REJOIN - BY GEMINI ]]
repeat task.wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- 1. HÀM TỰ ĐỘNG XÓA BẢNG LỖI (QUAN TRỌNG)
local function ClearErrorPrompts()
    local coreGui = game:GetService("CoreGui")
    local errorPrompt = coreGui:FindFirstChild("ErrorMessagePrompt", true)
    if errorPrompt then
        print("Phat hien bang loi! Dang tu dong xoa va nhay lai...")
        -- Giam lap bam nut OK de tat bang loi
        pcall(function()
            local okButton = errorPrompt:FindFirstChild("Button", true) or errorPrompt:FindFirstChild("PrimaryButton", true)
            if okButton then
                -- Bam nut ngam
                for _, connection in pairs(getconnections(okButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end
        end)
        task.wait(1)
    end
end

-- 2. HÀM NHẢY SERVER SIÊU SẠCH (CHỈ LẤY ĐÚNG PLACEID HIỆN TẠI)
local function SuperCleanHop()
    ClearErrorPrompts()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success and result then
        local safe = {}
        for _, v in pairs(result) do
            if v.playing < (v.maxPlayers - 10) and v.id ~= game.JobId then
                table.insert(safe, v.id)
            end
        end
        
        if #safe > 0 then
            local target = safe[math.random(1, #safe)]
            print("Dang nhay vao Server moi: " .. target)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target, game.Players.LocalPlayer)
        end
    end
end

-- 3. TỰ ĐỘNG ĐỔI SERVER MỖI 2 PHÚT
task.spawn(function()
    while task.wait(120) do
        SuperCleanHop()
    end
end)

-- 4. VÒNG LẶP KIỂM TRA LỖI (0.5 GIÂY/LẦN) - NẾU THẤY LỖI 773 LÀ DIỆT NGAY
task.spawn(function()
    while task.wait(0.5) do
        if GuiService:GetErrorMessage() ~= "" or game:GetService("CoreGui"):FindFirstChild("ErrorMessagePrompt", true) then
            SuperCleanHop()
        end
    end
end)

print("--- [Gemini] V18 ANTI-UI: DA KICH HOAT ---")
