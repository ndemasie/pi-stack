from ClockWidget import ClockWidget
# from MonitorWidget import MonitorWidget
from textual.app import App, ComposeResult

class MainApp(App):
    CSS = '''
    #clock-row {
        height: 3;
        width: 100%;
        align-horizontal: center;
        align-vertical: middle;
    }
    #timer-btn {
        height: 3;
        width: 10;
        align-horizontal: center;
        content-align: center middle;
    }
    #timer-display {
        height: 3;
        width: 10;
        align-horizontal: center;
        content-align: center middle;
        text-align: center;
    }
    '''
    BINDINGS = [ ("q", "quit", "Quit") ]
    def compose(self) -> ComposeResult:
        # yield MonitorWidget()
        yield ClockWidget()

if __name__ == "__main__":
    MainApp().run()
