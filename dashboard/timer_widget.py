import curses
import time
from typing import Optional
from enum import Enum

class TimerButton(Enum):
    START_STOP = 0
    RESET = 1

class TimerWidget:
    def __init__(self, stdscr: 'curses._CursesWindow') -> None:
        self.stdscr: 'curses._CursesWindow' = stdscr

        self.button: TimerButton = TimerButton.START_STOP
        self.running: bool = False
        self.start_time: Optional[float] = None
        self.elapsed: float = 0
        self.update()

    def handle_input(self, key: int) -> None:
        if key in (curses.KEY_STAB, curses.KEY_BTAB, 9):
            self.button = TimerButton((self.button.value + 1) % 2)

        elif key in (curses.KEY_ENTER, 10, 13):
            if self.button == TimerButton.START_STOP and not self.running:
                self.running = True
                self.start_time = time.time()

            elif self.button == TimerButton.START_STOP and self.running:
                self.running = False
                self.elapsed += time.time() - self.start_time
                self.start_time = None

            elif self.button == TimerButton.RESET:
                self.running = False
                self.elapsed = 0
                self.start_time = None
                self.button = TimerButton.START_STOP

    def update(self, time: float = time.time()) -> None:
        if self.running and self.start_time is not None:
            self.elapsed += time - self.start_time
            self.start_time = time


    def draw(self, row: int) -> None:
        # Start/Stop
        attr = curses.A_REVERSE if self.button == TimerButton.START_STOP else curses.A_NORMAL
        text = " [ Start ] " if not self.running else " [ Stop ] "
        self.stdscr.addstr(row, 3, f"{text:<11}", attr)

        # Timer
        hours: int = int(self.elapsed // 3600)
        minutes: int = int((self.elapsed % 3600) // 60)
        seconds: int = int(self.elapsed % 60)
        self.stdscr.addstr(row, 16, f"{hours:02}:{minutes:02}:{seconds:02}", curses.A_BOLD)

        # Reset
        attr = curses.A_REVERSE if self.button == TimerButton.RESET else curses.A_NORMAL
        text = " [ Reset ] "
        self.stdscr.addstr(row, 26, f"{text:<11}", attr)

        return row + 2