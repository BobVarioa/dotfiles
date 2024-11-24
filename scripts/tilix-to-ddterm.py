# Save this file as tilix-to-ddterm.py!
# Run it with "python3 tilix-to-ddterm.py <name of your tilix color JSON file>".

from pathlib import Path
from pprint import pprint
import json
import re
import subprocess
import sys


if len(sys.argv) < 2:
    print("Please provide a Tilix JSON color scheme filename.")
    exit(1)

tilix_file = Path(sys.argv[1])
if not tilix_file.is_file():
    print("Invalid filename.")
    exit(1)

out_palette = []
with tilix_file.open("rt", encoding="utf-8") as f:
    tilix_data = json.loads(f.read())
    if not "palette" in tilix_data:
        print("Invalid JSON file. Not a Tilix color scheme.")
        exit(1)
    
    in_palette = tilix_data["palette"]
    
    for color in in_palette:
        m = re.match(r"^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$", color.lower(), re.IGNORECASE)
        if not m:
            print(f"Invalid color: {color}. Exiting...")
            exit(1)
        
        out_palette.append(f"rgb(0x{m.group(1)}, 0x{m.group(2)}, 0x{m.group(3)})")

if len(out_palette) != 16:
    print(f"Wrong color amount in JSON file. Expected 16, found {len(out_palette)}. Exiting...")
    exit(1)

out_palette_arg = "['" + "', '".join(out_palette) + "']"
print(f"Writing {tilix_file} palette to ddterm's dconf storage: {out_palette_arg}.")
subprocess.run(["dconf", "write", "/com/github/amezin/ddterm/palette", out_palette_arg], shell=False, check=True)
