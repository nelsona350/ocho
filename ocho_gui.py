import random
import tkinter as tk
from tkinter import messagebox


class OchoGame:
    def __init__(self, max_turns: int = 10):
        self.max_turns = max_turns
        self.turn = 1
        self.total_score = 0.0

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

    def reset_game(self) -> None:
        self.turn = 1
        self.total_score = 0.0
        self._start_new_turn()

    def end_turn(self) -> bool:
        """End a turn. Returns True if this started a brand-new game."""
        self.total_score += self.current_score()
        self.turn += 1
        if self.turn > self.max_turns:
            self.reset_game()
            return True

        self._start_new_turn()
        return False


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

        self.status_label = tk.Label(root, text="Click a green matched hole to give it back and roll again.")
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

        self.end_turn_btn = tk.Button(
            controls,
            text="End Turn",
            command=self.end_turn,
            width=14,
        )
        self.end_turn_btn.grid(row=0, column=0, padx=5)

        self.update_view(after_roll=True)

    def on_hole_click(self, idx: int) -> None:
        if self.game.hole[idx] == idx + 1:
            if not self.game.return_match_and_roll(idx):
                self.status_label.config(text="Invalid selection. Choose a currently matched hole.")
                return
            self.status_label.config(text=f"Returned ball from hole {idx + 1}. Rolled again.")
            self.update_view(after_roll=True)
        else:
            self.status_label.config(text=f"Hole {idx + 1} is not a match. Pick a green matched hole.")

    def end_turn(self) -> None:
        prior_turn = self.game.turn
        prior_total = self.game.total_score
        turn_score = self.game.current_score()

        started_new_game = self.game.end_turn()
        if started_new_game:
            final_total = prior_total + turn_score
            messagebox.showinfo(
                "New Game",
                f"Game Over after 10 turns. Final score: {final_total:.0f}\nStarting a new game.",
            )
            self.status_label.config(text="Started a new game. Scores and rounds were reset.")
            self.update_view(after_roll=True)
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

            txt = f"Hole {i + 1}: {'-' if val == 0 else val}"
            bg = "lightgreen" if is_match else "lightgray"
            btn.config(text=txt, bg=bg, relief=tk.RAISED)


def main() -> None:
    root = tk.Tk()
    app = OchoApp(root)
    _ = app
    root.mainloop()


if __name__ == "__main__":
    main()
