GameScreen = class(Screen)

function GameScreen:init(nPlayers)
    self.playerOrder = {"red","blue","yellow","green"}
    Screen.init(self)
    self.nPlayers = nPlayers
    self.player = 1
    self.currentPiece = nil
    self.hasRotated = false
    self.mode = "adding"
    
    -- ok button
    self.okButton = Button(310,25,135,90)
    self:doDraw(self.okButton,"okButton")
    self.okButton.onEnded = function(obj,t)
        if self.mode == "adding" then
            if self.currentPiece then
                self.mode = "rotating"
                self.hasRotated = false
                self.currentPiece = nil
                for i=1,9 do
                    for j=1,9 do
                        self.cells[i][j]:setTint(color(255,255,255,255))
                    end
                end
            end
        elseif self.hasRotated then
            self.mode = "adding"
            self.player = self.player%self.nPlayers+1
            self:updateIndicator()
        end
    end
    
    -- make the cells
    local cellW,cellH = 65,65
    GameScreen.makePieceSprites(cellW,cellH)
    self:updateIndicator()
    
    local cellMaker = function()
        rectMode(CORNER)
        fill(214, 214, 214, 255)
        stroke(255, 255, 255, 255)
        strokeWidth(4)
        rect(0,0,cellW,cellH)
    end
    Screen.makeSprite("cellSprite",cellMaker,cellW,cellH)
    local spacing = 5
    self.cells = {}
    self.pieces = {}
    for i = 1,9 do
        self.cells[i] = {}
        self.pieces[i] = {}
        for j = 1,9 do
            local iSpace = math.floor((i-1)/3) * spacing
            local jSpace = math.floor((j-1)/3) * spacing
            local cell = Button((i-1)*cellW+80+iSpace,(j-1)*cellH+140+jSpace,cellW,cellH)
            self:doDraw(cell,"cellSprite")
            self.cells[i][j] = cell
            
            self.pieces[i][j] = "none"
            cell.onEnded = function(cell,t)
                if self.mode == "adding" then
                    if not self.currentPiece and self.pieces[i][j] == "none" then
                        -- make a new piece
                        local obj = SpriteObj(cell.x+cell.w*.15,cell.y+cell.h*.15,
                            cell.w*.7,cell.h*.7)
                        self:doDraw(obj,self.playerOrder[self.player].."spr",2)
                        self.pieces[i][j] = obj
                        self.currentPiece = obj
                        for i2=1,9 do
                            for j2=1,9 do
                                if i2~=i or j2~=j then
                                    self.cells[i2][j2]:setTint(color(100,100,100,255))
                                else
                                    self.cells[i2][j2]:setTint(color(255,255,255,255))
                                end
                            end
                        end
                    else
                        -- move the current piece
                        if self.pieces[i][j] == "none" then
                            local cell = self.cells[i][j]
                            local x,y = cell:getPos()
                            local w,h = cell:getSize()
                            self.currentPiece:translate(
                                x+w*.15 - self.currentPiece.x,
                                y+h*.15 - self.currentPiece.y)
                            for i2=1,9 do
                                for j2=1,9 do
                                    if self.pieces[i2][j2] == self.currentPiece then
                                        self.pieces[i2][j2] = "none"
                                    end
                                    if i2~=i or j2~=j then
                                        self.cells[i2][j2]:setTint(color(100,100,100,255))
                                    else
                                        self.cells[i2][j2]:setTint(color(255,255,255,255))
                                    end
                                end
                            end
                            self.pieces[i][j] = self.currentPiece
                        end
                    end -- if current piece
                else
                    -- rotate mode
                    
                end -- if adding
            end -- cell.onEnded
        end -- for j
    end -- for i
end -- func

function GameScreen:touched(t)
    if self.mode == "adding" then
        Screen.touched(self,t)
        return nil
    end
    
    self.okButton:touched(t)
    
    if t.state == BEGAN then
        -- find which cell
        for i = 1,9 do for j=1,9 do
            local cell = self.cells[i][j]
            
            if cell:inbounds(t) then
                local bigI = math.floor((i-1)/3)
                local bigJ = math.floor((j-1)/3)
                local centerCell = self.cells[bigI*3+2][bigJ*3+2]
                self.center = vec2(centerCell.x+centerCell.w/2,centerCell.y+centerCell.h/2)
                self.anchor = vec2(t.x,t.y)
                self.angle = (self.anchor - self.center)
                self.angle = -math.deg(self.angle:angleBetween(vec2(1,0)))
                self.bigPos = vec2(bigI,bigJ)
                --print(self.angle)
                
                self.startPos = {}
                for i = 1,3 do
                    self.startPos[i] = {}
                    for j = 1,3 do
                        local cell = self.cells[self.bigPos.x*3+i][self.bigPos.y*3+j]
                        local cellc = vec2(cell.x+cell.w/2,cell.y+cell.h/2)
                        self.startPos[i][j] = cellc
                        self:highlightObj(cell,10)
                        
                        local piece = self.pieces[self.bigPos.x*3+i][self.bigPos.y*3+j]
                        if piece ~= "none" then
                            self:highlightObj(piece,10)
                        end
                    end 
                end
            end
        end end
    elseif t.state == MOVING and self.angle ~= nil then
        local tvec = vec2(t.x,t.y)
        local newAng = (tvec - self.center)
        newAng = -math.deg(newAng:angleBetween(vec2(1,0)))
        local dAng = newAng - self.angle
        if math.abs(dAng) < 100 then
            self:setBlockAngle(dAng)
        end
    elseif t.state == ENDED and self.angle ~= nil then
        local tvec = vec2(t.x,t.y)
        local newAng = (tvec - self.center)
        newAng = -math.deg(newAng:angleBetween(vec2(1,0)))
        local dAng = newAng - self.angle
        if dAng > 45 then self:setBlockAngle(90)
        elseif dAng < -45 then self:setBlockAngle(-90)
        else self:setBlockAngle(0) end
        
        self.hasRotated = true
        self.angle = nil
        self:removeHighlights()
    end
end

function GameScreen:setBlockAngle(dAng)
    for i = 1,3 do for j = 1,3 do
        local newC = self.startPos[i][j] - self.center
        newC = newC:rotate(math.rad(dAng))
        
        local cell = self.cells[self.bigPos.x*3+i][self.bigPos.y*3+j]
        cell:translate(newC.x + self.center.x - (cell.x + cell.w/2),
            newC.y + self.center.y - (cell.y + cell.h/2))
        cell:setAngle(dAng)
        
        local cell = self.pieces[self.bigPos.x*3+i][self.bigPos.y*3+j]
        if cell ~= "none" then
            cell:translate(newC.x + self.center.x - (cell.x + cell.w/2),
                newC.y + self.center.y - (cell.y + cell.h/2))
            cell:setAngle(dAng)
        end
    end end
end

function GameScreen:updateIndicator()
    if self.indicator then
        self:undoDraw(self.indicator)
    end
    self.indicator = SpriteObj(180,18,100,100)
    self:doDraw(self.indicator,self.playerOrder[self.player].."spr")
end

GameScreen.colors = {
    red = color(255, 0, 0, 255),
    blue = color(0, 0, 255, 255),
    yellow = color(255, 255, 0, 255),
    green = color(0,255,0,255)
}

function GameScreen.makePieceSprites(w,h)
    for name,col in pairs(GameScreen.colors) do
        local maker = function()
            ellipseMode(CENTER)
            fill(col)
            strokeWidth(2)
            stroke(0, 0, 0, 255)
            ellipse(w/2,h/2,w,h)
        end
        Screen.makeSprite(name.."spr",maker,w,h)
    end
end
  
