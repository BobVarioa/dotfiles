import { Socket } from "node:net";
import process from "node:process";
import { spawn, exec } from "node:child_process";

const path = `${process.env.XDG_RUNTIME_DIR}/hypr/${process.env.HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock`
const sock = new Socket();

const knownMonitors = new Set();
const wallpaperInstances = new Map();

const refreshMonitors = (...args) => {
	for (const [monitor, paper] of wallpaperInstances) {
		if (!knownMonitors.has(monitor)) paper.kill("SIGTERM");
	}
	
	for (const monitor of knownMonitors) {
		if (!wallpaperInstances.has(monitor)) {
			const paper = spawn("/usr/local/bin/glpaper", [monitor, "~/.config/hypr/sky.frag", "--fps", "5", "-F", ...args]);	

			paper.on('exit', () => {
				wallpaperInstances.delete(monitor);
			})

			wallpaperInstances.set(monitor, paper);
		}
	}
}

sock.on('data', (data) => {
	const [event, _params] = data.toString().split(">>");
	const params = _params.split(",");
	console.log(event, params);

	switch (event) {
		case "monitoradded":
			knownMonitors.add(params[0]);
			refreshMonitors();
			break;
		
		case "monitorremoved":
			knownMonitors.delete(params[0]);
			refreshMonitors();
			break;

		case "custom":
			if (params[0] === "lock") {
				for (const [monitor, paper] of wallpaperInstances) {
					paper.kill("SIGTERM");
				}

				refreshMonitors("-l", "top");
			} else if (params[0] === "unlock") {
				refreshMontiors();
			}
			
	}
})

sock.connect(path);


const mons = JSON.parse(execSync("hyprctl monitors -j").toString());

for (const m of mons) {
	knownMonitors.add(m.name);
}
