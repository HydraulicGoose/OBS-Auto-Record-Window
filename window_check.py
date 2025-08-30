#!/usr/bin/env python3

import os
import time
import psutil
import subprocess
from pathlib import Path
import sys


def get_active_window_class():
    # Get the window ID of the currently active window
    window_id = subprocess.check_output(['xdotool', 'getactivewindow']).strip()

    # Get the window class (WM_CLASS) using xprop
    wm_class = subprocess.check_output(['xprop', '-id', window_id, 'WM_CLASS'])

    # Decode and parse the output to extract the class name
    wm_class = wm_class.decode('utf-8')

    # Extract the second string (usually the class) after the comma
    class_name = wm_class.split('=')[1].strip().split(',')[1].strip().strip('"')

    return class_name


def is_obs_running():
    """Check if any process named 'obs' is running."""
    for proc in psutil.process_iter(['name']):
        if proc.info['name'] and 'obs' in proc.info['name'].lower():
            return True
    return False


def main():

    home_dir = os.path.expanduser("~")
    temp_name = "auto_record_window_script.txt"
    temp_path = os.path.join(home_dir, temp_name)

    last_process = ""

    # Write initial text to file
    with open(temp_path, 'w') as f:
        f.write("This is a manually created temp file.")

    # Timer to check OBS every 15 seconds
    obs_check_interval = 15
    last_obs_check = time.time()

    while True:

        # Check if OBS is running every 15 seconds
        if time.time() - last_obs_check >= obs_check_interval:
            if not is_obs_running():
                print("OBS is not running. Exiting script.")

                if os.path.exists(temp_path):
                    os.remove(temp_path)

                sys.exit(0)

            last_obs_check = time.time()
        
        # Write current process to temp file
        current_process = get_active_window_class()

        if current_process and current_process != last_process:

            if os.path.exists(temp_path):
                os.remove(temp_path)

            with open(temp_path, 'w') as f:
                f.write(current_process)

            last_process = current_process

        time.sleep(0.1)


if __name__ == "__main__":
    main()
