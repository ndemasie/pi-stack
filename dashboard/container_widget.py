import curses
import subprocess
import re
from typing import List, Tuple, Any

class ContainerWidget:
    def __init__(self, stdscr) -> None:
        self.stdscr = stdscr
        self.container_cache: List[Tuple[str, str, str]] = []
        self.container_cache_expiry: int = 10 # Seconds
        self.container_update_offset: int = 2 # Seconds - Time offset to avoid spikes
        self.container_update_time: float = 0

    @staticmethod
    def load_docker_cache() -> List[Tuple[str, str, str]]:
        result: List[Tuple[str, str, str]] = []
        try:
            output = subprocess.check_output([
                "docker", "ps", "--format", "{{.ID}}|{{.Names}}|{{.State}}|{{.Status}}"
            ], text=True)
            for line in output.strip().splitlines():
                container_id, name, state, status = line.split("|", 3)
                status_str = re.search(r'\\(([^)]+)\\)', status)
                if status_str:
                    state = status_str.group(1)
                result.append((container_id, name, state))
        except Exception:
            pass
        return result

    @staticmethod
    def get_container_display(status: str) -> int:
        if status in ("healthy", "running"):
            return curses.color_pair(1)
        elif status == "unhealthy":
            return curses.color_pair(2)
        else:
            return curses.color_pair(6)

    def update_cache(self, time: float) -> None:
        if time - self.container_update_offset - self.container_update_time >= self.container_cache_expiry:
            self.container_update_time = time
            self.container_cache = self.load_docker_cache()

    def draw(self, row: int) -> int:
        self.stdscr.addstr(row, 0, f"{'Container':<32}{'Status':<8}", curses.A_BOLD)

        for i, (container_id, name, status) in enumerate(sorted(self.container_cache, key=lambda x: x[1])):
            color = self.get_container_display(status)
            self.stdscr.addstr(row + 1, 0, f"{name[:31]:<32}")
            self.stdscr.addstr(row + 1, 32, f"{status[:8]}", color)
            row += 1

        return row + 2
