#!/usr/bin/env python3

import os
import time
import psutil
import subprocess
from pathlib import Path


def get_active_window_class():
    """Gets the class name of the active window and returns it."""
    
    window_id = subprocess.check_output(['xdotool', 'getactivewindow']).strip()
    wm_class = subprocess.check_output(['xprop', '-id', window_id, 'WM_CLASS'])
    wm_class = wm_class.decode()

    start = wm_class.find('=') + 2
    wm_class_str = wm_class[start:].strip()

    if len(wm_class_str) >= 2:
        return wm_class_str[1]

    return None



def main():
    
    # Temp file
    home_dir = os.path.expanduser("~")
    temp_name = "auto_record_window_script.txt"
    temp_path = os.path.join(home_dir, temp_name)

    

    # Write text to file
    with open(temp_path, 'w') as f:
        f.write("This is a manually created temp file.")


    # Clear temp file
    # os.remove(temp_path)

    while True:

        print(get_active_window_class())
        time.sleep(0.1)


if __name__ == "__main__":
    main()



# implement choosing window based on window class via:
# "xprop | grep WM_CLASS"