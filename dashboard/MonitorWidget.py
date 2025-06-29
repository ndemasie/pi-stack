from textual.widget import Widget
from textual.reactive import reactive
from textual import events
from textual.widgets import Static
import psutil
import os
import time
import requests
import subprocess
import re

class MonitorWidget(Widget):
    cpu = reactive(0.0)
    mem = reactive(0.0)
    temp = reactive(0.0)
    top_processes = reactive([])
    containers = reactive([])
    websites = reactive([])

    WEBSITE_URLS = [
        "https://lieblinghomecare.com",
        "",  # Spacer
        "https://demasie.com/health",
        "https://nathan.demasie.com/health",
        "https://refer.demasie.com/health",
        "https://habit.demasie.com/health",
        "https://nathan-app-site.demasie.com/health",
        "https://nathan-app-habit-print.demasie.com/health",
        "https://nathan-app-refer-codes.demasie.com/health",
        "https://nathan-edu-i18next-server.demasie.com/health"
    ]

    def on_mount(self):
        self.set_interval(2, self.refresh_data)
        self.refresh_data()

    def refresh_data(self):
        self.cpu = psutil.cpu_percent(interval=None)
        self.mem = psutil.virtual_memory()
        self.temp = self.get_temp()
        # self.top_processes = self.get_top_processes()
        self.containers = self.get_docker_containers()
        self.websites = [(url, self.get_website_status(url)) for url in self.WEBSITE_URLS]
        self.refresh()

    def get_temp(self):
        try:
            temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")
            return float(temp.replace("'C", ""))
        except Exception:
            return 0.0

    # def get_top_processes(self):
    #     try:
    #         procs = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
    #                        key=lambda p: p.info['cpu_percent'], reverse=True)[:3]
    #         return [(p.info['pid'], p.info['name'], p.info['cpu_percent']) for p in procs]
    #     except Exception:
            return []

    def get_docker_containers(self):
        result = []
        try:
            output = subprocess.check_output([
                "docker", "ps", "--format", "{{.ID}}|{{.Names}}|{{.State}}|{{.Status}}"
            ], text=True)
            for line in output.strip().splitlines():
                container_id, name, state, status = line.split("|", 3)
                status_str = re.search(r'\\(([^)]+)\\)', status)
                if status_str:
                    state = status_str.group(1)
                result.append((name, state))
        except Exception:
            pass
        return result

    def get_website_status(self, url):
        try:
            code = requests.head(url, timeout=2).status_code
            if code == 200:
                return "OK"
            else:
                return f"ERR:{code}"
        except Exception:
            return "ERR"

    def render(self):
        lines = []
        lines.append(f"[b]CPU:[/b] [green]{self.cpu:.1f}%[/green]  [b]Mem:[/b] [green]{self.mem.percent:.1f}%[/green] ({self.mem.used / 1024**2:.1f}MB) [b]T:[/b] [green]{self.temp:.1f}C[/green]")
        lines.append("")

        # lines.append("[b]Top Processes:[/b]")
        # for pid, name, cpu in self.top_processes:
        #     lines.append(f"{pid:<6} {name:<20} {cpu:>5.1f}%")
        # lines.append("")

        lines.append(f"[b]{'Website'.rjust(33):<34}{'Status':<6}[/b]")
        for url, status in self.websites:
            name = url.replace("https://", "").replace("/health", "")
            if not name.strip():
                lines.append("")
                continue
            lines.append(f"{name[-33:]:<34} [on green]{status[:6]:<6}[/on green]")
        lines.append("")

        lines.append(f"[b]{'Container':<32}{'Status':<8}[/b]")
        for name, state in self.containers:
            lines.append(f"{name[:31]:<32} [green]{state[:8]:<8}[/green]")
        return "\n".join(lines)
