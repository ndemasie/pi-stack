import curses
import psutil
import os
from typing import Any

class HardwareWidget:
    def __init__(self, stdscr) -> None:
        self.stdscr = stdscr
        self.cpu_usage: float = 0
        self.memory: Any = None
        self.temp: str = ""
        self.temp_num: float = 0

    @staticmethod
    def get_cpu_display(cpu_usage: float) -> int:
        if cpu_usage > 70:
            return curses.color_pair(6) | curses.A_REVERSE
        elif cpu_usage > 50:
            return curses.color_pair(6)
        elif cpu_usage > 30:
            return curses.color_pair(2)
        else:
            return curses.color_pair(1)

    @staticmethod
    def get_memory_display(memory_percent: float) -> int:
        if memory_percent > 70:
            return curses.color_pair(6) | curses.A_REVERSE
        elif memory_percent > 50:
            return curses.color_pair(6)
        elif memory_percent > 30:
            return curses.color_pair(2)
        else:
            return curses.color_pair(1)

    @staticmethod
    def get_temp_display(temp_num: float) -> int:
        if temp_num > 64:
            return curses.color_pair(6) | curses.A_REVERSE
        elif temp_num > 60:
            return curses.color_pair(6)
        elif temp_num > 55:
            return curses.color_pair(2)
        else:
            return curses.color_pair(1)

    def update(self) -> None:
        self.cpu_usage = psutil.cpu_percent(interval=1)
        self.memory = psutil.virtual_memory()
        self.temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")
        try:
            self.temp_num = float(self.temp.replace("'C", "").replace("C", ""))
        except Exception:
            self.temp_num = 0

    def draw(self, row: int) -> int:
        cpu_color = self.get_cpu_display(self.cpu_usage)
        memory_color = self.get_memory_display(self.memory.percent)
        temp_color = self.get_temp_display(self.temp_num)

        self.stdscr.addstr(row, 0, "CPU:", curses.A_BOLD)
        self.stdscr.addstr(row, 4, f"{self.cpu_usage:.2f}%", cpu_color)
        self.stdscr.addstr(row, 11, "Mem:", curses.A_BOLD)
        self.stdscr.addstr(row, 15, f"{self.memory.percent}%", memory_color)
        self.stdscr.addstr(row, 21, f"({self.memory.used / 1024**2:.1f}MB)")
        self.stdscr.addstr(row, 32, "T:", curses.A_BOLD)
        self.stdscr.addstr(row, 34, self.temp, temp_color)

        return row + 2
