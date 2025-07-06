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
        self.row: Optional[int] = None
        self.button: TimerButton = TimerButton.START_STOP
        self.is_running: bool = False
        self.start_time: Optional[float] = None
        self.elapsed: float = 0
        self.flash_until: Optional[float] = None
        self.flash_button: Optional[TimerButton] = None
        self.update()

    def handle_input(self, key: int, time: float = time.time()) -> None:
        if key in (curses.KEY_STAB, curses.KEY_BTAB, 9):
            self.button = TimerButton((self.button.value + 1) % 2)
        elif key in (curses.KEY_ENTER, 10, 13):
            if self.button == TimerButton.START_STOP and not self.is_running:
                self.is_running = True
                self.start_time = time
                self.flash_until = time + 0.2
                self.flash_button = TimerButton.START_STOP

            elif self.button == TimerButton.START_STOP and self.is_running:
                self.is_running = False
                self.elapsed += time - self.start_time
                self.start_time = None
                self.flash_until = time + 0.2
                self.flash_button = TimerButton.START_STOP

            elif self.button == TimerButton.RESET:
                self.is_running = False
                self.elapsed = 0
                self.start_time = None
                self.flash_until = time + 0.2
                self.flash_button = TimerButton.RESET

    def update(self, time: float = time.time()) -> None:
        if self.is_running and self.start_time is not None:
            self.elapsed += time - self.start_time
            self.start_time = time

    def update_flash(self):
        if self.flash_until and time.time() >= self.flash_until:
            self.flash_until = None
            self.flash_button = None

    def get_flash_attr(self, button: TimerButton) -> int:
        now = time.time()
        if self.flash_until and self.flash_button == button and now < self.flash_until:
            return curses.A_BLINK | curses.A_BOLD
        return 0

    def draw(self, row: Optional[int] = None) -> int:
        if row is None:
            row = self.row if self.row is not None else 0
        self.row = row

        # Start/Stop
        attr = curses.A_REVERSE if self.button == TimerButton.START_STOP else curses.A_NORMAL
        attr |= self.get_flash_attr(TimerButton.START_STOP)
        text = " [ Start ] " if not self.is_running else " [ Stop ] "
        self.stdscr.addstr(row, 3, f"{text:<11}", attr)

        # Timer
        hours: int = int(self.elapsed // 3600)
        minutes: int = int((self.elapsed % 3600) // 60)
        seconds: int = int(self.elapsed % 60)
        self.stdscr.addstr(row, 16, f"{hours:02}:{minutes:02}:{seconds:02}", curses.A_BOLD)

        # Reset
        attr = curses.A_REVERSE if self.button == TimerButton.RESET else curses.A_NORMAL
        attr |= self.get_flash_attr(TimerButton.RESET)
        text = " [ Reset ] "
        self.stdscr.addstr(row, 26, f"{text:<11}", attr)

        self.update_flash()
        return row + 2