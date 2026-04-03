import random
import tkinter as tk
from tkinter import messagebox


class OchoGame:
    def __init__(self, max_turns: int = 10):
        self.max_turns = max_turns
        self.turn = 1
        self.total_score = 0.0
        self.selected_match_to_return = None

        self.ball = list(range(1, 9))
        self.hole = [0] * 8
        self.number_of_matches = 0
        self.number_of_balls_remaining = 8

        self._start_new_turn()

    def _reset_board(self) -> None:
        self.ball = list(range(1, 9))
        self.hole = [0] * 8
        self.number_of_matches = 0
        self.number_of_balls_remaining = 8
        self.selected_match_to_return = None

    def _start_new_turn(self) -> None:
        """Ensure turn starts with at least one match, like original C game."""
        good_initial_roll = False
        while not good_initial_roll:
            self._reset_board()
            self.roll_balls()
            if self.number_of_matches > 0:
                good_initial_roll = True

    def roll_balls(self) -> None:
        for i in range(8):
            if self.hole[i] == 0:
                n = random.randrange(self.number_of_balls_remaining)
                self.hole[i] = self.ball[n]
                self.number_of_balls_remaining -= 1
                self.ball.pop(n)

        self.number_of_matches = sum(1 for i in range(8) if self.hole[i] == i + 1)

    def current_score(self) -> float:
        return sum((i + 1) for i in range(8) if self.hole[i] == i + 1)

    def reload_non_matches(self) -> None:
        reloaded = []
        for i in range(8):
            if self.hole[i] != i + 1:
                reloaded.append(self.hole[i])
                self.hole[i] = 0
        self.ball = reloaded

    def can_roll_again(self) -> bool:
        return self.number_of_matches > 0

    def return_match_and_roll(self, hole_index: int) -> bool:
        if hole_index < 0 or hole_index > 7:
            return False
        if self.hole[hole_index] != hole_index + 1:
            return False

        returned_ball = hole_index + 1
        self.hole[hole_index] = 0
        self.number_of_matches -= 1

        insert_at = 7 - self.number_of_matches
        self.ball.insert(min(insert_at, len(self.ball)), returned_ball)
        self.number_of_balls_remaining = 8 - self.number_of_matches

        self.roll_balls()
        return True

    def end_turn(self) -> bool:
        self.total_score += self.current_score()
        self.turn += 1
        if self.turn > self.max_turns:
            return False

        self._start_new_turn()
        return True


class OchoApp:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("OCHO")

        self.game = OchoGame(max_turns=10)

        title = tk.Label(root, text="Welcome to OCHO", font=("Helvetica", 16, "bold"))
        title.pack(pady=(10, 5))

        self.turn_label = tk.Label(root, text="")
        self.turn_label.pack()

        self.score_label = tk.Label(root, text="")
        self.score_label.pack()

        self.status_label = tk.Label(root, text="Select a matched ball to give back, then roll again.")
        self.status_label.pack(pady=(5, 10))

        self.grid_frame = tk.Frame(root)
        self.grid_frame.pack(padx=10, pady=10)

        self.hole_buttons = []
        for i in range(8):
            btn = tk.Button(
                self.grid_frame,
                text="",
                width=20,
                height=2,
                command=lambda idx=i: self.on_hole_click(idx),
            )
            btn.grid(row=i // 4, column=i % 4, padx=5, pady=5)
            self.hole_buttons.append(btn)

        controls = tk.Frame(root)
        controls.pack(pady=(5, 10))

        self.roll_again_btn = tk.Button(
            controls,
            text="Roll Again (Give Back Selected Match)",
            command=self.roll_again,
            width=34,
        )
        self.roll_again_btn.grid(row=0, column=0, padx=5)

        self.end_turn_btn = tk.Button(
            controls,
            text="End Turn",
            command=self.end_turn,
            width=14,
        )
        self.end_turn_btn.grid(row=0, column=1, padx=5)

        self.update_view(after_roll=True)

    def on_hole_click(self, idx: int) -> None:
        if self.game.hole[idx] == idx + 1:
            self.game.selected_match_to_return = idx
            self.update_view()
        else:
            self.status_label.config(text=f"Hole {idx + 1} is not a match. Pick a green matched hole.")

    def roll_again(self) -> None:
        selected = self.game.selected_match_to_return
        if selected is None:
            self.status_label.config(text="Select a matched hole first.")
            return

        if not self.game.return_match_and_roll(selected):
            self.status_label.config(text="Invalid selection. Choose a currently matched hole.")
            return

        self.game.selected_match_to_return = None
        self.update_view(after_roll=True)

    def end_turn(self) -> None:
        prior_turn = self.game.turn
        prior_total = self.game.total_score
        turn_score = self.game.current_score()

        still_playing = self.game.end_turn()
        if not still_playing:
            final_total = prior_total + turn_score
            self.update_view()
            self.roll_again_btn.config(state=tk.DISABLED)
            self.end_turn_btn.config(state=tk.DISABLED)
            messagebox.showinfo("Game Over", f"Game Over after 10 turns. Final score: {final_total:.0f}")
            self.status_label.config(text=f"Game over. Final score: {final_total:.0f}")
            return

        self.status_label.config(
            text=f"Ended turn {prior_turn}. Scored {turn_score:.0f}. Starting turn {self.game.turn}."
        )
        self.update_view(after_roll=True)

    def update_view(self, after_roll: bool = False) -> None:
        if after_roll:
            self.game.reload_non_matches()

        self.turn_label.config(text=f"Turn: {self.game.turn}/10")
        self.score_label.config(
            text=f"Turn score: {self.game.current_score():.0f}    Total score: {self.game.total_score:.0f}"
        )

        for i, btn in enumerate(self.hole_buttons):
            val = self.game.hole[i]
            is_match = val == i + 1
            selected = self.game.selected_match_to_return == i

            txt = f"Hole {i + 1}: {'-' if val == 0 else val}"
            bg = "lightgreen" if is_match else "lightgray"
            relief = tk.SUNKEN if selected else tk.RAISED
            btn.config(text=txt, bg=bg, relief=relief)

        self.roll_again_btn.config(state=tk.NORMAL if self.game.can_roll_again() else tk.DISABLED)


def main() -> None:
    root = tk.Tk()
    app = OchoApp(root)
    _ = app
    root.mainloop()


if __name__ == "__main__":
    main()
