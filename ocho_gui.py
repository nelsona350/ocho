import json
import random
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
        # Keep the same opening behavior as the original: each turn must start with a match.
        while True:
            self._reset_board()
            self.roll_balls()
            if self.number_of_matches > 0:
                return

    def roll_balls(self) -> None:
        for i in range(8):
            if self.hole[i] == 0:
                n = random.randrange(self.number_of_balls_remaining)
                self.hole[i] = self.ball[n]
                self.number_of_balls_remaining -= 1
                self.ball.pop(n)

        self.number_of_matches = sum(1 for i in range(8) if self.hole[i] == i + 1)

    def current_score(self) -> float:
        return float(sum((i + 1) for i in range(8) if self.hole[i] == i + 1))

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
        self.root.title("OCHO (Python Port)")
        self.root.configure(bg="#f4f4f4")
        self.root.geometry("360x700")
        self.root.resizable(False, False)

        self.asset_dir = Path(__file__).parent / "OchoSimple" / "OchoSimple"
        self.images = self._load_images()

        self.game = OchoGame(max_turns=10)
        self.high_scores_file = Path(__file__).with_name("ocho_high_scores.json")
        self.high_scores = self._load_high_scores()

        self._build_ui()
        self.update_view(after_roll=True)
        self.update_high_score_view()

    def _load_images(self) -> dict[str, tk.PhotoImage | None]:
        image_names = {
            "logo": "OchoLogo.png",
            "author": "AdamZapplCropped.png",
            "coin": "blackButton.png",
            "empty": "silverButton.png",
            "cta": "silverRectButton.png",
        }
        loaded: dict[str, tk.PhotoImage | None] = {}
        for key, filename in image_names.items():
            path = self.asset_dir / filename
            try:
                loaded[key] = tk.PhotoImage(file=str(path))
            except tk.TclError:
                loaded[key] = None
        return loaded

    def _build_ui(self) -> None:
        if self.images["logo"]:
            tk.Label(self.root, image=self.images["logo"], bg="#f4f4f4").pack(pady=(8, 4))
        else:
            tk.Label(self.root, text="OCHO", font=("Helvetica", 24, "bold"), bg="#f4f4f4").pack(pady=(8, 4))

        stat_row = tk.Frame(self.root, bg="#f4f4f4")
        stat_row.pack(fill=tk.X, padx=12)

        self.turn_label = tk.Label(stat_row, text="", font=("Helvetica", 11, "bold"), bg="#f4f4f4")
        self.turn_label.pack(side=tk.LEFT)

        self.points_to_go_label = tk.Label(stat_row, text="", font=("Helvetica", 11), bg="#f4f4f4")
        self.points_to_go_label.pack(side=tk.RIGHT)

        totals = tk.Frame(self.root, bg="#f4f4f4")
        totals.pack(fill=tk.X, padx=12, pady=(2, 8))

        self.total_score_label = tk.Label(totals, text="", font=("Helvetica", 11, "bold"), bg="#f4f4f4")
        self.total_score_label.pack(side=tk.LEFT)

        self.round_score_label = tk.Label(totals, text="", font=("Helvetica", 11), bg="#f4f4f4")
        self.round_score_label.pack(side=tk.RIGHT)

        board = tk.Frame(self.root, bg="#ffffff", bd=1, relief=tk.SOLID)
        board.pack(padx=12, pady=(0, 8), fill=tk.X)

        self.hole_canvases: list[tk.Canvas] = []
        self.hole_value_ids: list[int] = []
        self.frame_score_labels: list[tk.Label] = []

        for i in range(8):
            row = tk.Frame(board, bg="#ffffff")
            row.pack(fill=tk.X, padx=10, pady=4)

            fs = tk.Label(row, text="0", width=4, font=("Helvetica", 11, "bold"), bg="#ffffff")
            fs.pack(side=tk.LEFT)
            self.frame_score_labels.append(fs)

            cv = tk.Canvas(row, width=48, height=48, highlightthickness=0, bg="#ffffff")
            cv.pack(side=tk.RIGHT)
            cv.bind("<Button-1>", lambda _evt, idx=i: self.on_hole_click(idx))
            self.hole_canvases.append(cv)
            self.hole_value_ids.append(cv.create_text(24, 24, text=str(i + 1), fill="white", font=("Helvetica", 14, "bold")))

        actions = tk.Frame(self.root, bg="#f4f4f4")
        actions.pack(fill=tk.X, padx=12, pady=(2, 6))

        self.end_turn_btn = tk.Button(
            actions,
            text="END TURN",
            command=self.end_turn,
            font=("Helvetica", 11, "bold"),
            width=14,
            relief=tk.RAISED,
            bd=2,
        )
        if self.images["cta"]:
            self.end_turn_btn.configure(image=self.images["cta"], compound=tk.CENTER)
        self.end_turn_btn.pack(side=tk.LEFT)

        self.new_game_btn = tk.Button(
            actions,
            text="NEW GAME",
            command=self.new_game,
            font=("Helvetica", 11, "bold"),
            width=14,
            relief=tk.RAISED,
            bd=2,
        )
        if self.images["cta"]:
            self.new_game_btn.configure(image=self.images["cta"], compound=tk.CENTER)
        self.new_game_btn.pack(side=tk.RIGHT)

        self.status_label = tk.Label(
            self.root,
            text="Tap a matching coin to return it and roll again.",
            bg="#f4f4f4",
            wraplength=330,
            justify=tk.LEFT,
            anchor="w",
        )
        self.status_label.pack(fill=tk.X, padx=12, pady=(2, 6))

        self.high_score_label = tk.Label(
            self.root,
            text="",
            justify=tk.LEFT,
            anchor="w",
            font=("Courier", 9),
            bg="#f4f4f4",
        )
        self.high_score_label.pack(fill=tk.BOTH, expand=True, padx=12, pady=(0, 8))

        if self.images["author"]:
            tk.Label(self.root, image=self.images["author"], bg="#f4f4f4").pack(pady=(0, 8))

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

    def _draw_hole(self, idx: int, value: int) -> None:
        cv = self.hole_canvases[idx]
        cv.delete("coin")
        match = value == idx + 1

        coin_image = self.images["coin"] if value else self.images["empty"]
        if coin_image is not None:
            cv.create_image(24, 24, image=coin_image, tags="coin")
        else:
            fill = "#2d2d2d" if value else "#b7b7b7"
            cv.create_oval(2, 2, 46, 46, fill=fill, outline="#333", width=2, tags="coin")

        color = "#66ff66" if match else "white"
        text = str(value) if value else str(idx + 1)
        cv.itemconfig(self.hole_value_ids[idx], text=text, fill=color)

        frame_score = idx + 1 if match else 0
        self.frame_score_labels[idx].config(text=str(frame_score))

    def update_view(self, after_roll: bool = False) -> None:
        if after_roll:
            self.game.reload_non_matches()

        round_score = self.game.current_score()
        self.turn_label.config(text=f"Turn {self.game.turn}/10")
        self.total_score_label.config(text=f"Total Score: {self.game.total_score:.0f}")
        self.round_score_label.config(text=f"Round Score: {round_score:.0f}")
        self.points_to_go_label.config(text=f"To 88: {max(0, 88 - int(round_score))}")

        for i, val in enumerate(self.game.hole):
            self._draw_hole(i, val)

    def on_hole_click(self, idx: int) -> None:
        if self.game.hole[idx] != idx + 1:
            self.status_label.config(text=f"Hole {idx + 1} is not a match. Choose a green number.")
            return

        if not self.game.return_match_and_roll(idx):
            self.status_label.config(text="Invalid selection. Try another matched hole.")
            return

        self.status_label.config(text=f"Returned coin {idx + 1}. Tossed again.")
        self.update_view(after_roll=True)

    def end_turn(self) -> None:
        prior_turn = self.game.turn
        prior_total = self.game.total_score
        turn_score = self.game.current_score()

        started_new_game = self.game.end_turn()
        if started_new_game:
            final_total = prior_total + turn_score
            self._record_high_score(final_total)
            messagebox.showinfo(
                "Game Over",
                f"Game over after 10 turns. Final score: {final_total:.0f}.\nStarting a new game.",
            )
            self.status_label.config(text="New game started.")
            self.update_view(after_roll=True)
            return

        self.status_label.config(text=f"Ended turn {prior_turn} with {turn_score:.0f} points.")
        self.update_view(after_roll=True)

    def new_game(self) -> None:
        if not messagebox.askyesno("New Game", "Start a new game and reset score?"):
            return
        self.game.reset_game()
        self.status_label.config(text="Started a new game.")
        self.update_view(after_roll=True)


def main() -> None:
    root = tk.Tk()
    _app = OchoApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
