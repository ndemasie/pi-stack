import curses
import time
from container_widget import ContainerWidget
from website_widget import WebsiteWidget
from hardware_widget import HardwareWidget
from process_widget import ProcessWidget
from timer_widget import TimerWidget
from typing import Any

class MonitorApp:
    def __init__(self, stdscr: 'curses._CursesWindow') -> None:
        self.stdscr: 'curses._CursesWindow' = stdscr
        self.stdscr.nodelay(True)  # Make getch non-blocking

        self.setup_curses()

        self.container_widget = ContainerWidget(self.stdscr, update_offset=3)
        self.website_widget = WebsiteWidget(self.stdscr)
        self.hardware_widget = HardwareWidget(self.stdscr)
        self.process_widget = ProcessWidget(self.stdscr, update_offset=1)
        self.timer_widget = TimerWidget(self.stdscr)

    def setup_curses(self) -> None:
        curses.curs_set(0)  # Hide cursor

        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)
        curses.init_pair(5, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
        curses.init_pair(6, curses.COLOR_RED, curses.COLOR_BLACK)

        curses.init_pair(7, curses.COLOR_WHITE, curses.COLOR_BLACK)
        curses.init_pair(8, curses.COLOR_BLACK, curses.COLOR_WHITE)

    def update(self, time: float = time.time()) -> None:
        self.hardware_widget.update(time)
        self.process_widget.update(time)
        self.website_widget.update(time)
        self.container_widget.update(time)
        self.timer_widget.update(time)

    def redraw(self) -> None:
        row = 0
        row = self.hardware_widget.draw(row)
        row = self.process_widget.draw(row)
        row = self.website_widget.draw(row)
        row = self.container_widget.draw(row)
        row = self.timer_widget.draw(row)
        self.stdscr.refresh()

    def run(self) -> None:
        self.stdscr.clear()
        last_timer_update = time.time()

        while True:
            key = self.stdscr.getch()
            now = time.time()

            # If key is pressed
            if key != -1:
                self.timer_widget.handle_input(key, now)
                self.timer_widget.draw()

            # If second has passed
            if now - last_timer_update >= 1:
                last_timer_update = now
                self.update(now)
                self.redraw()

            time.sleep(0.05)

def main(stdscr: Any) -> None:
    app = MonitorApp(stdscr)
    app.run()

if __name__ == "__main__":
    curses.wrapper(main)
