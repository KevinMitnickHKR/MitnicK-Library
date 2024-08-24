local MitnicK = {}
MitnicK.__index = MitnicK

function MitnicK.new(title, deleteDupes)
    local self = setmetatable({}, MitnicK)

    local playerGui = game.Players.LocalPlayer.PlayerGui

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Parent = playerGui
    self.screenGui.ResetOnSpawn = false

    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 240, 0, 300)
    self.mainFrame.Position = UDim2.new(0.5, -120, 0.5, -150)
    self.mainFrame.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    self.mainFrame.Parent = self.screenGui
    self.mainFrame.ClipsDescendants = true

    self.title = Instance.new("TextLabel")
    self.title.Text = title
    self.title.FontSize = Enum.FontSize.Size24
    self.title.Font = Enum.Font.SourceSans
    self.title.TextColor3 = Color3.new(0, 0, 0)
    self.title.TextStrokeTransparency = 0
    self.title.TextStrokeColor3 = Color3.new(0, 0, 0)
    self.title.Size = UDim2.new(0, 200, 0, 30)
    self.title.Position = UDim2.new(0, 20, 0, 10)
    self.title.Parent = self.mainFrame

    self.buttonList = Instance.new("ScrollingFrame")
    self.buttonList.Size = UDim2.new(0, 200, 0, 230)
    self.buttonList.Position = UDim2.new(0, 20, 0, 40)
    self.buttonList.BackgroundColor3 = Color3.new(1, 1, 1)
    self.buttonList.Parent = self.mainFrame

    self.buttonLayout = Instance.new("UIListLayout")
    self.buttonLayout.SortOrder = Enum.SortOrder.Name
    self.buttonLayout.Padding = UDim.new(0, 5)
    self.buttonLayout.Parent = self.buttonList

    self.tabs = {}
    self.deleteDupes = deleteDupes or false

    self:makeDraggable(self.mainFrame)
    self:setupToggleButton()

    return self
end

function MitnicK:makeDraggable(frame)
    local userInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    userInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                update(input)
            end
        end
    end)
end

function MitnicK:setupToggleButton()
    self.toggleButton = Instance.new("TextButton")
    self.toggleButton.Text = "Hide"
    self.toggleButton.FontSize = Enum.FontSize.Size14
    self.toggleButton.Font = Enum.Font.SourceSans
    self.toggleButton.TextColor3 = Color3.new(0, 0, 0)
    self.toggleButton.TextStrokeTransparency = 0
    self.toggleButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    self.toggleButton.Size = UDim2.new(0, 40, 0, 20)
    self.toggleButton.Position = UDim2.new(0, 10, 0, 50)
    self.toggleButton.Parent = self.screenGui

    local function toggleVisibility()
        if self.mainFrame.Visible then
            self.mainFrame.Visible = false
            self.toggleButton.Text = "Show"
        else
            self.mainFrame.Visible = true
            self.toggleButton.Text = "Hide"
        end
    end

    self.toggleButton.MouseButton1Click:Connect(toggleVisibility)
end

function MitnicK:newTab(tabName)
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    tabFrame.Visible = false
    tabFrame.Parent = self.mainFrame

    local tabTitle = Instance.new("TextLabel")
    tabTitle.Text = tabName
    tabTitle.FontSize = Enum.FontSize.Size18
    tabTitle.Font = Enum.Font.SourceSans
    tabTitle.TextColor3 = Color3.new(0, 0, 0)
    tabTitle.Size = UDim2.new(1, 0, 0, 30)
    tabTitle.BackgroundColor3 = Color3.new(0.7, 0.7, 0.7)
    tabTitle.Parent = tabFrame

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, -30)
    tabContent.Position = UDim2.new(0, 0, 0, 30)
    tabContent.BackgroundColor3 = Color3.new(1, 1, 1)
    tabContent.Parent = tabFrame

    local function showTab()
        for _, tab in pairs(self.tabs) do
            tab.frame.Visible = false
        end
        tabFrame.Visible = true
    end

    tabTitle.MouseButton1Click:Connect(showTab)

    self.tabs[tabName] = { frame = tabFrame, content = tabContent }
end

function MitnicK:addButton(tabName, title, description, callback)
    local tab = self.tabs[tabName]
    if not tab then return end

    local button = Instance.new("TextButton")
    button.Text = title
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, #tab.content:GetChildren() * 35)
    button.Parent = tab.content

    button.MouseButton1Click:Connect(callback)
end

function MitnicK:addInput(tabName, title, defaultValue, callback)
    local tab = self.tabs[tabName]
    if not tab then return end

    local inputBox = Instance.new("TextBox")
    inputBox.PlaceholderText = title
    inputBox.Text = defaultValue
    inputBox.Size = UDim2.new(1, -20, 0, 30)
    inputBox.Position = UDim2.new(0, 10, 0, #tab.content:GetChildren() * 35)
    inputBox.Parent = tab.content

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(inputBox.Text)
        end
    end)
end

function MitnicK:addSlider(tabName, title, description, isMax, minValue, maxValue, defaultValue, callback)
    local tab = self.tabs[tabName]
    if not tab then return end

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 30)
    sliderFrame.Position = UDim2.new(0, 10, 0, #tab.content:GetChildren() * 35)
    sliderFrame.Parent = tab.content

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Text = title .. ": " .. defaultValue
    sliderLabel.Size = UDim2.new(1, 0, 0, 15)
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 5)
    sliderBar.Position = UDim2.new(0, 0, 0, 20)
    sliderBar.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    sliderBar.Parent = sliderFrame

    local sliderHandle = Instance.new("Frame")
    sliderHandle.Size = UDim2.new(0, 10, 1, 0)
    sliderHandle.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 0, 0)
    sliderHandle.BackgroundColor3 = Color3.new(0, 0, 0)
    sliderHandle.Parent = sliderBar

    local function updateSlider(value)
        value = math.clamp(value, minValue, maxValue)
        sliderHandle.Position = UDim2.new((value - minValue) / (maxValue - minValue), 0, 0, 0)
        sliderLabel.Text = title .. ": " .. value
        callback(value)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Mouse
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePosition = input.Position
            local barPosition = sliderBar.AbsolutePosition
            local barSize = sliderBar.AbsoluteSize
            local percentage = math.clamp((mousePosition.X - barPosition.X) / barSize.X, 0, 1)
            updateSlider(minValue + percentage * (maxValue - minValue))
        end
    end)

    sliderBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePosition = input.Position
            local barPosition = sliderBar.AbsolutePosition
            local barSize = sliderBar.AbsoluteSize
            local percentage = math.clamp((mousePosition.X - barPosition.X) / barSize.X, 0, 1)
            updateSlider(minValue + percentage * (maxValue - minValue))
        end
    end)
end

function MitnicK:addDropdown(tabName, title, options, callback)
    local tab = self.tabs[tabName]
    if not tab then return end

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -20, 0, 30)
    dropdownFrame.Position = UDim2.new(0, 10, 0, #tab.content:GetChildren() * 35)
    dropdownFrame.Parent = tab.content

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Text = title
    dropdownLabel.Size = UDim2.new(1, -20, 0, 15)
    dropdownLabel.Parent = dropdownFrame

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Text = "Select an option"
    dropdownButton.Size = UDim2.new(1, 0, 0, 30)
    dropdownButton.Position = UDim2.new(0, 0, 0, 15)
    dropdownButton.Parent = dropdownFrame

    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Size = UDim2.new(1, 0, 0, #options * 30)
    dropdownMenu.Position = UDim2.new(0, 0, 0, 45)
    dropdownMenu.BackgroundColor3 = Color3.new(1, 1, 1)
    dropdownMenu.Visible = false
    dropdownMenu.Parent = dropdownFrame

    local function toggleMenu()
        dropdownMenu.Visible = not dropdownMenu.Visible
    end

    dropdownButton.MouseButton1Click:Connect(toggleMenu)

    for _, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Text = option
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Parent = dropdownMenu

        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            dropdownMenu.Visible = false
            callback(option)
        end)
    end
end

function MitnicK:addToggle(tabName, title, description, defaultValue, callback)
    local tab = self.tabs[tabName]
    if not tab then return end

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, #tab.content:GetChildren() * 35)
    toggleFrame.Parent = tab.content

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Text = title
    toggleLabel.Size = UDim2.new(1, -60, 0, 15)
    toggleLabel.Parent = toggleFrame

    local toggleSwitch = Instance.new("TextButton")
    toggleSwitch.Text = defaultValue and "On" or "Off"
    toggleSwitch.Size = UDim2.new(0, 40, 0, 15)
    toggleSwitch.Position = UDim2.new(1, -50, 0, 0)
    toggleSwitch.Parent = toggleFrame

    local function updateToggle()
        local isOn = toggleSwitch.Text == "On"
        toggleSwitch.Text = isOn and "Off" or "On"
        callback(not isOn)
    end

    toggleSwitch.MouseButton1Click:Connect(updateToggle)
end

return MitnicK
