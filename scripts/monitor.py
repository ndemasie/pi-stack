import curses
import psutil
import os
import time
import requests
import subprocess
import re

class MonitorApp:
    def __init__(self, stdscr):
        self.process_cache = []
        self.process_cache_expiry = 5 # Seconds
        self.process_update_offset = 0 # Seconds - Time offset to avoid spikes
        self.process_update_time = 0

        self.container_cache = []
        self.container_cache_expiry = 10 # Seconds
        self.container_update_offset = 2 # Seconds - Time offset to avoid spikes
        self.container_update_time = 0

        self.website_cache = {
            "https://lieblinghomecare.com": 0,
            "": 0,
            "https://demasie.com/health": 0,
            "https://nathan.demasie.com/health": 0,
            "https://refer.demasie.com/health": 0,
            "https://habit.demasie.com/health": 0,
            "https://nathan-app-site.demasie.com/health": 0,
            "https://nathan-app-habit-print.demasie.com/health": 0,
            "https://nathan-app-refer-codes.demasie.com/health": 0,
            "https://nathan-edu-i18next-server.demasie.com/health": 0
        }
        self.website_keys = list(self.website_cache.keys())
        self.website_index = 0

        self.stdscr = stdscr
        self.setup_curses()

    def setup_curses(self):
        curses.curs_set(0)  # Hide cursor
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)
        curses.init_pair(5, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
        curses.init_pair(6, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(7, curses.COLOR_WHITE, curses.COLOR_BLACK)

    @staticmethod
    def get_website_status(url):
        try:
            return requests.head(url, timeout=5).status_code
        except requests.RequestException:
            return 400

    @staticmethod
    def load_docker_cache():
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
                result.append((container_id, name, state))
        except Exception:
            pass
        return result

    @staticmethod
    def get_website_display(status_code):
        if status_code == 200:
            return curses.color_pair(1) | curses.A_REVERSE, "OK".center(6)
        elif status_code == 0:
            return curses.color_pair(4) | curses.A_REVERSE, "UKN".center(6)
        else:
            return curses.color_pair(6) | curses.A_REVERSE, "ERROR".center(6)

    @staticmethod
    def get_container_display(status):
        if status in ("healthy", "running"):
            return curses.color_pair(1)
        elif status == "unhealthy":
            return curses.color_pair(2)
        else:
            return curses.color_pair(6)

    @staticmethod
    def get_cpu_display(cpu_usage):
        if cpu_usage > 70:
            return curses.color_pair(6) | curses.A_REVERSE
        elif cpu_usage > 50:
            return curses.color_pair(6)
        elif cpu_usage > 30:
            return curses.color_pair(2)
        else:
            return curses.color_pair(1)

    @staticmethod
    def get_memory_display(memory_percent):
        if memory_percent > 70:
            return curses.color_pair(6) | curses.A_REVERSE
        elif memory_percent > 50:
            return curses.color_pair(6)
        elif memory_percent > 30:
            return curses.color_pair(2)
        else:
            return curses.color_pair(1)

    @staticmethod
    def get_temp_display(temp_num):
        if temp_num > 64:
            return curses.color_pair(6) | curses.A_REVERSE
        elif temp_num > 60:
            return curses.color_pair(6)
        elif temp_num > 55:
            return curses.color_pair(2)
        else:
            return curses.color_pair(1)

    def run(self):
        while True:
            current_time = time.time()

            # CPU Usage
            cpu_usage = psutil.cpu_percent(interval=1)
            cpu_color = self.get_cpu_display(cpu_usage)

            # Memory
            memory = psutil.virtual_memory()
            memory_color = self.get_memory_display(memory.percent)

            # Temperature
            temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")
            temp_num = 0
            temp_color = self.get_temp_display(temp_num)

            # Top Processes
            if current_time - self.process_update_offset - self.process_update_time >= self.process_cache_expiry:
                self.process_update_time = current_time
                self.process_cache = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                                           key=lambda p: p.info['cpu_percent'], reverse=True)[:3]

            # Containers
            if current_time - self.container_update_offset - self.container_update_time >= self.container_cache_expiry:
                self.container_update_time = current_time
                self.container_cache = self.load_docker_cache()

            # Websites
            website_url = self.website_keys[self.website_index]
            if website_url.strip():
                self.website_cache[website_url] = self.get_website_status(website_url)
            self.website_index = (self.website_index + 1) % len(self.website_keys)

            # Draw Screen
            self.stdscr.clear()
            self.stdscr.addstr(0, 0, "CPU:", curses.A_BOLD)
            self.stdscr.addstr(0, 4, f"{cpu_usage:.2f}%", cpu_color)
            self.stdscr.addstr(0, 11, "Mem:", curses.A_BOLD)
            self.stdscr.addstr(0, 15, f"{memory.percent}%", memory_color)
            self.stdscr.addstr(0, 21, f"({memory.used / 1024**2:.1f}MB)")
            self.stdscr.addstr(0, 32, "T:", curses.A_BOLD)
            self.stdscr.addstr(0, 34, temp, temp_color)

            self.stdscr.addstr(2, 0, f"{'PID':<9}{'Name':<25}{'CPU %':<8}", curses.A_BOLD)
            for i, p in enumerate(self.process_cache):
                self.stdscr.addstr(2 + 1 + i, 0, f"{p.info['pid']:<9}{p.info['name'][:24]:<25}{p.info['cpu_percent']:<8.2f}")

            self.stdscr.addstr(7, 0, f"{'Website'.rjust(33):<34}{'Status':<6}", curses.A_BOLD)
            for i, (website_url, status_code) in enumerate(self.website_cache.items()):
                if not website_url.strip():
                    continue
                display_url = website_url.replace("https://", "").replace("/health", "").rjust(33)
                color, text = self.get_website_display(status_code)
                self.stdscr.addstr(7 + 1 + i, 0, f"{display_url[-33:]:<34}")
                self.stdscr.addstr(7 + 1 + i, 34, f"{text[:6]}", color)

            self.stdscr.addstr(19, 0, f"{'Container':<32}{'Status':<8}", curses.A_BOLD)
            for i, (container_id, name, status) in enumerate(sorted(self.container_cache, key=lambda x: x[1])):
                color = self.get_container_display(status)
                self.stdscr.addstr(19 + 1 + i, 0, f"{name[:31]:<32}")
                self.stdscr.addstr(19 + 1 + i, 32, f"{status[:8]}", color)

            self.stdscr.refresh()
            time.sleep(1)  # Adjust refresh rate

def main(stdscr):
    app = MonitorApp(stdscr)
    app.run()

if __name__ == "__main__":
    curses.wrapper(main)
