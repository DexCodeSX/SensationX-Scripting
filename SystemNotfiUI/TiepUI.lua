local TiepUI = {}
TiepUI.__index = TiepUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FONT = Enum.Font.GothamBold
local TEXT_SIZE = 14
local TWEEN_TIME = 0.5
local NOTIFICATION_LIFETIME = 5

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
    self:updateLayout()

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

function TiepUI:createNotification(title, message, type)
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 1)
    frame.Position = UDim2.new(0.5, 0, 1, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = self.notificationFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Font = FONT
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
    messageLabel.Font = Enum.Font.Gotham
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

    local notification = {
        Frame = frame,
        CreatedAt = tick()
    }
    table.insert(self.notifications, 1, notification)
    self:updateNotificationPositions()

    spawn(function()
        TweenService:Create(frame, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 1, -frame.AbsoluteSize.Y)}):Play()
        wait(NOTIFICATION_LIFETIME)
        self:removeNotification(notification)
    end)
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

function TiepUI:success(title, message)
    self:createNotification(title, message, "success")
end

function TiepUI:error(title, message)
    self:createNotification(title, message, "error")
end

function TiepUI:warning(title, message)
    self:createNotification(title, message, "warning")
end

function TiepUI:info(title, message)
    self:createNotification(title, message, "info")
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
    self:createNotification("Debug", message, "info")
end

local tiepUI = TiepUI.new()

return tiepUI