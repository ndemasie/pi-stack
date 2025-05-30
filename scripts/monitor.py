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

def get_website_status(url):
    try:
        return requests.head(url, timeout=5).status_code
    except requests.RequestException:
        return 400

def get_website_status_display(status_code):
    if status_code == 0:
        text = "UKN".center(6)
        color = curses.color_pair(4) | curses.A_REVERSE
    elif status_code == 200:
        text = "OK".center(6)
        color = curses.color_pair(1) | curses.A_REVERSE
    else:
        text = "ERROR".center(6)
        color = curses.color_pair(6) | curses.A_REVERSE

    return text, color

def draw_screen(stdscr):
    setup_curses()

    process_cache = []
    process_cache_expiry = 5 # Seconds
    process_update_offset = 0 # Seconds - Time offset to avoid spikes
    process_update_time = 0

    docker_cache = []
    docker_cache_expiry = 10 # Seconds
    docker_update_offset = 2 # Seconds - Time offset to avoid spikes
    docker_update_time = 0

    website_cache = {
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
    website_keys = list(website_cache.keys())
    website_index = 0

    while True:
        current_time = time.time()

        # CPU Usage
        cpu_usage = psutil.cpu_percent(interval=1)
        cpu_color = curses.color_pair(1)
        if cpu_usage > 30:
            cpu_color = curses.color_pair(2)
        elif cpu_usage > 50:
            cpu_color = curses.color_pair(6)
        elif cpu_usage > 70:
            cpu_color = curses.color_pair(6) | curses.A_REVERSE

        # Memory
        memory = psutil.virtual_memory()
        memory_color = curses.color_pair(1)
        if memory.percent > 30:
            memory_color = curses.color_pair(2)
        elif memory.percent > 50:
            memory_color = curses.color_pair(6)
        elif memory.percent > 70:
            memory_color = curses.color_pair(6) | curses.A_REVERSE

        # Temperature
        temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")
        # TODO: Fix
        # temp_num = float(temp)  # Attempt to convert temp to a float
        temp_num = 0
        temp_color = curses.color_pair(1)
        if temp_num > 55:
            temp_color = curses.color_pair(2)
        elif temp_num > 60:
            temp_color = curses.color_pair(6)
        elif temp_num > 64:
            temp_color = curses.color_pair(6) | curses.A_REVERSE

        # Top Processes
        if current_time - process_update_offset - process_update_time >= process_cache_expiry:
            process_update_time = current_time
            process_cache = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                                       key=lambda p: p.info['cpu_percent'], reverse=True)[:5]

        # Docker Containers
        if current_time - docker_update_offset - docker_update_time >= docker_cache_expiry:
            docker_update_time = current_time
            docker_cache = [(c.short_id, c.name, c.status) for c in docker.from_env().containers.list()]

        # Website Status - Rolling Updates
        website_url = website_keys[website_index]
        if website_url.strip():
            website_cache[website_url] = get_website_status(website_url)

        website_index = (website_index + 1) % len(website_keys)

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

        stdscr.addstr(15, 0, "Website".rjust(46), curses.A_BOLD)
        stdscr.addstr(15, 50, "Status")
        for i, (website_url, status_code) in enumerate(website_cache.items()):
            if not website_url.strip():
                continue

            display_url = website_url.replace("https://", "").replace("/health", "").rjust(46)
            text, color = get_website_status_display(status_code)
            stdscr.addstr(16 + i, 0, f"{display_url:<30}")
            stdscr.addstr(16 + i, 50, f"{text}", color)

        stdscr.addstr(28, 0, "Docker Containers:", curses.A_BOLD)
        stdscr.addstr(29, 0, f"{'ID':<15}{'Name':<35}{'Status':<10}")
        for i, (short_id, name, status) in enumerate(docker_cache):
            status_color = curses.color_pair(1) if status == "running" else curses.color_pair(2)
            stdscr.addstr(30 + i, 0, f"{short_id:<15}")
            stdscr.addstr(30 + i, 15, f"{name:<35}")
            stdscr.addstr(30 + i, 50, f"{status:<10}", status_color)

        stdscr.refresh()
        time.sleep(1)  # Adjust refresh rate

curses.wrapper(draw_screen)
