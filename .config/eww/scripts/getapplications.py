#!/usr/bin/python3

import sys, os, subprocess, re, gi, json
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

def run(str):
    return subprocess.run(str,stdout=subprocess.PIPE, stderr=subprocess.STDOUT,check=False,text=True, shell=True).stdout

def thing(s):
    d = { "wid": s[0], "id": s[2].split(".")[0], "title": " ".join(s[4:]) }
    desktopFile = run(['find "/usr/share/applications/" ${HOME}/.local/share/applications/ -iname "*'+ d["id"]+'*"']).strip()

    if desktopFile:
        f = open(desktopFile, "r")
        lines = f.readlines()[1:]
        props = {}

        for l in lines:
            l = l.strip()
            if l and l[0] == "[":
                break
            spl = l.split("=")
            if len(spl) != 2: continue
            props[spl[0]] = spl[1]

        if props.get("NoDisplay") == "true": return None

        if props.get("Name"):
            d["name"] = props["Name"]

        if props.get("Icon"):
            icon_name = props["Icon"]
            icon_theme = Gtk.IconTheme.get_default()
            icon = icon_theme.lookup_icon(icon_name.strip(), 48, 0)
            if icon:
                d["icon"] = icon.get_filename()
    else:
        return None
    return d

wmctrl = run(["wmctrl -lx"])
windows = list(filter(lambda ele: ele != None, [thing(re.split(r'\s+', f)) for f in wmctrl.split("\n") if len(f) > 1]))
print(json.dumps(windows))
