import curses
import psutil
import docker
import os
import time
import requests

def setup_curses():
    curses.curs_set(0)  # Hide cursor
    curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
    curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)
    curses.init_pair(5, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
    curses.init_pair(6, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(7, curses.COLOR_WHITE, curses.COLOR_BLACK)

def check_website_status(url):
    try:
        return requests.get(url, timeout=5).status_code
    except requests.RequestException:
        return 400

def draw_screen(stdscr):
    setup_curses()

    process_cache_expiry = 5 # Seconds
    process_last_check = 0
    process_cache = []

    website_cache_expiry = 10 # Seconds
    website_last_check = 0
    website_cache = {}
    website_list = [
        "https://www.demasie.com/health",
        "https://nathan.demasie.com/health",
        "https://habit.demasie.com/health",
        "https://refer.demasie.com/health"
    ]

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, "=== Raspberry Pi Status Screen ===", curses.A_BOLD)

        # CPU Usage
        cpu_usage = psutil.cpu_percent(interval=1)

        stdscr.addstr(2, 0, "CPU:", curses.A_BOLD)
        stdscr.addstr(2, 15, f"{cpu_usage:.2f}%")

        # Memory
        memory = psutil.virtual_memory()
        memory_info = f"{memory.used / 1024**2:.2f} MB ({memory.percent}%)"

        stdscr.addstr(3, 0, "Memory:", curses.A_BOLD)
        stdscr.addstr(3, 15, memory_info)

        # Temperature
        temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")

        stdscr.addstr(4, 0, "Temperature:", curses.A_BOLD)
        stdscr.addstr(4, 15, temp)

        # Top Processes
        stdscr.addstr(6, 0, "Top Processes:", curses.A_BOLD)
        stdscr.addstr(7, 0, f"{'PID':<10}{'Name':<25}{'CPU%':<10}")

        current_time = time.time()
        if current_time - process_last_check >= process_cache_expiry:
            process_cache = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                                       key=lambda p: p.info['cpu_percent'], reverse=True)[:5]
            process_last_check = current_time

        for i, p in enumerate(process_cache):
            pid = p.info['pid']
            name = p.info['name'][:24]  # Truncate name to fit the column
            cpu_percent = p.info['cpu_percent']
            stdscr.addstr(8 + i, 0, f"{pid:<10}{name:<25}{cpu_percent:<10.2f}")

        # Docker Containers
        stdscr.addstr(14, 0, "Docker Containers:", curses.A_BOLD)
        stdscr.addstr(15, 0, f"{'ID':<15}{'Name':<25}{'Status':<10}")

        client = docker.from_env()
        containers = [(c.id[:12], c.name, c.status) for c in client.containers.list()]

        for i, (container_id, name, status) in enumerate(containers):
            status_color = curses.color_pair(1) if status == "running" else curses.color_pair(2)

            stdscr.addstr(16 + i, 0, f"{container_id:<15}")
            stdscr.addstr(16 + i, 15, f"{name:<25}")
            stdscr.addstr(16 + i, 40, f"{status:<10}", status_color)

        # Website Status
        stdscr.addstr(23, 0, "Website Status:", curses.A_BOLD)
        if current_time - website_last_check >= website_cache_expiry:
            website_cache = {url: check_website_status(url) for url in website_list}
            website_last_check = current_time

        for i, website_url in enumerate(website_list):
            status_code = website_cache.get(website_url, 400)
            status_text = " OK ".center(6) if status_code == 200 else " ERROR ".center(6)
            status_color = curses.color_pair(1) if status_code == 200 else curses.color_pair(6)

            stdscr.addstr(24 + i, 0, f"{website_url:<30}", curses.color_pair(4))
            stdscr.addstr(24 + i, 40, f"{status_text}", status_color | curses.A_REVERSE)

        stdscr.refresh()
        time.sleep(1)  # Adjust refresh rate

curses.wrapper(draw_screen)
