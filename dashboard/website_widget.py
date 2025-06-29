import curses
import requests
from typing import Dict, List, Tuple, Any

class WebsiteWidget:
    def __init__(self, stdscr) -> None:
        self.stdscr = stdscr
        self.website_cache: Dict[str, int] = {
            "https://lieblinghomecare.com": 0,
            "https://demasie.com/health": 0,
            "https://nathan.demasie.com/health": 0,
            "https://refer.demasie.com/health": 0,
            "https://habit.demasie.com/health": 0,
            "https://nathan-app-site.demasie.com/health": 0,
            "https://nathan-app-habit-print.demasie.com/health": 0,
            "https://nathan-app-refer-codes.demasie.com/health": 0,
            "https://nathan-edu-i18next-server.demasie.com/health": 0
        }
        self.website_keys: List[str] = list(self.website_cache.keys())
        self.website_index: int = 0
        self._last_update_second: int = -1

    @staticmethod
    def get_website_status(url: str) -> int:
        try:
            return requests.head(url, timeout=5).status_code
        except requests.RequestException:
            return 400

    @staticmethod
    def get_website_display(status_code: int, website_url: str) -> Tuple[int, str, str]:
        display_url: str = website_url.replace("https://", "").replace("/health", "").rjust(33)

        if status_code == 200:
            return curses.color_pair(1) | curses.A_REVERSE, "OK".center(6), display_url
        elif status_code == 0:
            return curses.color_pair(4) | curses.A_REVERSE, "UKN".center(6), display_url
        else:
            return curses.color_pair(6) | curses.A_REVERSE, "ERROR".center(6), display_url

    def update_cache(self, time: float) -> None:
        if int(time) != self._last_update_second:
            self._last_update_second = int(time)
            website_url: str = self.website_keys[self.website_index]
            self.website_cache[website_url] = self.get_website_status(website_url)
            self.website_index = (self.website_index + 1) % len(self.website_keys)

    def draw(self, row: int) -> int:
        self.stdscr.addstr(row, 0, f"{'Website'.rjust(33):<34}{'Status':<6}", curses.A_BOLD)

        for i, (website_url, status_code) in enumerate(self.website_cache.items()):
            color, status, website = self.get_website_display(status_code, website_url)
            self.stdscr.addstr(row + 1, 0, f"{website[-33:]:<34}")
            self.stdscr.addstr(row + 1, 34, f"{status[:6]}", color)
            row += 1

        return row + 2
