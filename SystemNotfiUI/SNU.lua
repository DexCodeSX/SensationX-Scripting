local NotificationUI = {}

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Constants
local TWEEN_TIME = 0.6
local DISPLAY_TIME = 5
local MAX_NOTIFICATIONS = 5

-- Color schemes
local COLORS = {
    success = Color3.fromRGB(46, 204, 113),
    info = Color3.fromRGB(52, 152, 219),
    warning = Color3.fromRGB(241, 196, 15),
    error = Color3.fromRGB(231, 76, 60)
}

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationUI"
ScreenGui.Parent = gethui()

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 340, 1, 0)
NotificationContainer.Position = UDim2.new(1, -340, 0, 0)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = NotificationContainer

local notificationQueue = {}

local function createNotification(title, message, notificationType)
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = UDim2.new(1, -20, 0, 0)
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
    ColorBar.BackgroundColor3 = COLORS[notificationType] or COLORS.info
    ColorBar.BorderSizePixel = 0
    ColorBar.Parent = NotificationFrame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = ColorBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -50, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 5)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = NotificationFrame

    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Size = UDim2.new(1, -50, 0, 0)
    Message.Position = UDim2.new(0, 20, 0, 35)
    Message.Font = Enum.Font.Gotham
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 14
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.BackgroundTransparency = 1
    Message.Parent = NotificationFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -25, 0, 5)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseButton.TextSize = 20
    CloseButton.BackgroundTransparency = 1
    CloseButton.Parent = NotificationFrame

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(1, 0, 0, 4)
    ProgressBar.Position = UDim2.new(0, 0, 1, -4)
    ProgressBar.BackgroundColor3 = COLORS[notificationType] or COLORS.info
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = NotificationFrame

    -- Calculate message height
    local textSize = game:GetService("TextService"):GetTextSize(
        message,
        14,
        Enum.Font.Gotham,
        Vector2.new(NotificationFrame.AbsoluteSize.X - 50, math.huge)
    )
    local messageHeight = textSize.Y
    local totalHeight = math.max(80, messageHeight + 50)

    -- Resize notification
    NotificationFrame.Size = UDim2.new(1, -20, 0, 0)
    Message.Size = UDim2.new(1, -50, 0, messageHeight)

    -- Animations
    local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local growTween = TweenService:Create(NotificationFrame, tweenInfo, {Size = UDim2.new(1, -20, 0, totalHeight)})
    growTween:Play()

    local progressTween = TweenService:Create(ProgressBar, TweenInfo.new(DISPLAY_TIME, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 4)})
    progressTween:Play()

    -- Close button functionality
    local function closeNotification()
        local shrinkTween = TweenService:Create(NotificationFrame, tweenInfo, {Size = UDim2.new(1, -20, 0, 0)})
        shrinkTween:Play()
        shrinkTween.Completed:Connect(function()
            NotificationFrame:Destroy()
        end)
    end

    CloseButton.MouseButton1Click:Connect(closeNotification)

    -- Auto-close after display time
    task.delay(DISPLAY_TIME, closeNotification)

    return NotificationFrame
end

function NotificationUI.notify(title, message, notificationType)
    notificationType = notificationType or "info"
    
    -- Add to queue if max notifications reached
    if #NotificationContainer:GetChildren() - 1 >= MAX_NOTIFICATIONS then
        table.insert(notificationQueue, {title, message, notificationType})
        return
    end

    local notification = createNotification(title, message, notificationType)

    -- Check queue when a notification is removed
    notification.AncestryChanged:Connect(function(_, parent)
        if not parent and #notificationQueue > 0 then
            local nextNotif = table.remove(notificationQueue, 1)
            NotificationUI.notify(unpack(nextNotif))
        end
    end)
end

-- Responsive design for mobile
local function updateLayout()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if viewportSize.X < 600 then
        NotificationContainer.Size = UDim2.new(1, 0, 1, 0)
        NotificationContainer.Position = UDim2.new(0, 0, 0, 0)
    else
        NotificationContainer.Size = UDim2.new(0, 340, 1, 0)
        NotificationContainer.Position = UDim2.new(1, -340, 0, 0)
    end
end

updateLayout()
UserInputService.WindowFocused:Connect(updateLayout)
UserInputService.WindowFocusReleased:Connect(updateLayout)

return NotificationUI
