[English](#galactic-ball) | [中文](#%E9%93%B6%E6%B2%B3%E5%BC%B9%E7%90%83-galactic-ball)

# Galactic Ball

A classic brick breaker game built with Godot Engine 4.6.

---

## Features

- Classic brick-breaking gameplay
- Smooth paddle controls (Arrow keys or A/D)
- **Skill system with energy bar (J/K/L keys)**
- Particle explosion effects
- Screen shake feedback
- Score system with floating text
- Fire trail effects
- Starfield background
- Game over and win conditions
- Restart functionality (Press R)

## Controls

| Key | Action |
|-----|--------|
| ← / A | Move paddle left |
| → / D | Move paddle right |
| J | Hold to shrink paddle (50% width) - consumes energy |
| K | Hold to extend paddle (double width) - consumes energy |
| L | Clear bottom row of bricks - requires full energy |
| R | Restart game (when game over) |

## Skill System

The game features an energy-based skill system:

- **Energy Bar**: Located on the right side of the screen
- **Energy Regeneration**: Energy automatically regenerates when not using skills
- **J Skill (Shrink)**: Hold J to shrink the paddle to 50% width - useful for precise control
- **K Skill (Extend)**: Hold K to extend the paddle to double width - helps catch the ball
- **L Skill (Clear Bottom Row)**: Press L when energy is full to instantly destroy the bottom row of bricks

## Requirements

- Godot Engine 4.6 or later

## How to Play

1. Open the project in Godot Engine
2. Press F5 or click the Play button
3. Use arrow keys or A/D to control the paddle
4. Break all bricks to win!
5. Don't let the ball fall below the paddle

## Project Structure

```
Galactic Ball/
├── scenes/                 # Godot scene files
│   ├── actors/             # Game entities
│   │   ├── enemies/
│   │   │   └── Brick.tscn
│   │   └── player/
│   │       ├── Ball.tscn
│   │       └── Paddle.tscn
│   └── system/             # System scenes
│       ├── ExplosionParticles.tscn
│       ├── FireTrail.tscn
│       ├── GameWorld.tscn
│       ├── GlassShards.tscn
│       ├── StarBackground.tscn
│       └── TrailParticle.tscn
├── scripts/                # GDScript files
│   ├── components/         # Game component scripts
│   │   ├── Ball.gd
│   │   ├── Brick.gd
│   │   └── Paddle.gd
│   └── utils/              # Utility scripts
│       ├── ExplosionParticles.gd
│       ├── FireTrail.gd
│       ├── GlassShards.gd
│       ├── Main.gd
│       ├── StarBackground.gd
│       └── TrailParticle.gd
├── project.godot           # Godot project file
└── README.md
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Created with Godot Engine

---

---

# 银河弹球 (Galactic Ball)

一个使用 Godot Engine 4.6 开发的经典打砖块游戏。

---

## 特性

- 经典打砖块玩法
- 流畅的挡板控制（方向键或 A/D）
- **技能系统与能量条（J/K/L 键）**
- 粒子爆炸效果
- 屏幕震动反馈
- 分数系统与浮动文字
- 火焰拖尾效果
- 星空背景
- 游戏结束和胜利条件
- 重新开始功能（按 R 键）

## 控制

| 按键 | 功能 |
|------|------|
| ← / A | 挡板左移 |
| → / D | 挡板右移 |
| J | 按住缩小挡板（50%宽度）- 消耗能量 |
| K | 按住加长挡板（双倍宽度）- 消耗能量 |
| L | 清除最下面一排砖块 - 需要满能量 |
| R | 重新开始游戏（游戏结束时） |

## 技能系统

游戏拥有基于能量的技能系统：

- **能量条**：位于屏幕右侧
- **能量恢复**：不使用时自动恢复能量
- **J 技能（缩小）**：按住 J 将挡板缩小至50%宽度 - 适合精准控制
- **K 技能（加长）**：按住 K 将挡板加长至双倍宽度 - 更容易接球
- **L 技能（清底）**：能量满时按 L 瞬间清除最下面一排砖块

## 运行要求

- Godot Engine 4.6 或更高版本

## 游戏说明

1. 在 Godot Engine 中打开项目
2. 按 F5 或点击播放按钮
3. 使用方向键或 A/D 控制挡板
4. 打破所有砖块即可获胜！
5. 不要让球掉到挡板下方

## 项目结构

```
Galactic Ball/
├── scenes/                 # Godot 场景文件
│   ├── actors/             # 游戏实体
│   │   ├── enemies/
│   │   │   └── Brick.tscn
│   │   └── player/
│   │       ├── Ball.tscn
│   │       └── Paddle.tscn
│   └── system/             # 系统场景
│       ├── ExplosionParticles.tscn
│       ├── FireTrail.tscn
│       ├── GameWorld.tscn
│       ├── GlassShards.tscn
│       ├── StarBackground.tscn
│       └── TrailParticle.tscn
├── scripts/                # GDScript 脚本文件
│   ├── components/         # 游戏组件脚本
│   │   ├── Ball.gd
│   │   ├── Brick.gd
│   │   └── Paddle.gd
│   └── utils/              # 工具脚本
│       ├── ExplosionParticles.gd
│       ├── FireTrail.gd
│       ├── GlassShards.gd
│       ├── Main.gd
│       ├── StarBackground.gd
│       └── TrailParticle.gd
├── project.godot           # Godot 项目文件
└── README.md
```

## 许可证

本项目采用 MIT 许可证 - 详情请参见 [LICENSE](LICENSE) 文件。

## 致谢

使用 Godot Engine 制作
