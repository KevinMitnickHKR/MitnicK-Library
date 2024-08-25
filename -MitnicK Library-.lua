local function randomName()
    local data = ""
    for i = 0, 20 do
        data = data .. tostring(string.char(math.ceil(math.random() * 254)))
    end
    return data
end

local ui = Instance.new("ScreenGui")
ui.Name = randomName()
ui.Parent = game:GetService("CoreGui")

local library = {}

local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local tabcount = 0
local rainbow = 0
_G.breatherate = 0.005
local color
local rainbows = {}
local buttoncount = {}

local function draggable(obj)
    local globals = {}
    globals.dragging = nil
    globals.uiorigin = nil
    globals.morigin = nil
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            globals.dragging = true
            globals.uiorigin = obj.Position
            globals.morigin = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    globals.dragging = false
                end
            end)
        end
    end)
    uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and globals.dragging then
            local change = input.Position - globals.morigin
            obj.Position = UDim2.new(globals.uiorigin.X.Scale, globals.uiorigin.X.Offset + change.X, globals.uiorigin.Y.Scale, globals.uiorigin.Y.Offset + change.Y)
        end
    end)
end

function library:Create(obj, data)
    obj = Instance.new(obj)
    for i, v in pairs(data) do
        if i ~= "Parent" then
            obj[i] = v
        end
    end
    obj.Parent = data.Parent
    return obj
end

function library:CreateTab(name, rainbow, color)
    tabcount = tabcount + 1
    buttoncount[tabcount] = 0
    if rainbow then
        table.insert(rainbows, #rainbows + 1, tabcount)
        color = Color3.new(1, 0, 0)
    elseif color == nil then
        color = Color3.new(0.1, 0.6, 0.1)
    end
    local tab = self:Create("Frame", {
        Name = tostring(tabcount),
        Parent = ui,
        Active = true,
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, (tabcount - 1) * 220, 0.05, 0),
        Size = UDim2.new(0, 200, 0, 400),
        ClipDescendants = true
    })
    local top = self:Create("Frame", {
        Name = "Top",
        Parent = tab,
        BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
    })
    local title = self:Create("TextLabel", {
        Parent = top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.05, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = name,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local minimize = self:Create("TextButton", {
        Parent = top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.85, 0, 0.1, 0),
        Size = UDim2.new(0, 40, 0, 30),
        Font = Enum.Font.SourceSansBold,
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 24
    })
    local rainbowBar = self:Create("Frame", {
        Parent = top,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0.1, 0)
    })
    local holder = self:Create("Frame", {
        Name = "ButtonHolder",
        Parent = tab,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40)
    })
    local holder2 = self:Create("Frame", {
        Name = "ButtonHolderContent",
        Parent = holder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ClipDescendants = true
    })
    local holder3 = self:Create("Frame", {
        Parent = holder2,
        BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true
    })
    local debounce = false
    minimize.MouseButton1Click:Connect(function()
        if holder3.Visible then
            if not debounce then
                debounce = true
                local tween = TweenService:Create(holder3, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 1, holder3.Size.Y.Offset)})
                tween:Play()
                tween.Completed:Connect(function()
                    holder3.Visible = false
                    debounce = false
                end)
            end
        else
            if not debounce then
                debounce = true
                holder3.Visible = true
                local tween = TweenService:Create(holder3, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)})
                tween:Play()
                tween.Completed:Connect(function()
                    debounce = false
                end)
            end
        end
    end)
    draggable(tab)
    return tab
end

function library:MakeButton(tab, text, callback)
    buttoncount[tonumber(tab.Name)] = buttoncount[tonumber(tab.Name)] + 1
    local button = self:Create("TextButton", {
        Parent = tab.ButtonHolder.ButtonHolderContent,
        BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
        BorderSizePixel = 0,
        Position = UDim2.new(0.05, 0, 0, (buttoncount[tonumber(tab.Name)] - 1) * 36 + 5),
        Size = UDim2.new(0, 190, 0, 30),
        Font = Enum.Font.SourceSansBold,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18
    })
    button.MouseButton1Click:Connect(function()
        callback(button)
    end)
    return button
end

function library:MakeToggle(tab, text, default, callback)
    buttoncount[tonumber(tab.Name)] = buttoncount[tonumber(tab.Name)] + 1
    local toggleState = default and {"ON", Color3.new(0, 1, 0)} or {"OFF", Color3.new(1, 0, 0)}
    local toggle = self:Create("TextButton", {
        Parent = tab.ButtonHolder.ButtonHolderContent,
        BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
        BorderSizePixel = 0,
        Position = UDim2.new(0.05, 0, 0, (buttoncount[tonumber(tab.Name)] - 1) * 36 + 5),
        Size = UDim2.new(0, 100, 0, 30),
        Font = Enum.Font.SourceSansBold,
        Text = toggleState[1],
        TextColor3 = toggleState[2],
        TextSize = 18
    })
    local description = self:Create("TextLabel", {
        Parent = toggle,
        BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
        BorderSizePixel = 0,
        Position = UDim2.new(-0.1, 0, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    toggle.MouseButton1Click:Connect(function()
        if toggle.Text == "ON" then
            toggle.Text = "OFF"
            toggle.TextColor3 = Color3.new(1, 0, 0)
            callback(false)
        else
            toggle.Text = "ON"
            toggle.TextColor3 = Color3.new(0, 1, 0)
            callback(true)
        end
    end)
    return toggle
end

return library 
                    
