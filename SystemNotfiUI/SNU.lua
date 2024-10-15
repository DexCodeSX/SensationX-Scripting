local NotificationUI = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local TWEEN_TIME = 0.6
local DISPLAY_TIME = 5
local MAX_NOTIFICATIONS = 5
local NOTIFICATION_WIDTH = 340
local NOTIFICATION_PADDING = 10
local NOTIFICATION_SPACING = 10
local MAX_TITLE_LENGTH = 50
local MAX_MESSAGE_LENGTH = 200

local COLORS = {
    success = Color3.fromRGB(46, 204, 113),
    info = Color3.fromRGB(52, 152, 219),
    warning = Color3.fromRGB(241, 196, 15),
    error = Color3.fromRGB(231, 76, 60),
    custom = Color3.fromRGB(155, 89, 182)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = gethui()

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, NOTIFICATION_WIDTH, 1, 0)
NotificationContainer.Position = UDim2.new(1, -NOTIFICATION_WIDTH, 0, 0)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, NOTIFICATION_SPACING)
UIListLayout.Parent = NotificationContainer

local notificationQueue = {}
local currentNotifications = {}

local function truncateString(str, maxLength)
    if #str <= maxLength then
        return str
    end
    return str:sub(1, maxLength - 3) .. "..."
end

local function createNotification(title, message, options)
    local notificationType = options.type or "info"
    local duration = options.duration or DISPLAY_TIME
    local callback = options.callback
    local actions = options.actions or {}
    local icon = options.icon
    
    title = truncateString(title, MAX_TITLE_LENGTH)
    message = truncateString(message, MAX_MESSAGE_LENGTH)
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = UDim2.new(1, -NOTIFICATION_PADDING * 2, 0, 0)
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.ClipsDescendants = true
    NotificationFrame.Parent = NotificationContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = NotificationFrame

    local ColorBar = Instance.new("Frame")
    ColorBar.Name = "ColorBar"
    ColorBar.Size = UDim2.new(0, 8, 1, 0)
    ColorBar.BackgroundColor3 = COLORS[notificationType] or COLORS.custom
    ColorBar.BorderSizePixel = 0
    ColorBar.Parent = NotificationFrame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = ColorBar

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -8, 1, 0)
    ContentFrame.Position = UDim2.new(0, 8, 0, 0)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = NotificationFrame

    local IconImage
    if icon then
        IconImage = Instance.new("ImageLabel")
        IconImage.Name = "IconImage"
        IconImage.Size = UDim2.new(0, 24, 0, 24)
        IconImage.Position = UDim2.new(0, 10, 0, 10)
        IconImage.BackgroundTransparency = 1
        IconImage.Image = icon
        IconImage.Parent = ContentFrame
    end

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, icon and -74 or -50, 0, 30)
    Title.Position = UDim2.new(0, icon and 44 or 20, 0, 5)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = ContentFrame

    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Size = UDim2.new(1, -40, 0, 0)
    Message.Position = UDim2.new(0, 20, 0, 35)
    Message.Font = Enum.Font.Gotham
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 14
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.BackgroundTransparency = 1
    Message.Parent = ContentFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -25, 0, 5)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseButton.TextSize = 20
    CloseButton.BackgroundTransparency = 1
    CloseButton.Parent = ContentFrame

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(1, 0, 0, 4)
    ProgressBar.Position = UDim2.new(0, 0, 1, -4)
    ProgressBar.BackgroundColor3 = COLORS[notificationType] or COLORS.custom
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = NotificationFrame

    local textSize = TextService:GetTextSize(
        message,
        14,
        Enum.Font.Gotham,
        Vector2.new(ContentFrame.AbsoluteSize.X - 40, math.huge)
    )
    local messageHeight = textSize.Y
    local totalHeight = math.max(80, messageHeight + 50)

    if #actions > 0 then
        local buttonHeight = 30
        local buttonSpacing = 5
        local buttonsContainer = Instance.new("Frame")
        buttonsContainer.Name = "ButtonsContainer"
        buttonsContainer.Size = UDim2.new(1, -40, 0, buttonHeight)
        buttonsContainer.Position = UDim2.new(0, 20, 0, totalHeight)
        buttonsContainer.BackgroundTransparency = 1
        buttonsContainer.Parent = ContentFrame

        local buttonWidth = (buttonsContainer.AbsoluteSize.X - (buttonSpacing * (#actions - 1))) / #actions

        for i, action in ipairs(actions) do
            local button = Instance.new("TextButton")
            button.Name = "ActionButton" .. i
            button.Size = UDim2.new(0, buttonWidth, 1, 0)
            button.Position = UDim2.new(0, (i - 1) * (buttonWidth + buttonSpacing), 0, 0)
            button.Font = Enum.Font.Gotham
            button.Text = action.text
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 14
            button.BackgroundColor3 = COLORS[notificationType] or COLORS.custom
            button.Parent = buttonsContainer

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 5)
            buttonCorner.Parent = button

            button.MouseButton1Click:Connect(function()
                if action.callback then
                    action.callback()
                end
            end)
        end

        totalHeight = totalHeight + buttonHeight + buttonSpacing
    end

    NotificationFrame.Size = UDim2.new(1, -NOTIFICATION_PADDING * 2, 0, 0)
    Message.Size = UDim2.new(1, -40, 0, messageHeight)

    local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local growTween = TweenService:Create(NotificationFrame, tweenInfo, {Size = UDim2.new(1, -NOTIFICATION_PADDING * 2, 0, totalHeight)})
    growTween:Play()

    local progressTween = TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 4)})
    progressTween:Play()

    local function closeNotification()
        local shrinkTween = TweenService:Create(NotificationFrame, tweenInfo, {Size = UDim2.new(1, -NOTIFICATION_PADDING * 2, 0, 0)})
        shrinkTween:Play()
        shrinkTween.Completed:Connect(function()
            NotificationFrame:Destroy()
            table.remove(currentNotifications, table.find(currentNotifications, NotificationFrame))
            if callback then
                callback()
            end
        end)
    end

    CloseButton.MouseButton1Click:Connect(closeNotification)

    task.delay(duration, closeNotification)

    return NotificationFrame
end

function NotificationUI.notify(title, message, options)
    options = options or {}
    
    if #currentNotifications >= MAX_NOTIFICATIONS then
        table.insert(notificationQueue, {title, message, options})
        return
    end

    local notification = createNotification(title, message, options)
    table.insert(currentNotifications, notification)

    notification.AncestryChanged:Connect(function(_, parent)
        if not parent and #notificationQueue > 0 then
            local nextNotif = table.remove(notificationQueue, 1)
            NotificationUI.notify(unpack(nextNotif))
        end
    end)
end

local function updateLayout()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if viewportSize.X < 600 then
        NotificationContainer.Size = UDim2.new(1, 0, 1, 0)
        NotificationContainer.Position = UDim2.new(0, 0, 0, 0)
    else
        NotificationContainer.Size = UDim2.new(0, NOTIFICATION_WIDTH, 1, 0)
        NotificationContainer.Position = UDim2.new(1, -NOTIFICATION_WIDTH, 0, 0)
    end
end

updateLayout()
UserInputService.WindowFocused:Connect(updateLayout)
UserInputService.WindowFocusReleased:Connect(updateLayout)

function NotificationUI.success(title, message, options)
    options = options or {}
    options.type = "success"
    options.icon = "rbxassetid://105579861960290"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.info(title, message, options)
    options = options or {}
    options.type = "info"
    options.icon = "rbxassetid://99644130295609"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.warning(title, message, options)
    options = options or {}
    options.type = "warning"
    options.icon = "rbxassetid://122878607482605"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.error(title, message, options)
    options = options or {}
    options.type = "error"
    options.icon = "rbxassetid://111618354985317"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.toast(message, duration)
    duration = duration or 3
    local options = {
        type = "custom",
        duration = duration
    }
    NotificationUI.notify("", message, options)
end

function NotificationUI.clearAll()
    for _, notification in ipairs(currentNotifications) do
        notification:Destroy()
    end
    currentNotifications = {}
    notificationQueue = {}
end

local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    NotificationContainer.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

NotificationContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos = NotificationContainer.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragStart = nil
            end
        end)
    end
end)

NotificationContainer.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragStart then
            updateDrag(input)
        end
    end
end)

return NotificationUI
