import random
import json
from pathlib import Path
import tkinter as tk
from tkinter import messagebox, simpledialog


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
    HIGH_SCORE_LIMIT = 10

    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("OCHO")

        self.game = OchoGame(max_turns=10)
        self.high_scores_file = Path(__file__).with_name("ocho_high_scores.json")
        self.high_scores = self._load_high_scores()

        title = tk.Label(root, text="Welcome to OCHO", font=("Helvetica", 16, "bold"))
        title.pack(pady=(10, 5))

        self.turn_label = tk.Label(root, text="")
        self.turn_label.pack()

        self.score_label = tk.Label(root, text="")
        self.score_label.pack()

        self.status_label = tk.Label(root, text="Click a green matched hole to give it back and roll again.")
        self.status_label.pack(pady=(5, 10))

        self.gameplay_frame = tk.Frame(root)
        self.gameplay_frame.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

        left_panel = tk.Frame(self.gameplay_frame)
        left_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        holes_panel = tk.Frame(self.gameplay_frame)
        holes_panel.pack(side=tk.RIGHT, padx=(10, 0))

        self.hole_buttons = []
        for i in range(8):
            btn = tk.Button(
                holes_panel,
                text="",
                width=20,
                height=2,
                command=lambda idx=i: self.on_hole_click(idx),
            )
            btn.grid(row=i, column=0, padx=5, pady=5, sticky="ew")
            self.hole_buttons.append(btn)

        self.end_turn_btn = tk.Button(
            left_panel,
            text="End Turn",
            command=self.end_turn,
            width=14,
            height=8,
            font=("Helvetica", 16, "bold"),
        )
        self.end_turn_btn.pack(expand=True)

        self.high_score_label = tk.Label(
            root,
            text="",
            justify=tk.LEFT,
            anchor="w",
            font=("Courier", 10),
        )
        self.high_score_label.pack(fill=tk.X, padx=10, pady=(0, 10))

        self.update_view(after_roll=True)
        self.update_high_score_view()

    def _load_high_scores(self) -> list[dict[str, float | str]]:
        if not self.high_scores_file.exists():
            return []
        try:
            data = json.loads(self.high_scores_file.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            return []

        cleaned = []
        for entry in data:
            name = str(entry.get("name", "Anonymous")).strip() or "Anonymous"
            score = float(entry.get("score", 0))
            cleaned.append({"name": name, "score": score})
        cleaned.sort(key=lambda x: x["score"], reverse=True)
        return cleaned[: self.HIGH_SCORE_LIMIT]

    def _save_high_scores(self) -> None:
        self.high_scores_file.write_text(
            json.dumps(self.high_scores[: self.HIGH_SCORE_LIMIT], indent=2),
            encoding="utf-8",
        )

    def _is_high_score(self, score: float) -> bool:
        if len(self.high_scores) < self.HIGH_SCORE_LIMIT:
            return True
        return score > float(self.high_scores[-1]["score"])

    def _record_high_score(self, score: float) -> None:
        if not self._is_high_score(score):
            return
        name = simpledialog.askstring(
            "High Score!",
            f"New top {self.HIGH_SCORE_LIMIT} score: {score:.0f}\nEnter your name:",
            parent=self.root,
        )
        if not name:
            name = "Anonymous"

        self.high_scores.append({"name": name.strip() or "Anonymous", "score": score})
        self.high_scores.sort(key=lambda x: x["score"], reverse=True)
        self.high_scores = self.high_scores[: self.HIGH_SCORE_LIMIT]
        self._save_high_scores()
        self.update_high_score_view()

    def update_high_score_view(self) -> None:
        lines = [f"High Scores (Top {self.HIGH_SCORE_LIMIT})"]
        if not self.high_scores:
            lines.append("  No scores yet.")
        else:
            for i, entry in enumerate(self.high_scores, start=1):
                lines.append(f"{i:>2}. {entry['name']:<12} {entry['score']:.0f}")
        self.high_score_label.config(text="\n".join(lines))

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
            self._record_high_score(final_total)
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
