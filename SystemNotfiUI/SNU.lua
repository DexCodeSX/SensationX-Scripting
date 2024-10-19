local NotificationUI = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local TWEEN_TIME = 0.3
local DISPLAY_TIME = 5
local MAX_NOTIFICATIONS = 5
local NOTIFICATION_WIDTH = 320
local NOTIFICATION_PADDING = 16
local NOTIFICATION_SPACING = 8
local MAX_TITLE_LENGTH = 50
local MAX_MESSAGE_LENGTH = 200
local SWIPE_THRESHOLD = 100

local COLORS = {
    background = Color3.fromRGB(18, 18, 18),
    text = Color3.fromRGB(255, 255, 255),
    subtext = Color3.fromRGB(179, 179, 179),
    success = Color3.fromRGB(0, 200, 83),
    info = Color3.fromRGB(33, 150, 243),
    warning = Color3.fromRGB(255, 152, 0),
    error = Color3.fromRGB(244, 67, 54),
    custom = Color3.fromRGB(156, 39, 176)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernNotificationUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = gethui()

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, NOTIFICATION_WIDTH, 1, -20)
NotificationContainer.Position = UDim2.new(1, -NOTIFICATION_WIDTH - 20, 0, 10)
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
    return #str <= maxLength and str or (str:sub(1, maxLength - 3) .. "...")
end

local function createNotification(title, message, options)
    local notificationType = options.type or "info"
    local duration = options.duration or DISPLAY_TIME
    local callback = options.callback
    
    title = truncateString(title, MAX_TITLE_LENGTH)
    message = truncateString(message, MAX_MESSAGE_LENGTH)
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = UDim2.new(1, 0, 0, 0)
    NotificationFrame.BackgroundColor3 = COLORS.background
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.ClipsDescendants = true
    NotificationFrame.Parent = NotificationContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = NotificationFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = COLORS[notificationType]
    Stroke.Thickness = 1
    Stroke.Parent = NotificationFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -NOTIFICATION_PADDING * 2, 1, -NOTIFICATION_PADDING * 2)
    ContentFrame.Position = UDim2.new(0, NOTIFICATION_PADDING, 0, NOTIFICATION_PADDING)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = NotificationFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = COLORS.text
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = ContentFrame

    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Size = UDim2.new(1, 0, 0, 0)
    Message.Position = UDim2.new(0, 0, 0, 28)
    Message.Font = Enum.Font.Gotham
    Message.Text = message
    Message.TextColor3 = COLORS.subtext
    Message.TextSize = 14
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.BackgroundTransparency = 1
    Message.Parent = ContentFrame

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(1, 0, 0, 2)
    ProgressBar.Position = UDim2.new(0, 0, 1, -2)
    ProgressBar.BackgroundColor3 = COLORS[notificationType]
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = NotificationFrame

    local textSize = TextService:GetTextSize(
        message,
        14,
        Enum.Font.Gotham,
        Vector2.new(ContentFrame.AbsoluteSize.X, math.huge)
    )
    local messageHeight = textSize.Y
    local totalHeight = math.max(80, messageHeight + 60)

    NotificationFrame.Size = UDim2.new(1, 0, 0, 0)
    Message.Size = UDim2.new(1, 0, 0, messageHeight)

    local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local growTween = TweenService:Create(NotificationFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, totalHeight)})
    growTween:Play()

    local progressTween = TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})
    progressTween:Play()

    local function closeNotification()
        local shrinkTween = TweenService:Create(NotificationFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)})
        shrinkTween:Play()
        shrinkTween.Completed:Connect(function()
            NotificationFrame:Destroy()
            table.remove(currentNotifications, table.find(currentNotifications, NotificationFrame))
            if callback then
                callback()
            end
        end)
    end

    task.delay(duration, closeNotification)

    -- Swipe to dismiss
    local startX
    local connection
    NotificationFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startX = input.Position.X
            local startPos = NotificationFrame.Position

            connection = RunService.RenderStepped:Connect(function()
                local delta = UserInputService:GetMouseLocation().X - startX
                NotificationFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta, startPos.Y.Scale, startPos.Y.Offset)
            end)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if connection then
                        connection:Disconnect()
                    end

                    local endX = input.Position.X
                    local delta = endX - startX

                    if math.abs(delta) > SWIPE_THRESHOLD then
                        local direction = delta > 0 and 1 or -1
                        local dismissTween = TweenService:Create(NotificationFrame, tweenInfo, {Position = UDim2.new(direction, 0, NotificationFrame.Position.Y.Scale, NotificationFrame.Position.Y.Offset)})
                        dismissTween:Play()
                        dismissTween.Completed:Connect(closeNotification)
                    else
                        local resetTween = TweenService:Create(NotificationFrame, tweenInfo, {Position = startPos})
                        resetTween:Play()
                    end
                end
            end)
        end
    end)

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
        NotificationContainer.Size = UDim2.new(1, -20, 1, -20)
        NotificationContainer.Position = UDim2.new(0, 10, 0, 10)
    else
        NotificationContainer.Size = UDim2.new(0, NOTIFICATION_WIDTH, 1, -20)
        NotificationContainer.Position = UDim2.new(1, -NOTIFICATION_WIDTH - 20, 0, 10)
    end
end

updateLayout()
UserInputService.WindowFocused:Connect(updateLayout)
UserInputService.WindowFocusReleased:Connect(updateLayout)

function NotificationUI.success(title, message, options)
    options = options or {}
    options.type = "success"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.info(title, message, options)
    options = options or {}
    options.type = "info"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.warning(title, message, options)
    options = options or {}
    options.type = "warning"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.error(title, message, options)
    options = options or {}
    options.type = "error"
    NotificationUI.notify(title, message, options)
end

function NotificationUI.custom(title, message, options)
    options = options or {}
    options.type = "custom"
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

local dragStart, startPos

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
