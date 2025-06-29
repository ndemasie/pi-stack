import curses
import time
from container_widget import ContainerWidget
from website_widget import WebsiteWidget
from hardware_widget import HardwareWidget
from process_widget import ProcessWidget
from typing import Any

class MonitorApp:
    def __init__(self, stdscr: Any) -> None:
        self.stdscr = stdscr
        self.setup_curses()

        self.container_widget = ContainerWidget()
        self.website_widget = WebsiteWidget()
        self.hardware_widget = HardwareWidget()
        self.process_widget = ProcessWidget()

    def setup_curses(self) -> None:
        curses.curs_set(0)  # Hide cursor
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)
        curses.init_pair(5, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
        curses.init_pair(6, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(7, curses.COLOR_WHITE, curses.COLOR_BLACK)

    def run(self) -> None:
        while True:
            current_time = time.time()

            self.hardware_widget.update()
            self.process_widget.update_cache(current_time)
            self.container_widget.update_cache(current_time)
            self.website_widget.update_cache()
            self.stdscr.clear()

            row = 0
            row = self.hardware_widget.draw(self.stdscr, row)
            row = self.process_widget.draw(self.stdscr, row)
            row = self.website_widget.draw(self.stdscr, row)
            row = self.container_widget.draw(self.stdscr, row)

            self.stdscr.refresh()
            time.sleep(1)  # Adjust refresh rate

def main(stdscr: Any) -> None:
    app = MonitorApp(stdscr)
    app.run()

if __name__ == "__main__":
    curses.wrapper(main)
