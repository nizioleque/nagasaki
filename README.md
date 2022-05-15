# Nagasaki Minesweeper

Mobile game made in Flutter. 

Modern interpretation of the classic Minesweeper with many features, including saving game state (with serialization), custom stateful and stateless widgets, custom dialog, animations and more.

[**Click here to play now!**](https://spicy-nachos.github.io/nagasaki/)

## About

Created as an opportunity to learn Flutter by two CS students from Warsaw, Poland.

### Features

- Modern high-resolution graphics inspired by the Windows Minesweeper
- Animations
- Three difficulty levels & custom settings
- Automatically saving and restoring the game
- Sound effects & haptic feedback
- Responsive layout adapting to the window size

### Implementation overview

- Saving game state – serialization with json_serializable package and detecting app closing with didChangeAppLifecycleState
- Sounds – audioplayers package
- Custom stateful and stateless widgets for various elements of the UI
- Iterator for analyzing the surroundings of a field
- Custom dialog for the settings panel & game end
- Text field validation
- Asynchronous functions for loading/saving settings and (de)serialization
- LayoutBuilder for a responsive header layout
