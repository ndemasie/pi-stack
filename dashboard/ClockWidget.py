from textual.widgets import Button, Static
from textual.containers import Horizontal
from textual.reactive import reactive
from textual.widget import Widget
from textual.timer import Timer as TextualTimer
from textual.app import ComposeResult

class ClockWidget(Widget):
    elapsed = reactive(0)
    running = reactive(False)

    def compose(self) -> ComposeResult:
        yield Horizontal(
            Button("Start", id="timer-btn", variant="primary"),
            Static(id="timer-display"),
            Button("Reset", id="reset-btn", variant="error"),
            id="clock-row"
        )

    def on_mount(self):
        self._timer: TextualTimer | None = None
        self.update_timer_display()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        btn = event.button
        if btn.id == "timer-btn":
            if btn.label == "Start":
                self.start()
                btn.label = "Stop"
                btn.variant = "warning"
            else:
                self.stop()
                btn.label = "Start"
                btn.variant = "primary"
        elif btn.id == "reset-btn":
            self.reset()
            # Optionally set Start button label back to Start and color
            start_btn = self.query_one("#timer-btn", Button)
            start_btn.label = "Start"
            start_btn.variant = "primary"

    def start(self):
        if not self.running:
            self.running = True
            self._timer = self.set_interval(1, self._tick)

    def stop(self):
        if self.running and self._timer:
            self._timer.stop()
            self._timer = None
            self.running = False

    def reset(self):
        self.elapsed = 0
        self.update_timer_display()
        self.stop()

    def _tick(self):
        self.elapsed += 1
        self.update_timer_display()

    def update_timer_display(self):
        hours, rem = divmod(self.elapsed, 3600)
        mins, secs = divmod(rem, 60)
        self.query_one("#timer-display", Static).update(f"{hours:02}:{mins:02}:{secs:02}")
