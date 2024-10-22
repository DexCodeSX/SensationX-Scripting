local TiepUI = {}
TiepUI.__index = TiepUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local FONT = Enum.Font.Gotham
local BOLD_FONT = Enum.Font.GothamBold
local TEXT_SIZE = 14
local TWEEN_TIME = 0.3
local DEFAULT_DURATION = 5
local CORNER_RADIUS = UDim.new(0, 8)

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = parent
    return shadow
end

function TiepUI.new()
    local self = setmetatable({}, TiepUI)
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "TiepUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = gethui()

    self.notificationFrame = Instance.new("Frame")
    self.notificationFrame.Name = "NotificationFrame"
    self.notificationFrame.BackgroundTransparency = 1
    self.notificationFrame.Size = UDim2.new(1, 0, 1, 0)
    self.notificationFrame.Parent = self.screenGui

    self.notifications = {}
    self.debugLogs = {}
    self:updateLayout()

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F3 then
            self:toggleDebugConsole()
        end
    end)

    return self
end

function TiepUI:updateLayout()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local isPortrait = viewportSize.Y > viewportSize.X
    local padding = isPortrait and viewportSize.X * 0.05 or viewportSize.Y * 0.05
    local maxWidth = isPortrait and viewportSize.X * 0.9 or viewportSize.Y * 0.4

    self.notificationFrame.Position = UDim2.new(0.5, 0, 1, -padding)
    self.notificationFrame.AnchorPoint = Vector2.new(0.5, 1)

    for _, notification in ipairs(self.notifications) do
        notification.Frame.Size = UDim2.new(0, maxWidth, 0, 0)
        notification.Frame.AutomaticSize = Enum.AutomaticSize.Y
    end
end

function TiepUI:createNotification(title, message, type, duration)
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 1)
    frame.Position = UDim2.new(0.5, 0, 1, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = self.notificationFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNER_RADIUS
    corner.Parent = frame

    createShadow(frame)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Font = BOLD_FONT
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = TEXT_SIZE
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Top
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, TEXT_SIZE)
    titleLabel.Text = title
    titleLabel.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Font = FONT
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = TEXT_SIZE - 2
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 0, 0, TEXT_SIZE + 4)
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.Text = message
    messageLabel.TextWrapped = true
    messageLabel.Parent = frame

    local typeColor
    if type == "success" then
        typeColor = Color3.fromRGB(0, 255, 0)
    elseif type == "error" then
        typeColor = Color3.fromRGB(255, 0, 0)
    elseif type == "warning" then
        typeColor = Color3.fromRGB(255, 255, 0)
    else
        typeColor = Color3.fromRGB(0, 170, 255)
    end

    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.BackgroundColor3 = typeColor
    colorBar.BorderSizePixel = 0
    colorBar.Size = UDim2.new(0, 4, 1, 0)
    colorBar.Position = UDim2.new(0, -8, 0, 0)
    colorBar.Parent = frame

    local durationBar = Instance.new("Frame")
    durationBar.Name = "DurationBar"
    durationBar.BackgroundColor3 = typeColor
    durationBar.BorderSizePixel = 0
    durationBar.Size = UDim2.new(1, 0, 0, 2)
    durationBar.Position = UDim2.new(0, 0, 1, 2)
    durationBar.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Font = BOLD_FONT
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.TextSize = TEXT_SIZE
    closeButton.Text = "×"
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -10, 0, 0)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Parent = frame

    local notification = {
        Frame = frame,
        DurationBar = durationBar,
        CreatedAt = tick(),
        Duration = duration or DEFAULT_DURATION
    }
    table.insert(self.notifications, 1, notification)
    self:updateNotificationPositions()

    closeButton.MouseButton1Click:Connect(function()
        self:removeNotification(notification)
    end)

    spawn(function()
        TweenService:Create(frame, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 1, -frame.AbsoluteSize.Y)}):Play()
        TweenService:Create(durationBar, TweenInfo.new(notification.Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()
        wait(notification.Duration)
        self:removeNotification(notification)
    end)

    self:debug("Notification created", {
        title = title,
        message = message,
        type = type,
        duration = duration
    })
end

function TiepUI:removeNotification(notification)
    local index = table.find(self.notifications, notification)
    if index then
        table.remove(self.notifications, index)
        local frame = notification.Frame
        TweenService:Create(frame, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
        wait(TWEEN_TIME)
        frame:Destroy()
        self:updateNotificationPositions()
    end
end

function TiepUI:updateNotificationPositions()
    local offset = 0
    for i, notification in ipairs(self.notifications) do
        local frame = notification.Frame
        local targetPosition = UDim2.new(0.5, 0, 1, -offset - frame.AbsoluteSize.Y)
        TweenService:Create(frame, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPosition}):Play()
        offset = offset + frame.AbsoluteSize.Y + 8
    end
end

function TiepUI:success(title, message, duration)
    self:createNotification(title, message, "success", duration)
end

function TiepUI:error(title, message, duration)
    self:createNotification(title, message, "error", duration)
end

function TiepUI:warning(title, message, duration)
    self:createNotification(title, message, "warning", duration)
end

function TiepUI:info(title, message, duration)
    self:createNotification(title, message, "info", duration)
end

function TiepUI:debug(...)
    local args = {...}
    local message = ""
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            message = message .. HttpService:JSONEncode(arg)
        else
            message = message .. tostring(arg)
        end
        if i < #args then
            message = message .. " "
        end
    end
    
    table.insert(self.debugLogs, {
        timestamp = os.date("%H:%M:%S"),
        message = message
    })
    
    if #self.debugLogs > 100 then
        table.remove(self.debugLogs, 1)
    end
    
    if self.debugConsole then
        self:updateDebugConsole()
    end
end

function TiepUI:createDebugConsole()
    local frame = Instance.new("Frame")
    frame.Name = "DebugConsole"
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Parent = self.screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CORNER_RADIUS
    corner.Parent = frame

    createShadow(frame)

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Font = BOLD_FONT
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = TEXT_SIZE
    titleLabel.Text = "Debug Console"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Parent = titleBar

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Font = BOLD_FONT
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.TextSize = TEXT_SIZE
    closeButton.Text = "×"
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Parent = titleBar

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "LogFrame"
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Position = UDim2.new(0, 10, 0, 40)
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.Parent = frame

    local logLayout = Instance.new("UIListLayout")
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.Padding = UDim.new(0, 5)
    logLayout.Parent = scrollFrame

    closeButton.MouseButton1Click:Connect(function()
        self:toggleDebugConsole()
    end)

    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragInput.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    return frame, scrollFrame
end

function TiepUI:toggleDebugConsole()
    if not self.debugConsole then
        self.debugConsole, self.debugScrollFrame = self:createDebugConsole()
        self:updateDebugConsole()
    else
        self.debugConsole:Destroy()
        self.debugConsole = nil
        self.debugScrollFrame = nil
    end
end

function TiepUI:updateDebugConsole()
    if not self.debugConsole then return end

    for i, log in ipairs(self.debugLogs) do
        local existingLog = self.debugScrollFrame:FindFirstChild("Log" .. i)
        if not existingLog then
            local logLabel = Instance.new("TextLabel")
            logLabel.Name = "Log" .. i
            logLabel.Font = FONT
            logLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            logLabel.TextSize = TEXT_SIZE - 2
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            logLabel.TextYAlignment = Enum.TextYAlignment.Top
            logLabel.BackgroundTransparency = 1
            logLabel.Size = UDim2.new(1, -10, 0, 0)
            logLabel.AutomaticSize = Enum.AutomaticSize.Y
            logLabel.TextWrapped = true
            logLabel.Parent = self.debugScrollFrame
            
            existingLog = logLabel
        end
        
        existingLog.Text = string.format("[%s] %s", log.timestamp, log.message)
    end

    self.debugScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.debugScrollFrame.UIListLayout.AbsoluteContentSize.Y)
    self.debugScrollFrame.CanvasPosition = Vector2.new(0, self.debugScrollFrame.CanvasSize.Y.Offset - self.debugScrollFrame.AbsoluteSize.Y)
end

local tiepUI = TiepUI.new()

return tiepUI
