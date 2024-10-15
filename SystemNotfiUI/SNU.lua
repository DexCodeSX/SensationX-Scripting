local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local NotificationSystem = {}

local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotificationUI"
    gui.ResetOnSpawn = false

    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.new(1, -20, 0, 20)
    holder.Size = UDim2.new(0, 300, 1, -40)
    holder.Parent = gui

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = holder

    return gui
end

local function createNotification(options)
    local notification = Instance.new("Frame")
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification

    local title = Instance.new("TextLabel")
    title.Font = Enum.Font.GothamBold
    title.Text = options.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification

    local content = Instance.new("TextLabel")
    content.Font = Enum.Font.Gotham
    content.Text = options.Content
    content.TextColor3 = Color3.fromRGB(200, 200, 200)
    content.TextSize = 14
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -20, 1, -80)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = notification

    local button = Instance.new("TextButton")
    button.Font = Enum.Font.GothamMedium
    button.Text = options.ButtonText or "Dismiss"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 1, -40)
    button.Parent = notification

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button

    return notification
end

function NotificationSystem.notify(options)
    local gui = Players.LocalPlayer:FindFirstChild("NotificationUI") or createGui()
    gui.Parent = Players.LocalPlayer.PlayerGui

    local notification = createNotification(options)
    notification.Parent = gui.Holder

    local targetSize = UDim2.new(1, 0, 0, 120)
    notification.Size = UDim2.new(1, 0, 0, 0)
    
    local appearTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize})
    appearTween:Play()

    notification.TextButton.MouseButton1Click:Connect(function()
        local disappearTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)

    if not options.NeverExpire then
        task.delay(options.Length or 5, function()
            if notification.Parent then
                local disappearTween = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
                disappearTween:Play()
                disappearTween.Completed:Connect(function()
                    notification:Destroy()
                end)
            end
        end)
    end
end

return NotificationSystem
