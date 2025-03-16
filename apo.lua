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

local mobs = {
    ["Zaruka"] = "http://www.roblox.com/asset/?id=5097757152",
}

do
    -- Criar o dropdown
    local MobDropdown = Tabs.Mobs:AddDropdown("MobDropdown", {
        Title = "Select Mob",
        Description = "Select a mob to interact with",
        Values = {}, -- Será preenchido com as chaves do dicionário
        Multi = false, -- Pode mudar para true se quiser selecionar múltiplos
        Default = "Zaruka"
    })

    -- Preencher o dropdown com as chaves do dicionário
    local dropdownValues = {}
    for mobName, _ in pairs(mobs) do
        table.insert(dropdownValues, mobName)
    end
    MobDropdown:BuildDropdownList(dropdownValues) -- Atualiza a lista do dropdown

    -- Evento quando o valor do dropdown muda
    MobDropdown:OnChanged(function(Value)
        -- Verificar mobs em workspace.temp com o ShirtTemplate correspondente
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
