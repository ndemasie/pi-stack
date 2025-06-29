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

    def draw(self, row: int) -> None:
        # Start/Stop
        attr = curses.color_pair(8) if self.selected_button == 0 else curses.color_pair(7)
        text = " [ Start ] " if not self.running else " [ Stop ] "
        self.stdscr.addstr(row + 0, 0, " " * 11, attr)
        self.stdscr.addstr(row + 1, 0, text, attr)
        self.stdscr.addstr(row + 2, 0, " " * 11, attr)

        # Reset
        attr = curses.color_pair(8) if self.selected_button == 1 else curses.color_pair(7)
        self.stdscr.addstr(row + 0, 12, " " * 11, attr)
        self.stdscr.addstr(row + 1, 12, f" [ Reset ] ", attr)
        self.stdscr.addstr(row + 2, 12, " " * 11, attr)

        # Timer
        hours: int = int(self.elapsed // 3600)
        minutes: int = int((self.elapsed % 3600) // 60)
        seconds: int = int(self.elapsed % 60)
        self.stdscr.addstr(row + 0, 24, " " * 11)
        self.stdscr.addstr(row + 1, 24, f"{hours:2.2f}:{minutes:2.2f}:{seconds:2.2f}", curses.A_BOLD)
        self.stdscr.addstr(row + 2, 24, " " * 11)

    def run(self, row: int) -> None:
        if self.running:
            self.elapsed += time.time() - self.start_time  # type: ignore

        while True:
            self.draw(row)
            key: int = self.stdscr.getch()

            if key in (curses.KEY_TAB, 9):
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

            self.stdscr.refresh()
            time.sleep(0.05)