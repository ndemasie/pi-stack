import curses
import psutil
import docker
import os
import time

def draw_screen(stdscr):
  curses.curs_set(0)  # Hide cursor
  while True:
    stdscr.clear()
    stdscr.addstr(0, 0, "=== Raspberry Pi Status Screen ===", curses.A_BOLD)

    # Memory
    memory = psutil.virtual_memory()
    memory_info = f"Memory: {memory.used / 1024**2:.2f} MB / {memory.total / 1024**2:.2f} MB"

    stdscr.addstr(2, 0, memory_info)

    # Temperature
    temp = os.popen("vcgencmd measure_temp").readline().strip()

    stdscr.addstr(3, 0, f"Temperature: {temp}")

    # Top Processes
    stdscr.addstr(5, 0, "Top Processes (PID Name CPU%):")
    processes = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                        key=lambda p: p.info['cpu_percent'], reverse=True)[:5]

    for i, p in enumerate(processes):
      stdscr.addstr(6 + i, 0, f"{p.info['pid']} {p.info['name']} {p.info['cpu_percent']}%")

    # Docker Containers
    stdscr.addstr(12, 0, "Docker Containers (ID Name Status):")
    client = docker.from_env()
    containers = [(c.id[:12], c.name, c.status) for c in client.containers.list()]

    for i, c in enumerate(containers):
        stdscr.addstr(13 + i, 0, f"{c[0]} {c[1]} {c[2]}")

    stdscr.refresh()
    time.sleep(1)  # Adjust refresh rate

curses.wrapper(draw_screen)
