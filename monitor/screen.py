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
    process_update_time = 0
    process_cache = []

    website_cache_expiry = 10 # Seconds
    website_update_time = 0
    website_cache = {}
    website_list = [
        "https://www.demasie.com/health",
        "https://nathan.demasie.com/health",
        "https://habit.demasie.com/health",
        "https://refer.demasie.com/health"
    ]

    while True:
        current_time = time.time()

        # CPU Usage
        cpu_usage = psutil.cpu_percent(interval=1)
        cpu_color
        if cpu_usage < 30:
            cpu_color = curses.color_pair(1)
        elif cpu_usage < 50:
            cpu_color = curses.color_pair(2)
        elif cpu_usage < 70:
            cpu_color = curses.color_pair(6)
        else:
            cpu_color = curses.color_pair(6) | curses.A_REVERSE

        # Memory
        memory = psutil.virtual_memory()
        memory_color
        if memory.percent < 30:
            memory_color = curses.color_pair(1)
        elif memory.percent < 50:
            memory_color = curses.color_pair(2)
        elif memory.percent < 70:
            memory_color = curses.color_pair(6)
        else:
            memory_color = curses.color_pair(6) | curses.A_REVERSE

        # Temperature
        temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")
        temp_num = float(temp)  # Attempt to convert temp to a float
        temp_color
        if temp_num < 55:
            temp_color = curses.color_pair(1)
        elif temp_num < 60:
            temp_color = curses.color_pair(2)
        elif temp_num < 64:
            temp_color = curses.color_pair(6)
        else:
            temp_color = curses.color_pair(6) | curses.A_REVERSE

        # Top Processes
        if current_time - process_update_time >= process_cache_expiry:
            process_update_time = current_time
            process_cache = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                                       key=lambda p: p.info['cpu_percent'], reverse=True)[:5]

        # Docker Containers
        docker_containers = [(c.id[:12], c.name, c.status) for c in docker.from_env().containers.list()]

        # Website Status
        if current_time - website_update_time >= website_cache_expiry:
            website_update_time = current_time
            website_cache = {url: check_website_status(url) for url in website_list}

        # Draw Screen
        stdscr.clear()
        stdscr.addstr(0, 0, "=== Raspberry Pi Status Screen ===", curses.A_BOLD)

        stdscr.addstr(2, 0, "CPU:", curses.A_BOLD)
        stdscr.addstr(2, 15, f"{cpu_usage:.2f}%", cpu_color)
        stdscr.addstr(3, 0, "Memory:", curses.A_BOLD)
        stdscr.addstr(3, 15, f"{memory.percent}%", memory_color)
        stdscr.addstr(3, 21, f"({memory.used / 1024**2:.2f} MB)")
        stdscr.addstr(4, 0, "Temperature:", curses.A_BOLD)
        stdscr.addstr(4, 15, temp, temp_color)

        stdscr.addstr(6, 0, "Top Processes:", curses.A_BOLD)
        stdscr.addstr(7, 0, f"{'PID':<10}{'Name':<25}{'CPU%':<10}")
        for i, p in enumerate(process_cache):
            stdscr.addstr(8 + i, 0, f"{p.info['pid']:<10}{p.info['name'][:24]:<25}{p.info['cpu_percent']:<10.2f}")

        stdscr.addstr(14, 0, "Docker Containers:", curses.A_BOLD)
        stdscr.addstr(15, 0, f"{'ID':<15}{'Name':<25}{'Status':<10}")
        for i, (container_id, name, status) in enumerate(docker_containers):
            status_color = curses.color_pair(1) if status == "running" else curses.color_pair(2)
            stdscr.addstr(16 + i, 0, f"{container_id:<15}")
            stdscr.addstr(16 + i, 15, f"{name:<25}")
            stdscr.addstr(16 + i, 50, f"{status:<10}", status_color)

        stdscr.addstr(23, 0, "Website Status:", curses.A_BOLD)
        for i, website_url in enumerate(website_list):
            status_code = website_cache.get(website_url, 400)
            status_text = " OK ".center(6) if status_code == 200 else " ERROR ".center(6)
            status_color = curses.color_pair(1) if status_code == 200 else curses.color_pair(6)
            stdscr.addstr(24 + i, 0, f"{website_url:<30}", curses.color_pair(4))
            stdscr.addstr(24 + i, 50, f"{status_text}", status_color | curses.A_REVERSE)

        stdscr.refresh()
        time.sleep(1)  # Adjust refresh rate

curses.wrapper(draw_screen)
