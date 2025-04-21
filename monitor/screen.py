import curses
import psutil
import docker
import os
import time

def draw_screen(stdscr):
    curses.curs_set(0)  # Hide cursor
    curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)

    last_process_check = 0
    cached_processes = []

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, "=== Raspberry Pi Status Screen ===", curses.A_BOLD)

        # Memory
        memory = psutil.virtual_memory()
        memory_info = f"{memory.used / 1024**2:.2f} MB / {memory.total / 1024**2:.2f} MB ({memory.percent}%)"

        stdscr.addstr(2, 0, "Memory:", curses.A_BOLD)
        stdscr.addstr(2, 8, memory_info)

        # Temperature
        temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")

        stdscr.addstr(3, 0, "Temperature:", curses.A_BOLD)
        stdscr.addstr(3, 12, temp)

        # Top Processes
        stdscr.addstr(5, 0, "Top Processes:", curses.A_BOLD)
        stdscr.addstr(6, 0, f"{'PID':<10}{'Name':<25}{'CPU%':<10}", curses.A_UNDERLINE)

        current_time = time.time()
        if current_time - last_process_check >= 5:
            cached_processes = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                                       key=lambda p: p.info['cpu_percent'], reverse=True)[:5]
            last_process_check = current_time

        for i, p in enumerate(cached_processes):
            pid = p.info['pid']
            name = p.info['name'][:24]  # Truncate name to fit the column
            cpu_percent = p.info['cpu_percent']
            stdscr.addstr(7 + i, 0, f"{pid:<10}{name:<25}{cpu_percent:<10.2f}")

        # Docker Containers
        stdscr.addstr(13, 0, "Docker Containers:", curses.A_BOLD)
        stdscr.addstr(14, 0, f"{'ID':<15}{'Name':<25}{'Status':<10}", curses.A_BOLD)

        client = docker.from_env()
        containers = [(c.id[:12], c.name, c.status) for c in client.containers.list()]

        for i, (container_id, name, status) in enumerate(containers):
            status_color = curses.color_pair(1) if status == "running" else curses.color_pair(2)

            stdscr.addstr(15 + i, 0, f"{container_id:<15}")
            stdscr.addstr(15 + i, 15, f"{name:<25}", curses.COLOR_CYAN)
            stdscr.addstr(15 + i, 40, f"{status:<10}", status_color)

        stdscr.refresh()
        time.sleep(1)  # Adjust refresh rate

curses.wrapper(draw_screen)
