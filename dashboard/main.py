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

        self.container_widget = ContainerWidget(self.stdscr)
        self.website_widget = WebsiteWidget(self.stdscr)
        self.hardware_widget = HardwareWidget(self.stdscr)
        self.process_widget = ProcessWidget(self.stdscr)
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

    def run(self) -> None:
        self.stdscr.clear()

        while True:
            current_time = time.time()

            self.hardware_widget.update()
            self.process_widget.update_cache(current_time)
            self.website_widget.update_cache(current_time)
            self.container_widget.update_cache(current_time)
            # self.timer_widget.update(current_time)

            row = 0
            row = self.hardware_widget.draw(row)
            row = self.process_widget.draw(row)
            row = self.website_widget.draw(row)
            row = self.container_widget.draw(row)
            # row = self.timer_widget.draw(row)

            self.stdscr.refresh()

            # key = self.stdscr.getch()
            # if key != -1:
            #     self.timer_widget.handle_input(key)

            time.sleep(0.05)

def main(stdscr: Any) -> None:
    app = MonitorApp(stdscr)
    app.run()

if __name__ == "__main__":
    curses.wrapper(main)
