import curses
import psutil
from typing import List, Any

class ProcessWidget:
    def __init__(self) -> None:
        self.process_cache: List[Any] = []
        self.process_cache_expiry: int = 5 # Seconds
        self.process_update_offset: int = 0 # Seconds - Time offset to avoid spikes
        self.process_update_time: float = 0

    def update_cache(self, time: float) -> None:
        if time - self.process_update_offset - self.process_update_time >= self.process_cache_expiry:
            self.process_update_time = time
            self.process_cache = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                                       key=lambda p: p.info['cpu_percent'], reverse=True)[:3]

    def draw(self, stdscr: Any, row: int) -> int:
        stdscr.addstr(row, 0, f"{'PID':<9}{'Name':<25}{'CPU %':<8}", curses.A_BOLD)

        for i, p in enumerate(self.process_cache):
            stdscr.addstr(row + 1, 0, f"{p.info['pid']:<9}{p.info['name'][:24]:<25}{p.info['cpu_percent']:<8.2f}")
            row += 1

        return row + 2
