# OBS Auto Record Window

This script automatically starts/pauses recording when the specified exe gains/loses focus. Useful for only recording an application when you're actually using it, cutting out afk time and saving space and video length.

# Usage

1. Install autohotkey and pull this repo.
2. In obs `Tools >> Scripts >> +`, import `auto_record_window.lua`.
3. Set `AHK Script Path` to the location you stored `WindowCheck.ahk` in.
4. Set Process Name to the exe you want to automatically record (eg `photoshop.exe`).
5. Reload the script and check `Enable Script` to use.

Now OBS will automatically start recording when the specified exe gains focus. When it loses focus OBS will pause the recording.

# Config
### auto_record_window.lua
(in OBS Scripts tab)  
`AHK Script Path`: The path to where you put `WindowCheck.ahk`.  
`Process Name` The exe of the program you want to run. (eg `chrome.exe`)  
`Check Interval (seconds)` Default: `0.5` The amount of time in seconds it takes to re-check the currently focused window. Low values (0.01) may cause performance issues due to reading file off of disk many times per second.  

### WindowCheck.ahk` 
(inside file)  
`SetTimer(() => GetActiveWindow(), 100)` Checks currently focused every 0.1ms, and if it's different, it writes to a file. The ahk and lua script my not be in sync, so the ahk script checks frequently to lower latency. Generally a pretty fast operation but if you're on very slow hardware, you may want to increase the value.  
`SetTimer(() => KillOnOBSClose(), 15000)` Checks if OBS exists every 15 seconds. If OBS doesn't exist the script auto closes.  
