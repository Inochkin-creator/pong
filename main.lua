--[[
  VARIABLES
]]
  src = love.audio.newSource("victory.mp3", "static")
  src:setVolume(0.4)
  select = love.audio.newSource("select.mp3", "static")
  select:setVolume(0.2)

  Wwidth = 1200
  Wheight = 660

  p1 = 0  
  p2 = 0  

  speed = 500
  Bspeed = 0

  bgx = Wwidth / 2 - 157.5
  bgy = Wheight / 2 - 160
  bg = 1

  x = Wwidth / 2 - 7.5
  y = Wheight / 2 + 7.5

  y1 = Wheight / 2 + 25
  y2 = Wheight / 2 + 25

  Yspeed = 0
  Xspeed = 0

  c = 0

  T = os.time()
  S1time = 0
  S2time = 0
  Stime = 0

  gameType = "easy_bot"
  gameSpeed = "standart"
  Sup = 1

  font_1 = love.graphics.newFont("font.ttf", 64)
  font_2 = love.graphics.newFont("font.ttf", 96)
  font_3 = love.graphics.newFont("font.ttf", 32)
--
push = require "push"
--
function love.load()
  love.graphics.setFont(font_1)
  --love.window.setMode(Wwidth, Wheight, {resizable = true, vsync = true})
  push:setupScreen(Wwidth, Wheight, love.graphics.getWidth(), love.graphics.getHeight(), {
    fullscreen = false,
    resizable = true})
    
  love.window.setTitle("pong v1.0")
  love.window.maximize()
  gameState = "load"
  Otime = os.time()
end
--
function love.resize(w, h)
  push:resize(w, h)
end
--
function love.update(time)
  --
  collectgarbage()
  if gameState == "load" and os.time() - Otime == 3 then
    gameState = "choose"
  end
  --
  if gameState == "easter" then
    bgx = math.max(-8, math.min (Wwidth - 306, bgx + Xspeed * time) )
    bgy = math.max(-7, math.min (Wheight - 303, bgy + Yspeed * time) )
    --
    if bgy == -7 or bgy == Wheight - 303 then
      love.audio.newSource("hit.wav", "static"):play()
      Yspeed = -Yspeed * 1.01
    end
    --
    if bgx == -8 or bgx == Wwidth - 306 then
      love.audio.newSource("hit.wav", "static"):play()
      Xspeed = -Xspeed * 1.01
    end
    --
    -- Picture moves OAOAOAOOAOAOAOOA
      if love.keyboard.isDown("up") then Yspeed = Yspeed - 7.5 end
      if love.keyboard.isDown("down") then Yspeed = Yspeed + 7.5 end
      if love.keyboard.isDown("left") then Xspeed = Xspeed - 7.5 end
      if love.keyboard.isDown("right") then Xspeed = Xspeed + 7.5 end
  end
  --[[
    PADDLE UP / DOWN by PLAYER(s)
  ]]
    if love.keyboard.isDown("w") and gameType == "PvP" then
      if y1 - speed * time * Sup >= 85 then
        y1 = y1 - speed * time * Sup
      else
        y1 = 85
      end
    end

    if love.keyboard.isDown("s") and gameType == "PvP" then
      if y1 + speed * time * Sup <= Wheight - 135 then 
        y1 = y1 + speed * time * Sup
      else
        y1 = Wheight - 135
      end
    end

    if love.keyboard.isDown("up") then
      if y2 - speed * time * Sup >= 85 then
        y2 = y2 - speed * time * Sup
      else 
        y2 = 85
      end
    end

    if love.keyboard.isDown("down") then
      if y2 + speed * time * Sup <= Wheight - 135 then 
      y2 = y2 + speed * time * Sup
      else
      y2 = Wheight - 135
      end
    end
  --
  -- PADDLE UP / DOWN by BOT
    if (gameType == "easy_bot" or gameType == "medium_bot" or gameType == "hard_bot") and 
      x <= Wwidth / 2 - 10 and Xspeed < 0 then
      if y1 - 5 > y then
        y1 = math.max(85, y1 - Bspeed * time, y + 10)
      elseif y1 + 30 < y then
        y1 = math.min(Wheight - 135, y1 + Bspeed * time, y + 60)
      end
    end
  --
  if gameState == "play" then
    if y == 77.5 or y == Wheight - 95 then
      love.audio.newSource("hit.wav", "static"):play()
      Yspeed = - Yspeed * 1.05
    end
    --
    if (x <= 40 and y + 14 >= y1 and y - 14 <= y1 + 50) or 
    (x >= Wwidth - 55 and y + 14 >= y2 and y - 14 <= y2 + 50) then
      if (x <= 47.5) then x = 41
      else x = Wwidth - 56 end
      Xspeed = - Xspeed * 1.1
      Yspeed = - Yspeed * 1.07
      x = x + Xspeed * time
      love.audio.newSource("hitp.wav", "static"):play()
    end
    x = x + Xspeed * time
    y = math.max(77.5, math.min (Wheight - 95, y + Yspeed * time) )
  end
  --
  if gameState == "start" or gameState == "stop" then 
    x = Wwidth / 2 - 7.5
    y = Wheight / 2 + 7.5
  end
  --
  --[[
    BALL SCORED
  ]]
    if x <= 25 then
      gameState = "stop"
      p2 = p2 + 1
      S1time = os.time()
      if p2 ~= 5 then
        love.audio.newSource("point.wav", "static"):play()
      end
    end

    if x >= Wwidth - 40 then
      gameState = "stop"
      p1 = p1 + 1
      S1time = os.time()
      if p1 ~= 5 then
        love.audio.newSource("point.wav", "static"):play()
      end
    end
  --
  --[[
    THE END OF THE GAME
  ]]
    if p1 == 5 or p2 == 5 or os.time() - T - Stime >= 300 / Sup and gameState == "play" then
      x = Wwidth / 2
      if p1 == p2 then
        gameState = "draw"
      elseif p1 > p2 then
        if gameType == "PvP" then
          gameState = "1won"
        else
          gameState = "lose"
        end
      else
        if gameType == "PvP" then
          gameState = "2won"
        else
          gameState = "win"
        end
      end
    end

    if (gameState == "win" or gameState == "1won" or gameState == "2won" or gameState == "draw") 
    and c == 0 then
      src:play() c = 1
    elseif c == 0 and gameState == "lose" then
      love.audio.newSource("lose.wav", "static"):play() c = 1
    end
end
--
function love.keypressed(key)
  --
  collectgarbage()
  --
  if key == "g" then
    p1 = 0
    p2 = 0
    Otime = os.time()
    bgx = Wwidth / 2 - 157.5
    bgy = Wheight / 2 - 160
    Xspeed = math.random(66, 99)
    Yspeed = math.random(44, 66)
    z = math.random(0, 1)
    if z == 1 then
      Xspeed = -Xspeed
    end
    z = math.random(0, 1)
    if z == 1 then
      Yspeed = -Yspeed
    end
    gameState = "easter"
  --
  elseif gameState ~= "load" then
    if key == "escape" or ((key == "enter" or key == "return") and (gameState == "easter" or 
    gameState == "load" or gameState == "1won" or gameState == "2won" or gameState == "draw" or 
    gameState == "win" or gameState == "lose") )  then 
      gameState = "choose"
      p1 = 0  
      p2 = 0 
      y1 = Wheight / 2 + 25
      y2 = Wheight / 2 + 25
      c = 0
    --
    -- START OR PLAY (ENTER_BEGINNING) --  
      elseif (key == "enter" or key == "return") and gameState ~= "play" and gameState ~= "load" then
        
        if gameState == "choose" then
            gameState = "start"
            speed = 500 * Sup
          else
            if gameState == "start" then
              S1time = os.time()
              S2time = os.time()
              T = os.time() 
              Stime = 0
              p1 = 0  
              p2 = 0 

              -- BOT SPEED --
                if gameType == "easy_bot" then
                  Bspeed = 222 * Sup
                end

                if gameType == "medium_bot" then
                  Bspeed = 444 * Sup
                end

                if gameType == "hard_bot" then
                  Bspeed = 666 * Sup
                end
            
            else
              Stime = Stime + (os.time() - S1time)
            end
            gameState = "play"
            y1 = Wheight / 2 + 25
            y2 = Wheight / 2 + 25
            
            -- BALL SPEED --
              Xspeed = math.random(100, 200) * Sup
              Yspeed = math.random(75, 150) * Sup
              z = math.random(0, 1)
              if z == 1 then
                Xspeed = -Xspeed
              end
              z = math.random(0, 1)
              if z == 1 then
                Yspeed = -Yspeed
              end
          end
    end 
    --
    --[[ 
      CHOOSE GAMEMODE 
    ]]
      if key == "right" and gameType == "easy_bot" and gameState == "choose" then
        select:play()
        gameType = "medium_bot"
      end

      if key == "right" and gameType == "hard_bot" and gameState == "choose" then
        select:play()
        gameType = "PvP"
      end

      if key == "down" and gameType == "easy_bot" and gameState == "choose" then
        select:play()
        gameType = "hard_bot"
      end

      if key == "down" and gameType == "medium_bot" and gameState == "choose" then
        select:play()
        gameType = "PvP"
      end

      if key == "left" and gameType == "medium_bot" and gameState == "choose" then
        select:play()
        gameType = "easy_bot"
      end

      if key == "left" and gameType == "PvP" and gameState == "choose" then
        select:play()
        gameType = "hard_bot"
      end

      if key == "up" and gameType == "hard_bot" and gameState == "choose" then
        select:play()
        gameType = "easy_bot"
      end

      if key == "up" and gameType == "PvP" and gameState == "choose" then
        select:play()
        gameType = "medium_bot"
      end

      if key == "space" and gameSpeed == "standart" and gameState == "choose" then
        select:play()
        gameSpeed = "fast"
        Sup = 1.25
      --
      elseif key == "space" and gameSpeed == "fast" and gameState == "choose" then
        select:play()
        gameSpeed = "slow"
        Sup = 0.8333333333
      --
      elseif key == "space" and gameSpeed == "slow" and gameState == "choose" then
        select:play()
        gameSpeed = "standart"
        Sup = 1
      end
      --
  end
  --
  if gameState == "load" and (key == "enter" or key == "return")  then
    gameState = "choose"
    Xspeed = 0
    Yspeed = 0
  end
end
--
function love.draw()
  push:apply("start")
  collectgarbage()
  if gameState == "easter" or gameState == "load" then
    love.graphics.clear(255, 255, 255, 255)
    love.graphics.draw(love.graphics.newImage("logo.png"), bgx, bgy)
    love.graphics.setColor(0, 0, 0, 255)

    love.graphics.setFont(font_3)
    love.graphics.printf("(C) Games++ 07.2020", 0, Wheight - 48, Wwidth - 16, "right")

    love.graphics.setFont(font_2)
    love.graphics.printf("PONG", 0, 75, Wwidth, "center")

    love.graphics.setFont(font_1)
    love.graphics.setColor(255, 255, 255, 255)
  else
    love.graphics.setBackgroundColor(0, 0, 0)
  end
  --
  if gameState == "choose" then
    love.graphics.printf(gameSpeed, 0, 10, Wwidth, "center")
    
    love.graphics.rectangle("fill", 25, 75, Wwidth - 50, 2.5)
    love.graphics.rectangle("fill", 25, Wheight - 80, Wwidth - 50, 2.5)

    love.graphics.printf("Game with an easy bot", 0, Wheight / 4 - 25, Wwidth / 2, "center")
    love.graphics.printf("Game with a medium bot", Wwidth / 2, Wheight / 4 - 25, Wwidth / 2, "center")
    love.graphics.printf("Game with \n a hard bot", 0, Wheight - Wheight / 4 - 100, Wwidth / 2, "center")
    love.graphics.setFont(font_2)
    love.graphics.printf("PvP", Wwidth / 2, Wheight -  Wheight / 4 - 75, Wwidth / 2, "center")
    love.graphics.setFont(font_1)
    love.graphics.printf("Choose gamemode", 0, Wheight - 70, Wwidth, "center")
    
    --[[
      Rectangle around choosed gamemode
    ]]
      if gameType == "easy_bot" then
        love.graphics.rectangle("line", 25, 78, Wwidth / 2 - 25, 250)
      end

      if gameType == "medium_bot" then
        love.graphics.rectangle("line", Wwidth - Wwidth / 2, 78, Wwidth / 2 - 25, 250)
      end

      if gameType == "hard_bot" then
        love.graphics.rectangle("line", 25, Wheight - 330, Wwidth / 2 - 25, 250)
      end

      if gameType == "PvP" then
        love.graphics.rectangle("line", Wwidth - Wwidth / 2, Wheight - 330, Wwidth / 2 - 25, 250)
      end
  end
  --
  if gameState == "start" or gameState == "play" or gameState == "stop" then
    love.graphics.printf("PONG", 0, 10, Wwidth, "center")
    love.graphics.printf(p1, 25, 10, Wwidth, "left")
    love.graphics.printf(p2, 25, 10, Wwidth - 45, "right")
    
    love.graphics.rectangle("fill", 25, 75, Wwidth - 50, 2.5)
    love.graphics.rectangle("fill", 25, Wheight - 80, Wwidth - 50, 2.5)

    if gameType == "PvP" then
      love.graphics.printf("P1", 25, Wheight - 70, Wwidth, "left")
      love.graphics.printf("P2", 25, Wheight - 70, Wwidth - 45, "right")
    else
      love.graphics.printf("BOT", 25, Wheight - 70, Wwidth, "left")
      love.graphics.printf("Player", 25, Wheight - 70, Wwidth - 45, "right")
    end
    y1 = math.min(y1, Wheight - 135)
    love.graphics.rectangle("fill", 30, y1, 10, 50)
    love.graphics.rectangle("fill", Wwidth - 40, y2, 10, 50)

    love.graphics.rectangle("fill", x, y, 15, 15)

    if gameState == "play" then
      love.graphics.printf(os.time() - T - Stime, 0, Wheight - 70, Wwidth, "center")
    end

    if gameState == "stop" then
      love.graphics.printf(S1time - T - Stime, 0, Wheight - 70, Wwidth, "center")
    end
  end
  --
  --[[
    WIN / LOSE WINDOW
  ]]
    if gameState == "1won" then
      love.graphics.printf("PONG", 0, 10, Wwidth, "center")
      love.graphics.printf(p1, 25, 10, Wwidth, "left")
      love.graphics.printf(p2, 25, 10, Wwidth - 45, "right")
      love.graphics.setFont(font_2)
      love.graphics.printf("Player 1 has won! Congratulations!!!", 0, Wheight / 2 - 64, Wwidth, "center")
      love.graphics.setFont(font_1)
    end

    if gameState == "2won" then
      love.graphics.printf("PONG", 0, 10, Wwidth, "center")
      love.graphics.printf(p1, 25, 10, Wwidth, "left")
      love.graphics.printf(p2, 25, 10, Wwidth - 45, "right")
      love.graphics.setFont(font_2)
      love.graphics.printf("Player 2 has won! Congratulations!!!", 0, Wheight / 2 - 64, Wwidth, "center")
      love.graphics.setFont(font_1)
    end

    if gameState == "draw" then
      love.graphics.printf("PONG", 0, 10, Wwidth, "center")
      love.graphics.printf(p1, 25, 10, Wwidth, "left")
      love.graphics.printf(p2, 25, 10, Wwidth - 45, "right")
      love.graphics.setFont(font_2)
      love.graphics.printf("DRAW! \n No one has won!", 0, Wheight / 2 - 64, Wwidth, "center")
      love.graphics.setFont(font_1)
    end

    if gameState == "win" then
      love.graphics.printf("PONG", 0, 10, Wwidth, "center")
      love.graphics.printf(p1, 25, 10, Wwidth, "left")
      love.graphics.printf(p2, 25, 10, Wwidth - 45, "right")
      love.graphics.setFont(font_2)
      love.graphics.printf("Bot was defeated! \n Congratulations!!!", 0, Wheight / 2 - 64, Wwidth, "center")
      love.graphics.setFont(font_1)
      love.graphics.printf("Press G to pay respect", 0, Wheight - 96, Wwidth, "center")
    end

    if gameState == "lose" then
      love.graphics.printf("PONG", 0, 10, Wwidth, "center")
      love.graphics.printf(p1, 25, 10, Wwidth, "left")
      love.graphics.printf(p2, 25, 10, Wwidth - 45, "right")
      love.graphics.setFont(font_2)
      love.graphics.printf("You have lost! \n :((((((((((((", 0, Wheight / 2 - 64, Wwidth, "center")
      love.graphics.setFont(font_1)
    end
  push:apply("end")
end
-- copy /b love.exe+game.love pong_v1.0.exe