# Love2D Game

A basic Love2D game project with a solid foundation for game development.

## Features

- **State Management System**: Easy switching between game states (menu, game, etc.)
- **Menu State**: Simple start screen with navigation
- **Game State**: Basic game loop with player movement
- **Modular Structure**: Organized code structure for easy expansion

## Project Structure

```
├── conf.lua              # Love2D configuration
├── main.lua              # Main entry point and state manager
├── src/
│   ├── states/
│   │   ├── menu.lua      # Menu state
│   │   └── game.lua      # Game state
│   ├── entities/         # Game entities (player, enemies, etc.)
│   └── utils/            # Utility functions and helpers
└── README.md
```

## How to Run

1. Install [Love2D](https://love2d.org/) on your system
2. Navigate to the project directory
3. Run the game with one of these methods:
   - Drag the project folder onto the Love2D executable
   - Run `love .` in the project directory (if Love2D is in your PATH)
   - On Windows: `"C:\Program Files\LOVE\love.exe" .`

## Controls

### Menu State
- **SPACE**: Start the game
- **ESC**: Quit the application

### Game State
- **WASD** or **Arrow Keys**: Move the player
- **M**: Return to menu
- **ESC**: Quit the application

## Game States

### StateManager
The game uses a simple state management system that handles:
- State switching with `StateManager:switch(stateName)`
- Proper cleanup when exiting states
- Event forwarding to current state

### Menu State
- Displays the game title and instructions
- Handles input to start the game

### Game State
- Basic game loop with player movement
- Displays game time and player position
- Simple collision detection with screen boundaries

## Development

This project provides a solid foundation for Love2D game development. You can easily:

1. **Add new states**: Create new files in `src/states/` and register them in `main.lua`
2. **Add entities**: Create game objects in `src/entities/`
3. **Add utilities**: Create helper functions in `src/utils/`
4. **Expand gameplay**: Add more features to the existing states

## Next Steps

Some ideas for expanding this foundation:
- Add a pause state
- Implement a simple physics system
- Add sprites and animations
- Create enemies and collision detection
- Add sound effects and music
- Implement a scoring system
- Add multiple levels or scenes

## Dependencies

- Love2D 11.4+ (configured in `conf.lua`)

## License

This project is open source and available under the MIT License.