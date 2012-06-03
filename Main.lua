-- Main.lua
DEV_MODE = true

function setup()
    pts = {}
end

function draw()
    background()
    if not currentScreen then
        currentScreen = StartScreen()
        currentScreen:bind()
    end
    currentScreen:draw()
    currentScreen:tick()
    Tweener.run()
    
    ellipseMode(CENTER)
    fill(255, 0, 0, 255)
    strokeWidth(-1)
    for _,p in ipairs(pts) do
        ellipse(p.x,p.y,4,4)
    end
    pts = {}
end

function touched(t)
    if currentScreen and currentScreen.touched then currentScreen:touched(t) end
end

function printout(msg,x,y)
    fill(255,255,255,255)
    fontSize(40)
    textMode(CORNER)
    text(msg,x,y)
end
