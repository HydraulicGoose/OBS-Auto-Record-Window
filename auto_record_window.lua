local obs = obslua
-- add check if started and not ahk_script_running, run ahk script with commandline arguments
-- Variables
local enabled = false
local ahk_script_path = ""
local selected_process_name = ""
local check_interval_sec = 1.0
local timer = 0.0
local ahk_running = false
local last_mod_time = 0


-- ---------- OBS functions called on script startup
function script_properties()  -- UI Properties

    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "ahk_script_path", "AHK Script Path", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "selected_process_name", "Process Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_float(props, "check_interval_sec", "Check Interval (seconds)", 0.1, 1000, 0.1)
	obs.obs_properties_add_bool(props, "enabled", "Enable Script")
    return props
end

function script_update(settings)  -- Updates variables from ui
    
    ahk_script_path = obs.obs_data_get_string(settings, "ahk_script_path")
    selected_process_name = obs.obs_data_get_string(settings, "selected_process_name"):lower()
    check_interval_sec = obs.obs_data_get_double(settings, "check_interval_sec")
	enabled = obs.obs_data_get_bool(settings, "enabled")
	
end

function script_defaults(settings) --- Ui default values

    obs.obs_data_set_default_double(settings, "check_interval_sec", 0.5)
    obs.obs_data_set_default_bool(settings, "enabled", false)
    obs.obs_data_set_default_string(settings, "ahk_script_path", "C:\\Path\\To\\script.ahk")
    obs.obs_data_set_default_string(settings, "selected_process_name", "program.exe")
end


-- ---------- Code

-- Function to check if file exists
local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

-- Function that runs ahk script if it isn't already running
local function run_ahk_script()

    if not ahk_running and enabled then
        local command = string.format([[""C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe" "%s"]], ahk_script_path) -- Variable to run .ahk script with autothotkey
	
	    -- If file doesn't exist, error and disable script
        if not file_exists("C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe") or not file_exists(ahk_script_path) then
	        error("Either the autohotkey file path is incorrect or autohotkey isn't installed")
	    	enabled = false
	    	return
	    end	
	    
        os.execute(command) -- Runs ahk script that saves currently focused application to temp file
		
		ahk_running = true -- Flag to stop ahk from running again
	end	
end

-- Gets the exe of the currently focused window by opening external autohotkey script which saves the focused windows exe to a file, then this function reads that temp file and returns it
local function get_active_window_process_name()

    run_ahk_script() -- Runs ahk script if it isn't already running
	
	local temp_path = os.getenv("TEMP") or os.getenv("TMP") or "/tmp" -- Gets path of temp folder
	local file = io.open(temp_path .. "\\auto_record_window_script.txt", "r")  -- Opens temp file holding focused window exe
	
	-- If file doesn't exist, error and disable script
	if not file then
	    print("Could not read temp file. (happens on first launch)")
		return
	end	
	
	local result = file:read("*a") -- Reads file
    file:close() -- Closes file
	
    return result
end

-- Toggles recording if the selected process is focused
local function toggle_recording_if_process_focused()
    if not enabled then return end  -- Disables if "enabled" is false

    local process_name = get_active_window_process_name() -- Calls function to get the active window exe
    if not process_name then return end -- Ends function if process name doesn't exist

    local is_process = (process_name:lower() == selected_process_name)
    local recording = obs.obs_frontend_recording_active()
    local paused = obs.obs_frontend_recording_paused()

    if is_process then -- If process is the selected process, record
	
        --if not recording then -- If not recording, then record
        --    obs.obs_frontend_recording_start()
        --    print("Started recording (Process active)")
			
        if paused then -- If paused, then unpause
            obs.obs_frontend_recording_pause(false)
			
        end
		
    elseif recording and not paused then -- If window is not focused, pause recording
        obs.obs_frontend_recording_pause(true)
		
    end
end

-- Tick handler: called periodically with the number of seconds since the last tick
function script_tick(seconds)
    -- Disables script if "enabled" is false
    if not enabled then return end

    -- Increment the timer by the elapsed time
    timer = timer + seconds

    -- If the accumulated time exceeds the check interval, perform the toggle logic
    if timer >= check_interval_sec then
        toggle_recording_if_process_focused()  -- Call the function to handle recording state
        timer = 0  -- Reset the timer after the check
    end
end


-- ---------- Description
function script_description()
    return [[
Automatically starts/pauses recording when specified window is active/inactive.
Useful for only recording when you're using the specified applicaiton.

Require AutoHotKey V2 and the autohotkey script included in this repo.
]]
end
