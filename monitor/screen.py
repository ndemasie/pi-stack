import curses
import psutil
import docker
import os
import time

def draw_screen(stdscr):
    curses.curs_set(0)  # Hide cursor
    curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)

    while True:
        stdscr.clear()
        stdscr.addstr(0, 0, "=== Raspberry Pi Status Screen ===", curses.A_BOLD)

        # Memory
        memory = psutil.virtual_memory()
        memory_info = f"Memory: {memory.used / 1024**2:.2f} MB / {memory.total / 1024**2:.2f} MB ({memory.percent}%)"

        stdscr.addstr(2, 0, memory_info)

        # Temperature
        temp = os.popen("vcgencmd measure_temp").readline().strip()

        stdscr.addstr(3, 0, f"Temperature: {temp}")

        # Top Processes
        stdscr.addstr(5, 0, "Top Processes:")
        stdscr.addstr(6, 0, f"{'PID':<10}{'Name':<25}{'CPU%':<10}", curses.A_UNDERLINE)
        processes = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                            key=lambda p: p.info['cpu_percent'], reverse=True)[:5]

        for i, p in enumerate(processes):
            pid = p.info['pid']
            name = p.info['name'][:24]  # Truncate name to fit the column
            cpu_percent = p.info['cpu_percent']
            stdscr.addstr(7 + i, 0, f"{pid:<10}{name:<25}{cpu_percent:<10.2f}")

        # Docker Containers
        stdscr.addstr(13, 0, "Docker Containers:")
        stdscr.addstr(14, 0, f"{'ID':<15}{'Name':<25}{'Status':<10}", curses.A_UNDERLINE)

        client = docker.from_env()
        containers = [(c.id[:12], c.name, c.status) for c in client.containers.list()]

        for i, (container_id, name, status) in enumerate(containers):
            color = curses.color_pair(1) if status == "running" else curses.color_pair(2)
            stdscr.addstr(15 + i, 0, f"{container_id:<15}{name:<25}")
            stdscr.addstr(15 + i, 40, f"{status:<10}", color)

        stdscr.refresh()
        time.sleep(1)  # Adjust refresh rate

curses.wrapper(draw_screen)
