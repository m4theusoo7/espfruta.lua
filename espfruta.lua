-- Serviços necessários
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações da ESP
local SETTINGS = {
    TextSize = 14,
    TextColor = Color3.fromRGB(255, 255, 0), -- Amarelo para destacar
    OutlineColor = Color3.fromRGB(0, 0, 0),
    MaxDistance = 5000 -- Distância máxima para exibir (em studs)
}

-- Tabela para armazenar as instâncias visuais
local espCache = {}

local function createESP(fruit)
    local textDrawing = Drawing.new("Text")
    textDrawing.Visible = false
    textDrawing.Center = true
    textDrawing.Outline = true
    textDrawing.OutlineColor = SETTINGS.OutlineColor
    textDrawing.Color = SETTINGS.TextColor
    textDrawing.Size = SETTINGS.TextSize
    
    espCache[fruit] = textDrawing
    
    -- Remove a ESP quando a fruta for coletada ou destruída
    fruit.AncestryChanged:Connect(function()
        if not fruit:IsDescendantOf(Workspace) then
            textDrawing:Remove()
            espCache[fruit] = nil
        end
    end)
end

-- Função para atualizar a posição e a distância na tela
local function updateESP()
    for fruit, textDrawing in pairs(espCache) do
        if fruit and fruit.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            local fruitPart = fruit:FindFirstChild("Handle") or fruit.PrimaryPart or fruit:FindFirstChildWhichIsA("BasePart")
            
            if fruitPart then
                local distance = (rootPart.Position - fruitPart.Position).Magnitude
                
                if distance <= SETTINGS.MaxDistance then
                    -- Converte a posição 3D do mundo para 2D na tela
                    local vector, onScreen = Camera:WorldToViewportPoint(fruitPart.Position)
                    
                    if onScreen then
                        -- Pega o nome limpo da fruta (removendo sufixos se houver)
                        local fruitName = fruit.Name:gsub("Fruit", ""):gsub(":", "")
                        
                        textDrawing.Text = string.format("[%s] (%dm)", fruitName, math.floor(distance))
                        textDrawing.Position = Vector2.new(vector.X, vector.Y)
                        textDrawing.Visible = true
                    else
                        textDrawing.Visible = false
                    end
                else
                    textDrawing.Visible = false
                end
            else
                textDrawing.Visible = false
            end
        else
            textDrawing.Visible = false
        end
    end
end

-- Varre o Workspace em busca de frutas (no Blox Fruits, elas costumam vir com nomes específicos ou clonadas)
Workspace.ChildAdded:Connect(function(child)
    -- Verificação básica se o objeto se parece com uma fruta dropada
    if child:IsA("Tool") or child.Name:find("Fruit") then
        createESP(child)
    end
end)

-- Carrega as frutas que já estão no mapa
for _, child in ipairs(Workspace:GetChildren()) do
    if child:IsA("Tool") or child.Name:find("Fruit") then
        createESP(child)
    end
end

-- Loop de atualização contínua
RunService.RenderStepped:Connect(updateESP)
