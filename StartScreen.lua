StartScreen = class(Screen)

function StartScreen:init()
    Screen.init(self)
    self.selected = 4
    
    local w,h = Screen.makeTextSprite("numPlayers","Number of Players",{fontSize=75})
    local obj = SpriteObj((WIDTH-w)/2,500,w,h)
    self:doDraw(obj,"numPlayers") 

    local w,h = Screen.makeTextSprite("twoSprite","2",{fontSize=100})
    local obj = Button(200,320,w,h)
    self:doDraw(obj,"twoSprite")
    obj.onBegan = function(obj,t) self:moveSelector(2) end
    
    local w,h = Screen.makeTextSprite("threeSprite","3",{fontSize=100})
    local obj = Button(350,320,w,h)
    self:doDraw(obj,"threeSprite")
    obj.onBegan = function(obj,t) self:moveSelector(3) end
    
    local w,h = Screen.makeTextSprite("fourSprite","4",{fontSize=100})
    local obj = Button(500,320,w,h)
    self:doDraw(obj,"fourSprite")
    obj.onBegan = function(obj,t) self:moveSelector(4) end
    
    local selMaker = function()
        ellipseMode(CORNER)
        strokeWidth(6)
        noFill()
        stroke(255, 0, 0, 255)
        ellipse(0,0,120,120)
    end
    Screen.makeSprite("playerSelector",selMaker,120,120)
    self.selector = SpriteObj(475,330,120,120)
    self:doDraw(self.selector,"playerSelector")
    
    local okMaker = function()
        rectMode(CORNER)
        strokeWidth(1)
        fill(0, 172, 255, 255)
        stroke(255, 255, 255, 255)
        rect(0,0,150,100)
        
        textMode(CORNER)
        fill(255, 255, 255, 255)
        font("Futura-CondensedExtraBold")
        fontSize(80)
        text("OK",20,-5)
    end
    
    Screen.makeSprite("okButton",okMaker,150,100)
    local obj = Button(300,150,150,100)
    self:doDraw(obj,"okButton")
    obj.onEnded = function(obj,t)
        currentScreen = GameScreen(self.selected)
    end
end

function StartScreen:moveSelector(n)
    self.selected = n
    local x,y = self.selector:getPos()
    if n == 4 then
        self.selector:translate(475-x,330-y)
    elseif n == 3 then
        self.selector:translate(320-x,330-y)
    else
        self.selector:translate(170-x,330-y)
    end
end
