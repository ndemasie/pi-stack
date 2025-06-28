from MonitorApp import MonitorWidget
from textual.app import App, ComposeResult

class MainApp(App):
    CSS_PATH = None
    BINDINGS = [ ("q", "quit", "Quit") ]
    def compose(self) -> ComposeResult:
        yield MonitorWidget()

if __name__ == "__main__":
    MainApp().run()
