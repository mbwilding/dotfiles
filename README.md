# Dotfiles

## Linux

### Key repeat

 - Delay :  195ms
 - Rate:  67 repeats/s

## Mac

### Key repeat

 - Delay :  195ms
 - Repeat:   15ms

```bash
defaults write -g InitialKeyRepeat -int 13
defaults write -g KeyRepeat -int 1
defaults write -g ApplePressAndHoldEnabled -bool false
```

## Windows

### Key repeat

 - Delay: 195ms (approximate, "Repeat delay" in settings)
 - Rate: 67 repeats/s (approximate, "Repeat rate" in settings)

```reg
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\Keyboard]
"KeyboardDelay"="1"
"KeyboardSpeed"="31"
```

- `KeyboardDelay` ranges from 1 (shortest) to 3 (longest).
- `KeyboardSpeed` ranges from 0 (slowest) to 31 (fastest).
