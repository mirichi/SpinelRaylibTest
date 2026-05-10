require_relative "rayliblib"

class Bullet
  attr_accessor :x, :y, :vx, :vy, :active, :speed

  def initialize
    @x = 0.0
    @y = 0.0
    @speed = 15.0
    @vx = 0.0
    @vy = 0.0
    @active = false
  end

  def update(px, py)
    @x += @vx
    @y += @vy
    dx = @x - px
    dy = @y - py
    if dx * dx + dy * dy > 1500.0 * 1500.0
      @active = false
    end
  end

  def draw(cx, cy)
    if @active
      sx = @x - cx
      sy = @y - cy
      RAY.SpDrawRectangle(sx.to_i - 2, sy.to_i - 2, 4, 4, RAY::RED)
    end
  end
end

class BulletManager
  attr_accessor :bullets

  def initialize(max_bullets)
    @bullets = []
    max_bullets.times do
      @bullets.push(Bullet.new)
    end
  end

  def add(x, y, angle)
    @bullets.each do |b|
      if !b.active
        b.x = x
        b.y = y
        b.vx = b.speed * Math.cos(angle)
        b.vy = b.speed * Math.sin(angle)
        b.active = true
        return
      end
    end
  end

  def update(px, py)
    @bullets.each do |b|
      b.update(px, py) if b.active
    end
  end

  def draw(cx, cy)
    @bullets.each do |b|
      b.draw(cx, cy) if b.active
    end
  end
end

class Item
  attr_accessor :x, :y, :active, :life

  def initialize
    @x = 0.0
    @y = 0.0
    @active = false
    @life = 600
  end

  def spawn(x, y)
    @x = x
    @y = y
    @active = true
    @life = 600 # 寿命は600フレーム（約10秒）
  end

  # 引き寄せと寿命の更新処理
  def update(px, py, magnet_radius)
    @life = @life - 1
    if @life <= 0
      @active = false
      return
    end

    dx = px - @x
    dy = py - @y
    dist_sq = dx * dx + dy * dy
    if dist_sq < magnet_radius * magnet_radius
      dist = Math.sqrt(dist_sq)
      if dist > 0.1
        speed = 12.0
        @x = @x + (dx / dist) * speed
        @y = @y + (dy / dist) * speed
      end
    end
  end

  def draw(cx, cy)
    if @active
      # 寿命が2秒（120フレーム）を切ったら点滅させる
      if @life < 120 && (@life % 20) < 10
        return
      end

      sx = @x - cx
      sy = @y - cy
      RAY.SpDrawRectangle(sx.to_i - 5, sy.to_i - 5, 10, 10, RAY::YELLOW)
    end
  end
end

class ItemManager
  attr_accessor :items

  def initialize(max_items)
    @items = []
    max_items.times do
      @items.push(Item.new)
    end
  end

  def add(x, y)
    @items.each do |i|
      if !i.active
        i.spawn(x, y)
        break
      end
    end
  end

  def update(px, py, magnet_radius)
    @items.each do |i|
      i.update(px, py, magnet_radius) if i.active
    end
  end

  def draw(cx, cy)
    @items.each do |i|
      i.draw(cx, cy) if i.active
    end
  end
end

# --- 爆発エフェクト用のパーティクルクラス ---
class Particle
  attr_accessor :x, :y, :vx, :vy, :active, :life, :max_life

  def initialize
    @x = 0.0
    @y = 0.0
    @vx = 0.0
    @vy = 0.0
    @active = false
    @life = 0
    @max_life = 30
  end

  def spawn(x, y, vx, vy, life)
    @x = x
    @y = y
    @vx = vx
    @vy = vy
    @life = life
    @max_life = life
    @active = true
  end

  def update
    @x = @x + @vx
    @y = @y + @vy
    @life = @life - 1
    if @life <= 0
      @active = false
    end
  end

  def draw(cx, cy)
    if @active
      sx = @x - cx
      sy = @y - cy
      # 寿命（life）が減るにつれて四角形を小さく描画する
      size = (@life.to_f / @max_life) * 10.0
      RAY.SpDrawRectangle(sx.to_i - size.to_i / 2, sy.to_i - size.to_i / 2, size.to_i, size.to_i, RAY::ORANGE)
    end
  end
end

class ParticleManager
  attr_accessor :particles

  def initialize(max_particles)
    @particles = []
    max_particles.times do
      @particles.push(Particle.new)
    end
  end

  # 敵が死んだ座標を起点に、複数のパーティクルを散らす
  def add_explosion(x, y)
    10.times do
      angle = rand(360) * Math::PI / 180.0
      speed = rand(5).to_f + 2.0
      vx = speed * Math.cos(angle)
      vy = speed * Math.sin(angle)
      life = rand(15) + 15

      @particles.each do |p|
        if !p.active
          p.spawn(x, y, vx, vy, life)
          break
        end
      end
    end
  end

  def update
    @particles.each do |p|
      p.update if p.active
    end
  end

  def draw(cx, cy)
    @particles.each do |p|
      p.draw(cx, cy) if p.active
    end
  end
end

class Enemy
  attr_accessor :x, :y, :vx, :vy, :active, :speed, :radius, :hp, :max_hp

  def initialize
    @x = 0.0
    @y = 0.0
    @vx = 0.0
    @vy = 0.0
    @active = false
    @speed = 2.0
    @radius = 15.0
    @hp = 1
    @max_hp = 1
  end

  def spawn(px, py)
    edge = rand(4)
    if edge == 0
      @x = px + (rand(1400) - 700).to_f
      @y = py - 400.0
    elsif edge == 1
      @x = px + (rand(1400) - 700).to_f
      @y = py + 400.0
    elsif edge == 2
      @x = px - 700.0
      @y = py + (rand(800) - 400).to_f
    else
      @x = px + 700.0
      @y = py + (rand(800) - 400).to_f
    end
    @active = true

    # 10%の確率で硬い敵（大型）になる
    if rand(10) == 0
      @hp = 10
      @max_hp = 10
      @speed = 1.0
      @radius = 25.0
    else
      @hp = 1
      @max_hp = 1
      @speed = 2.0
      @radius = 15.0
    end
  end

  def update(px, py)
    angle = Math.atan2(py - @y, px - @x)
    @x += @speed * Math.cos(angle)
    @y += @speed * Math.sin(angle)
  end

  def draw(cx, cy)
    if @active
      sx = @x - cx
      sy = @y - cy
      size = (@radius * 2).to_i
      
      if @max_hp > 1
        # 硬い敵は赤くて大きい
        RAY.SpDrawRectangle(sx.to_i - size / 2, sy.to_i - size / 2, size, size, RAY::RED)
        
        # HPバーの描画
        bar_width = size
        hp_ratio = @hp.to_f / @max_hp
        RAY.SpDrawRectangle(sx.to_i - size / 2, sy.to_i - size / 2 - 10, bar_width, 5, RAY::GRAY)
        RAY.SpDrawRectangle(sx.to_i - size / 2, sy.to_i - size / 2 - 10, (bar_width * hp_ratio).to_i, 5, RAY::GREEN)
      else
        # 通常の敵
        RAY.SpDrawRectangle(sx.to_i - size / 2, sy.to_i - size / 2, size, size, RAY::BLUE)
      end
    end
  end
end

class EnemyManager
  attr_accessor :enemies, :spawn_timer, :spawn_interval

  def initialize(max_enemies)
    @enemies = []
    max_enemies.times do
      @enemies.push(Enemy.new)
    end
    @spawn_timer = 0
    @spawn_interval = 60.0
  end

  def update(px, py)
    if @spawn_interval > 5.0
      @spawn_interval -= 0.01
    end

    @spawn_timer -= 1
    if @spawn_timer <= 0
      @spawn_timer = @spawn_interval.to_i
      @enemies.each do |e|
        if !e.active
          e.spawn(px, py)
          break
        end
      end
    end

    @enemies.each do |e|
      e.update(px, py) if e.active
    end
  end

  def draw(cx, cy)
    @enemies.each do |e|
      e.draw(cx, cy) if e.active
    end
  end
end

class Player
  attr_accessor :x, :y, :radius, :sides, :rotation, :speed, :fire_timer, :fire_rate, :score, :magnet_radius

  def initialize(x, y)
    @x = x.to_f
    @y = y.to_f
    @radius = 30.0
    @sides = 3
    @rotation = 0.0
    @speed = 5.0
    @fire_timer = 0
    @fire_rate = 10
    @score = 0
    @magnet_radius = 150.0 # アイテムを引き寄せる範囲
  end

  def update(bullet_manager)
    @y -= @speed if RAY.IsKeyDown(RAY::KEY_W) != 0
    @y += @speed if RAY.IsKeyDown(RAY::KEY_S) != 0
    @x -= @speed if RAY.IsKeyDown(RAY::KEY_A) != 0
    @x += @speed if RAY.IsKeyDown(RAY::KEY_D) != 0

    cx = @x - 1280 / 2.0
    cy = @y - 720 / 2.0

    mx = RAY.SpGetMouseX() + cx
    my = RAY.SpGetMouseY() + cy

    # マウス左クリックホールドによる移動
    if RAY.IsMouseButtonDown(RAY::MOUSE_LEFT_BUTTON) != 0
      dx = mx - @x
      dy = my - @y
      dist = Math.sqrt(dx * dx + dy * dy)
      if dist > @speed
        @x = @x + (dx / dist) * @speed
        @y = @y + (dy / dist) * @speed
      else
        @x = mx
        @y = my
      end
    end

    @rotation = Math.atan2(my - @y, mx - @x)

    if @fire_timer > 0
      @fire_timer -= 1
    else
      @fire_timer = @fire_rate
      @sides.times do |i|
        angle = @rotation + i * (2 * Math::PI / @sides)
        vx = @x + @radius * Math.cos(angle)
        vy = @y + @radius * Math.sin(angle)
        bullet_manager.add(vx, vy, angle)
      end
    end
  end

  def draw(cx, cy)
    sx = @x - cx
    sy = @y - cy

    @sides.times do |i|
      angle1 = @rotation + i * (2 * Math::PI / @sides)
      vx1 = sx + @radius * Math.cos(angle1)
      vy1 = sy + @radius * Math.sin(angle1)

      angle2 = @rotation + ((i + 1) % @sides) * (2 * Math::PI / @sides)
      vx2 = sx + @radius * Math.cos(angle2)
      vy2 = sy + @radius * Math.sin(angle2)

      RAY.SpDrawTriangle(sx.to_f, sy.to_f, vx2.to_f, vy2.to_f, vx1.to_f, vy1.to_f, RAY::GREEN)
      RAY.SpDrawLine(vx1.to_i, vy1.to_i, vx2.to_i, vy2.to_i, RAY::WHITE)
      RAY.SpDrawRectangle(vx1.to_i - 2, vy1.to_i - 2, 4, 4, RAY::WHITE)
    end
  end
end

def check_collisions(bullet_manager, enemy_manager, item_manager, particle_manager, player)
  # 弾と敵の判定
  enemy_manager.enemies.each do |e|
    if e.active
      bullet_manager.bullets.each do |b|
        if b.active
          dx = e.x - b.x
          dy = e.y - b.y
          dist_sq = dx * dx + dy * dy
          hit_dist = e.radius + 2.0
          if dist_sq < hit_dist * hit_dist
            b.active = false
            e.hp = e.hp - 1
            
            if e.hp <= 0
              e.active = false
              particle_manager.add_explosion(e.x, e.y)
              
              if e.max_hp > 1
                # 硬い敵はアイテムを5個ドロップする
                5.times do
                  drop_x = e.x + (rand(40) - 20).to_f
                  drop_y = e.y + (rand(40) - 20).to_f
                  item_manager.add(drop_x, drop_y)
                end
              else
                # 通常の敵は1個
                item_manager.add(e.x, e.y)
              end
            end
            break
          end
        end
      end
    end
  end

  # アイテムとプレイヤーの判定
  item_manager.items.each do |i|
    if i.active
      dx = player.x - i.x
      dy = player.y - i.y
      if dx * dx + dy * dy < 45.0 * 45.0
        i.active = false
        player.score = player.score + 10
      end
    end
  end
end

class Game
  attr_accessor :player, :bullet_manager, :enemy_manager, :item_manager, :particle_manager, :game_state

  def initialize
    @player = Player.new(1280 / 2, 720 / 2)
    @bullet_manager = BulletManager.new(1000)
    @enemy_manager = EnemyManager.new(300)
    @item_manager = ItemManager.new(500)
    @particle_manager = ParticleManager.new(1000) # 爆発エフェクト用プール
    @game_state = 0 # 0: Playing, 1: Menu
  end

  def update_draw_frame
    esc_pressed = RAY.IsKeyPressed(RAY::KEY_ESCAPE) != 0
    right_clicked = RAY.IsMouseButtonPressed(RAY::MOUSE_RIGHT_BUTTON) != 0

    if esc_pressed || right_clicked
      if @game_state == 0
        @game_state = 1
      else
        @game_state = 0
      end
    end

    if @game_state == 0
      @player.update(@bullet_manager)
      @bullet_manager.update(@player.x, @player.y)
      @enemy_manager.update(@player.x, @player.y)
      @item_manager.update(@player.x, @player.y, @player.magnet_radius)
      @particle_manager.update
      check_collisions(@bullet_manager, @enemy_manager, @item_manager, @particle_manager, @player)
    elsif @game_state == 1
      shape_cost = (@player.sides - 2) * 100
      
      # マウスによる選択判定の準備
      mx = RAY.SpGetMouseX()
      my = RAY.SpGetMouseY()
      left_click = RAY.IsMouseButtonPressed(RAY::MOUSE_LEFT_BUTTON) != 0

      # 各メニュー項目の当たり判定
      hover1 = mx >= 380 && mx <= 1180 && my >= 245 && my <= 290
      hover2 = mx >= 380 && mx <= 1180 && my >= 295 && my <= 340
      hover3 = mx >= 380 && mx <= 1180 && my >= 345 && my <= 390
      hover4 = mx >= 380 && mx <= 1180 && my >= 395 && my <= 440

      if (RAY.IsKeyPressed(RAY::KEY_ONE) != 0 || (hover1 && left_click)) && @player.score >= shape_cost
        @player.score = @player.score - shape_cost
        @player.sides = @player.sides + 1
      end
      if (RAY.IsKeyPressed(RAY::KEY_TWO) != 0 || (hover2 && left_click)) && @player.score >= 50
        @player.score = @player.score - 50
        @player.speed = @player.speed + 1.0
      end
      if (RAY.IsKeyPressed(RAY::KEY_THREE) != 0 || (hover3 && left_click)) && @player.score >= 50 && @player.fire_rate > 2
        @player.score = @player.score - 50
        @player.fire_rate = @player.fire_rate - 2
      end
      if (RAY.IsKeyPressed(RAY::KEY_FOUR) != 0 || (hover4 && left_click)) && @player.score >= 50
        @player.score = @player.score - 50
        @player.magnet_radius = @player.magnet_radius + 50.0
      end
    end

    RAY.BeginDrawing()
    RAY.SpClearBackground(RAY::BLACK)

    # カメラ座標（プレイヤーを画面中央にするためのオフセット）
    cx = @player.x - 1280 / 2.0
    cy = @player.y - 720 / 2.0

    # グリッドの描画
    grid_size = 100
    offset_x = -(cx.to_i % grid_size)
    offset_y = -(cy.to_i % grid_size)

    x = offset_x
    while x < 1280
      RAY.SpDrawLine(x, 0, x, 720, RAY::DARKGRAY)
      x += grid_size
    end

    y = offset_y
    while y < 720
      RAY.SpDrawLine(0, y, 1280, y, RAY::DARKGRAY)
      y += grid_size
    end

    @particle_manager.draw(cx, cy)
    @item_manager.draw(cx, cy)
    @enemy_manager.draw(cx, cy)
    @bullet_manager.draw(cx, cy)
    @player.draw(cx, cy)

    score_str = "SCORE: " + @player.score.to_s
    RAY.SpDrawText(score_str, 20, 20, 30, RAY::WHITE)

    if @game_state == 1
      bg_color = RAY::Color.value(0, 0, 0, 150)
      RAY.SpDrawRectangle(0, 0, 1280, 720, bg_color)
      
      RAY.SpDrawText("--- SKILL MENU ---", 450, 150, 40, RAY::WHITE)
      
      # マウスホバー位置の取得（ハイライト用）
      mx = RAY.SpGetMouseX()
      my = RAY.SpGetMouseY()
      hover1 = mx >= 380 && mx <= 1180 && my >= 245 && my <= 290
      hover2 = mx >= 380 && mx <= 1180 && my >= 295 && my <= 340
      hover3 = mx >= 380 && mx <= 1180 && my >= 345 && my <= 390
      hover4 = mx >= 380 && mx <= 1180 && my >= 395 && my <= 440

      # ホバー中の項目をハイライト表示
      RAY.SpDrawRectangle(380, 245, 800, 45, RAY::DARKGRAY) if hover1
      RAY.SpDrawRectangle(380, 295, 800, 45, RAY::DARKGRAY) if hover2
      RAY.SpDrawRectangle(380, 345, 800, 45, RAY::DARKGRAY) if hover3
      RAY.SpDrawRectangle(380, 395, 800, 45, RAY::DARKGRAY) if hover4

      shape_cost = (@player.sides - 2) * 100
      t1 = "[1] Upgrade Shape  (Cost: " + shape_cost.to_s + ") -> Sides: " + (@player.sides + 1).to_s
      t2 = "[2] Speed Up       (Cost: 50) -> Speed: " + (@player.speed + 1.0).to_s
      t3 = "[3] Fire Rate Up   (Cost: 50)"
      t4 = "[4] Magnet Radius  (Cost: 50) -> Range: " + (@player.magnet_radius + 50.0).to_s
      
      RAY.SpDrawText(t1, 400, 250, 30, @player.score >= shape_cost ? RAY::WHITE : RAY::GRAY)
      RAY.SpDrawText(t2, 400, 300, 30, @player.score >= 50 ? RAY::WHITE : RAY::GRAY)
      RAY.SpDrawText(t3, 400, 350, 30, (@player.score >= 50 && @player.fire_rate > 2) ? RAY::WHITE : RAY::GRAY)
      RAY.SpDrawText(t4, 400, 400, 30, @player.score >= 50 ? RAY::WHITE : RAY::GRAY)
      
      RAY.SpDrawText("Right Click or ESC to Resume", 400, 500, 20, RAY::GRAY)
    end

    RAY.EndDrawing()
  end
end

RAY.InitWindow(1280, 720, "raylib and Spinel Sample")
RAY.SetTargetFPS(60)
RAY.SetExitKey(RAY::KEY_NULL) # ESCで勝手に終了しないようにする

game = Game.new

while !RAY.WindowShouldClose()
  game.update_draw_frame
  RAY.SpSleep() # EmscriptenのAsyncify用。ネイティブでは何もしない
end

RAY.CloseWindow()

