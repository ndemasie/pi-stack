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
    curses.init_pair(3, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(4, curses.COLOR_BLACK, curses.COLOR_GREEN)
    curses.init_pair(5, curses.COLOR_BLACK, curses.COLOR_YELLOW)
    curses.init_pair(6, curses.COLOR_BLACK, curses.COLOR_RED)

def check_website_status(url):
    try:
        return requests.get(url, timeout=5).status_code
    except requests.RequestException:
        return 200

def draw_screen(stdscr):
    setup_curses()

    # Define a list of websites
    websites = [
        "www.demasie.com/health",
        "nathan.demasie.com/health",
        "habit.demasie.com/health",
        "refer.demasie.com/health"
    ]

    last_process_check = 0
    cached_processes = []

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, "=== Raspberry Pi Status Screen ===", curses.A_BOLD)

        # CPU Usage
        cpu_usage = psutil.cpu_percent(interval=1)
        stdscr.addstr(2, 0, "CPU Usage:", curses.A_BOLD)
        stdscr.addstr(2, 11, f"{cpu_usage:.2f}%")

        # Memory
        memory = psutil.virtual_memory()
        memory_info = f"{memory.used / 1024**2:.2f} MB / {memory.total / 1024**2:.2f} MB ({memory.percent}%)"

        stdscr.addstr(3, 0, "Memory:", curses.A_BOLD)
        stdscr.addstr(3, 8, memory_info)

        # Temperature
        temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")

        stdscr.addstr(4, 0, "Temperature:", curses.A_BOLD)
        stdscr.addstr(4, 12, temp)

        # Top Processes
        stdscr.addstr(6, 0, "Top Processes:", curses.A_BOLD)
        stdscr.addstr(7, 0, f"{'PID':<10}{'Name':<25}{'CPU%':<10}", curses.A_UNDERLINE)

        current_time = time.time()
        if current_time - last_process_check >= 5:
            cached_processes = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                                       key=lambda p: p.info['cpu_percent'], reverse=True)[:5]
            last_process_check = current_time

        for i, p in enumerate(cached_processes):
            pid = p.info['pid']
            name = p.info['name'][:24]  # Truncate name to fit the column
            cpu_percent = p.info['cpu_percent']
            stdscr.addstr(8 + i, 0, f"{pid:<10}{name:<25}{cpu_percent:<10.2f}")

        # Docker Containers
        stdscr.addstr(14, 0, "Docker Containers:", curses.A_BOLD)
        stdscr.addstr(15, 0, f"{'ID':<15}{'Name':<25}{'Status':<10}", curses.A_UNDERLINE)

        client = docker.from_env()
        containers = [(c.id[:12], c.name, c.status) for c in client.containers.list()]

        for i, (container_id, name, status) in enumerate(containers):
            status_color = curses.color_pair(1) if status == "running" else curses.color_pair(2)
            check_mark = "✔" if status == "running" else ""

            stdscr.addstr(16 + i, 0, f"{container_id:<15}")
            stdscr.addstr(16 + i, 15, f"{name:<25}", curses.COLOR_CYAN)
            stdscr.addstr(16 + i, 40, f"{status:<10} {check_mark}", status_color)

        # Website Status
        stdscr.addstr(18, 0, "Website Status:", curses.A_BOLD)
        for i, website_url in enumerate(websites):
            website_status = check_website_status(website_url)
            status_color = curses.color_pair(1) if website_status == "OK" else curses.color_pair(2)
            stdscr.addstr(18 + i, 0, f"{website_url:<30} {website_status}", status_color)

        stdscr.refresh()
        time.sleep(1)  # Adjust refresh rate

curses.wrapper(draw_screen)
