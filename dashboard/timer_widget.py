import curses
import time
from typing import Optional, Tuple

class TimerWidget:
    def __init__(self, stdscr: 'curses._CursesWindow') -> None:
        self.stdscr: 'curses._CursesWindow' = stdscr

        self.row = None
        self.running: bool = False
        self.start_time: Optional[float] = None
        self.elapsed: float = 0
        self.selected_button: int = 0  # 0: Start/Stop, 1: Reset

    def handle_input(self, key: int) -> None:
        if key in (curses.KEY_STAB, curses.KEY_BTAB, 9):
            self.selected_button = (self.selected_button + 1) % 2
        elif key in (curses.KEY_ENTER, 10, 13):
            if self.selected_button == 0 and not self.running:
                self.running = True
                self.start_time = time.time()
            elif self.selected_button == 0 and self.running:
                self.running = False
                self.elapsed += time.time() - self.start_time
                self.start_time = None
            elif self.selected_button == 1:
                self.running = False
                self.elapsed = 0
                self.start_time = None
                self.selected_button = 0

    def update(self, current_time: int) -> None:
        if self.running and self.start_time is not None:
            self.elapsed += current_time - self.start_time
            self.start_time = current_time


    def draw(self, row: int) -> None:
        # Start/Stop
        attr = curses.color_pair(8) if self.selected_button == 0 else curses.color_pair(7)
        text = " [ Start ] " if not self.running else " [ Stop ] "
        self.stdscr.addstr(row, 0, f"{text:<12}", attr)

        # Reset
        attr = curses.color_pair(8) if self.selected_button == 1 else curses.color_pair(7)
        self.stdscr.addstr(row, 12, f"{' [ Reset ] ':<12}", attr)

        # Timer
        hours: int = int(self.elapsed // 3600)
        minutes: int = int((self.elapsed % 3600) // 60)
        seconds: int = int(self.elapsed % 60)
        self.stdscr.addstr(row, 24, f"{hours:02}:{minutes:02}:{seconds:02}", curses.A_BOLD)

        return row + 2