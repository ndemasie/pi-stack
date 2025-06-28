from textual.app import App, ComposeResult
from textual.widgets import Static, DataTable
from textual.containers import Vertical, Horizontal
from textual.reactive import reactive
import psutil
import os
import requests
import subprocess
import re

class MonitorWidget(Static):
    cpu_usage = reactive(0.0)
    memory_percent = reactive(0.0)
    memory_used = reactive(0.0)
    temp = reactive("0")

    top_processes = reactive([])
    website_status = reactive({})
    container_status = reactive([])
    website_urls = [
        "https://lieblinghomecare.com",
        "https://demasie.com/health",
        "https://nathan.demasie.com/health",
        "https://refer.demasie.com/health",
        "https://habit.demasie.com/health",
        "https://nathan-app-site.demasie.com/health",
        "https://nathan-app-habit-print.demasie.com/health",
        "https://nathan-app-refer-codes.demasie.com/health",
        "https://nathan-edu-i18next-server.demasie.com/health"
    ]

    def load_container_cache(self):
        result = []
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

    def clean_url(self, url):
        return url.replace("https://", "").replace("/health", "")

    def get_website_status_display(self, status_code):
        text = ""
        color = "green"
        if status_code == 0:
            text = "UKN"
        elif status_code == 200:
            text = "OK"
        else:
            text = "ERROR"
            color = "red"
        return f"[on {color}][black]{text.center(6)}[/black][/on {color}]"

    def get_container_status_display(self, status):
        color = "green" if status in ("healthy", "running") else "red"
        return f"[{color}]{status.center(6)}[/{color}]"

    def refresh_data(self):
        # Hardware
        self.cpu_usage = psutil.cpu_percent(interval=None)
        mem = psutil.virtual_memory()
        self.memory_percent = mem.percent
        self.memory_used = mem.used / 1024**2
        temp = os.popen("vcgencmd measure_temp").readline().strip().replace("temp=", "")
        self.temp = temp if temp else "0"

        # Websites
        for url in self.website_urls:
            try:
                status = requests.head(url, timeout=2).status_code
            except Exception:
                status = 400
            self.website_status[url] = status

        # Containers
        self.container_status = self.load_container_cache()

        self.update_widgets()

    def update_widgets(self):
        self.query_one("#cpu", Static).update(f"CPU: [green]{self.cpu_usage:.2f}%[/green]")
        self.query_one("#mem", Static).update(f"Mem: [green]{self.memory_percent:.1f}%[/green] ({self.memory_used:.1f}MB)")
        self.query_one("#temp", Static).update(f"T: [green]{self.temp}[/green]")

        # Get screen width for right alignment
        screen_width = self.app.size.width if hasattr(self, 'app') and self.app else 80

        # Websites
        website_table = self.query_one("#website-table", DataTable)
        website_table.clear(columns=True)
        max_width = max((len(self.clean_url(url)) for url in self.website_status if url.strip()), default=0)
        status_col_width = 8  # 6 chars + padding
        website_col_width = screen_width - status_col_width - 4  # 4 for table borders/padding
        website_table.add_columns(f"{'Website'.rjust(website_col_width)}", "Status")
        for url, status in self.website_status.items():
            if not url.strip():
                continue
            display_url = self.clean_url(url).rjust(website_col_width)
            status_text = self.get_website_status_display(status)
            website_table.add_row(display_url, status_text)

        # Containers
        container_table = self.query_one("#container-table", DataTable)
        container_table.clear(columns=True)
        # Right align container status column
        container_col_width = screen_width - status_col_width - 4
        container_table.add_columns(f"{'Container'.rjust(container_col_width)}", "Status")
        for _, name, status in self.container_status:
            display_name = name.rjust(container_col_width)
            status_text = self.get_container_status_display(status)
            container_table.add_row(display_name, status_text)

    def on_mount(self):
        self.set_interval(1, self.refresh_data)
        self.website_status = {url: 0 for url in self.website_urls}
        self.refresh_data()

    def compose(self) -> ComposeResult:
        # yield Static("[b]Raspberry Pi Status[/b]", id="title")
        yield Horizontal(
            Static(id="cpu"),
            Static(id="mem"),
            Static(id="temp"),
        )
        yield Static("")  # Space
        yield DataTable(id="website-table", show_cursor=False)
        yield Static("")  # Space
        yield DataTable(id="container-table", show_cursor=False)

class MonitorApp(App):
    CSS_PATH = None
    BINDINGS = [ ("q", "quit", "Quit") ]
    def compose(self) -> ComposeResult:
        yield MonitorWidget()

if __name__ == "__main__":
    MonitorApp().run()
