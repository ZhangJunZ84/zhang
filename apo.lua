-- Carregar a biblioteca Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Criar a janela
local Window = Fluent:CreateWindow({
    Title = "AHD",
    SubTitle = "BacaHub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Criar um tab
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "loader" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game.Workspace
local player = game.Players.LocalPlayer
local playerRootPart = player.Character.HumanoidRootPart

local mobs = {
    ["Zaruka"] = "http://www.roblox.com/asset/?id=5097757152",
}

do
    -- Criar uma tabela com as chaves do dicionário
    local mobNames = {}
    for mobName, _ in pairs(mobs) do
        table.insert(mobNames, mobName)
    end
    
    -- Criar o dropdown usando a tabela de nomes
    local MobDropdown = Tabs.Main:AddDropdown("MobDropdown", {
        Title = "Select Mob",
        Description = "Select a mob to interact with",
        Values = mobNames, -- Usar a tabela preenchida dinamicamente
        Multi = false,
        Default = "Zaruka"
    })
    
    MobDropdown:SetValue("Zaruka")
    
    MobDropdown:OnChanged(function(Value)
        local selectedTemplate = mobs[Value]
        for _, mob in pairs(game.Workspace.temp:GetChildren()) do
            local shirt = mob:FindFirstChild("Shirt")
            if shirt and shirt.ShirtTemplate == selectedTemplate then
                Fluent:Notify({
                    Title = "Mob Found",
                    Content = "Found a " .. Value .. " with UUID: " .. mob.Name,
                    Duration = 3
                })
            end
        end
    end)

    -- Toggle de Auto Farm
    local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm",
        Description = "Will farm selected mob",
        Default = false,
    })
    
    AutoFarmToggle:OnChanged(function()
        if Options.AutoFarm.Value then
            task.spawn(function()
                while Options.AutoFarm.Value do
                    wait() -- Pequeno delay para não sobrecarregar
                    while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
                        wait() -- Aguarda até o personagem estar pronto
                    end
                
                    local selectedMobType = MobDropdown.Value -- Pega o mob selecionado no dropdown
                    local selectedTemplate = mobs[selectedMobType] -- Pega o ShirtTemplate correspondente
                
                    -- Procura um mob com o ShirtTemplate em workspace.temp
                    local targetMob = nil
                    for _, mob in pairs(game.Workspace.temp:GetChildren()) do
                        local shirt = mob:FindFirstChild("Shirt")
                        if shirt and shirt.ShirtTemplate == selectedTemplate then
                            targetMob = mob
                            break -- Pega o primeiro que encontrar
                        end
                    end
                
                    if targetMob then
                        -- Enquanto o mob existir, teleportar o jogador para o CFrame dele
                        while Options.AutoFarm.Value and targetMob.Parent do
                            player.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame -- Teleporta para o mob
                            wait(0.1) -- Delay para verificar a existência e não travar
                        end
                        Fluent:Notify({
                            Title = "Mob Defeated",
                            Content = "Target " .. selectedMobType .. " defeated, finding next...",
                            Duration = 2
                        })
                    else
                        -- Se não encontrar nenhum mob, esperar um pouco antes de tentar novamente
                        Fluent:Notify({
                            Title = "No Mob Found",
                            Content = "No " .. selectedMobType .. " found, searching...",
                            Duration = 2
                        })
                        wait(1)
                    end
                end
            end)
        end
    end)
    
    Options.AutoFarm:SetValue(false) -- Garante que começa desativado

    local AutoClickToggle = Tabs.Main:AddToggle("AutoClick", {
        Title = "Auto Click",
        Description = "Will click for you",
        Default = false,
    })

    AutoClickToggle:OnChanged(function ()
        if Options.AutoClick.Value then
            task.spawn(function()
                while Options.AutoClick.Value do
                    wait(0.1)
                    local args = {
                        [1] = "attack"
                    }
                    
                    ReplicatedStorage:WaitForChild("Shared"):WaitForChild("events"):WaitForChild("RemoteEvent"):FireServer(unpack(args))                
                end
            end)
        end
    end)

    Options.AutoClickToggle:SetValue(false)
end
