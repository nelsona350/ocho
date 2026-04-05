import json
import random
from pathlib import Path
import tkinter as tk
from tkinter import messagebox, simpledialog


class OchoGame:
    def __init__(self, frames_per_round: int = 8, bonus_round_threshold: int = 88):
        self.frames_per_round = frames_per_round
        self.bonus_round_threshold = bonus_round_threshold
        self.turn = 1
        self.frame_in_round = 1
        self.round_number = 1
        self.total_score = 0.0
        self.current_round_score = 0.0

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
        # Keep the same opening behavior as the original: each frame must start with a match.
        while True:
            self._reset_board()
            self.roll_balls()
            if self.number_of_matches > 0:
                return

    def start_next_turn(self) -> None:
        self._start_new_turn()

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
        self.frame_in_round = 1
        self.round_number = 1
        self.total_score = 0.0
        self.current_round_score = 0.0
        self._start_new_turn()

    def end_turn(self, start_next_turn: bool = True) -> dict[str, bool | float]:
        turn_score = self.current_score()
        self.total_score += turn_score
        self.current_round_score += turn_score

        self.turn += 1

        round_completed = self.frame_in_round >= self.frames_per_round
        if round_completed:
            completed_round_score = self.current_round_score
            if completed_round_score >= self.bonus_round_threshold:
                self.frame_in_round = 1
                self.round_number += 1
                self.current_round_score = 0.0
                if start_next_turn:
                    self._start_new_turn()
                return {
                    "game_over": False,
                    "round_completed": True,
                    "completed_round_score": completed_round_score,
                    "earned_bonus_round": True,
                }

            return {
                "game_over": True,
                "round_completed": True,
                "completed_round_score": completed_round_score,
                "earned_bonus_round": False,
            }

        self.frame_in_round += 1
        if start_next_turn:
            self._start_new_turn()
        return {
            "game_over": False,
            "round_completed": False,
            "completed_round_score": 0.0,
            "earned_bonus_round": False,
        }


class OchoApp:
    HIGH_SCORE_LIMIT = 8

    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("OCHO (Python Port)")
        self.root.configure(bg="#f4f4f4")
        # Use a larger default window so controls are visible without scrolling.
        self.root.geometry("420x760")
        self.root.minsize(360, 640)
        self.root.resizable(True, True)

        self.asset_dir = Path(__file__).parent / "OchoSimple" / "OchoSimple"
        self.images = self._load_images()
        self._notify_missing_images()

        self.game = OchoGame(frames_per_round=8, bonus_round_threshold=88)
        self.high_scores_file = Path(__file__).with_name("ocho_high_scores.json")
        self.high_scores = self._load_high_scores()
        self.high_scores_window: tk.Toplevel | None = None
        self.high_scores_text_label: tk.Label | None = None

        self._build_scrollable_root()
        self._build_ui()
        self.awaiting_reroll = False
        self.update_view(after_roll=True)
        self.update_high_score_view()

    def _build_scrollable_root(self) -> None:
        self.container = tk.Frame(self.root, bg="#f4f4f4")
        self.container.pack(fill=tk.BOTH, expand=True)

        self.scroll_canvas = tk.Canvas(self.container, bg="#f4f4f4", highlightthickness=0)
        self.scrollbar = tk.Scrollbar(self.container, orient=tk.VERTICAL, command=self.scroll_canvas.yview)
        self.scroll_canvas.configure(yscrollcommand=self.scrollbar.set)

        self.scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.scroll_canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.content = tk.Frame(self.scroll_canvas, bg="#f4f4f4")
        self.content_window = self.scroll_canvas.create_window((0, 0), window=self.content, anchor="nw")

        self.content.bind("<Configure>", self._on_content_configure)
        self.scroll_canvas.bind("<Configure>", self._on_canvas_configure)
        self.scroll_canvas.bind_all("<MouseWheel>", self._on_mouse_wheel)

    def _on_content_configure(self, _evt: tk.Event) -> None:
        self.scroll_canvas.configure(scrollregion=self.scroll_canvas.bbox("all"))

    def _on_canvas_configure(self, event: tk.Event) -> None:
        self.scroll_canvas.itemconfigure(self.content_window, width=event.width)

    def _on_mouse_wheel(self, event: tk.Event) -> None:
        self.scroll_canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

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
#            path = self.asset_dir / filename
#            try:
#                loaded[key] = tk.PhotoImage(file=str(path))
#            except tk.TclError:
                loaded[key] = None
        return loaded

    def _notify_missing_images(self) -> None:
        missing = [
            filename
            for key, filename in {
                "logo": "OchoLogo.png",
                "author": "AdamZapplCropped.png",
                "coin": "blackButton.png",
                "empty": "silverButton.png",
                "cta": "silverRectButton.png",
            }.items()
            if self.images.get(key) is None
        ]
        if not missing:
            return

        lines = "\n".join(f"• {name}" for name in missing)
        messagebox.showwarning(
            "Images Unavailable",
            (
                "Some graphics could not be loaded from:\n"
                f"{self.asset_dir}\n\n"
                "The app will use fallback visuals for:\n"
                f"{lines}"
            ),
        )

    def _build_ui(self) -> None:
        if self.images["logo"]:
            tk.Label(self.content, image=self.images["logo"], bg="#f4f4f4").pack(pady=(8, 4))
        else:
            tk.Label(self.content, text="OCHO", font=("Helvetica", 24, "bold"), bg="#f4f4f4").pack(pady=(8, 4))

        stat_row = tk.Frame(self.content, bg="#f4f4f4")
        stat_row.pack(fill=tk.X, padx=12)

        self.turn_label = tk.Label(stat_row, text="", font=("Helvetica", 11, "bold"), bg="#f4f4f4")
        self.turn_label.pack(side=tk.LEFT)

        self.points_to_go_label = tk.Label(stat_row, text="", font=("Helvetica", 11), bg="#f4f4f4")
        self.points_to_go_label.pack(side=tk.RIGHT)

        totals = tk.Frame(self.content, bg="#f4f4f4")
        totals.pack(fill=tk.X, padx=12, pady=(2, 8))

        self.total_score_label = tk.Label(totals, text="", font=("Helvetica", 11, "bold"), bg="#f4f4f4")
        self.total_score_label.pack(side=tk.LEFT)

        self.round_score_label = tk.Label(totals, text="", font=("Helvetica", 11), bg="#f4f4f4")
        self.round_score_label.pack(side=tk.RIGHT)

        board = tk.Frame(self.content, bg="#ffffff", bd=1, relief=tk.SOLID)
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

        actions = tk.Frame(self.content, bg="#f4f4f4")
        actions.pack(fill=tk.X, padx=12, pady=(2, 6))

        self.end_turn_btn = tk.Button(
            actions,
            text="END FRAME",
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
            self.content,
            text="Tap a matching coin to return it and roll again.",
            bg="#f4f4f4",
            wraplength=330,
            justify=tk.LEFT,
            anchor="w",
        )
        self.status_label.pack(fill=tk.X, padx=12, pady=(2, 6))

        self.show_high_scores_btn = tk.Button(
            self.content,
            text="HIGH SCORES",
            command=self.show_high_scores,
            font=("Helvetica", 11, "bold"),
            width=14,
            relief=tk.RAISED,
            bd=2,
        )
        if self.images["cta"]:
            self.show_high_scores_btn.configure(image=self.images["cta"], compound=tk.CENTER)
        self.show_high_scores_btn.pack(pady=(0, 8))

        if self.images["author"]:
            tk.Label(self.content, image=self.images["author"], bg="#f4f4f4").pack(pady=(0, 8))

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

    def _high_score_text(self) -> str:
        lines = [f"High Scores (Top {self.HIGH_SCORE_LIMIT})"]
        if not self.high_scores:
            lines.append("  No scores yet.")
        else:
            for i, entry in enumerate(self.high_scores, start=1):
                lines.append(f"{i:>2}. {entry['name']:<12} {entry['score']:.0f}")
        return "\n".join(lines)

    def update_high_score_view(self) -> None:
        if self.high_scores_text_label is not None:
            self.high_scores_text_label.config(text=self._high_score_text())

    def _close_high_scores_window(self) -> None:
        if self.high_scores_window is not None:
            self.high_scores_window.destroy()
        self.high_scores_window = None
        self.high_scores_text_label = None

    def show_high_scores(self) -> None:
        if self.high_scores_window is not None and self.high_scores_window.winfo_exists():
            self.high_scores_window.lift()
            self.high_scores_window.focus_force()
            return

        self.high_scores_window = tk.Toplevel(self.root)
        self.high_scores_window.title("High Scores")
        self.high_scores_window.configure(bg="#f4f4f4")
        self.high_scores_window.resizable(False, False)
        self.high_scores_window.geometry("280x280")
        self.high_scores_window.protocol("WM_DELETE_WINDOW", self._close_high_scores_window)

        self.high_scores_text_label = tk.Label(
            self.high_scores_window,
            text=self._high_score_text(),
            justify=tk.LEFT,
            anchor="nw",
            font=("Courier", 10),
            bg="#f4f4f4",
        )
        self.high_scores_text_label.pack(fill=tk.BOTH, expand=True, padx=12, pady=(12, 8))

        tk.Button(
            self.high_scores_window,
            text="CLOSE",
            command=self._close_high_scores_window,
            font=("Helvetica", 10, "bold"),
            width=10,
        ).pack(pady=(0, 12))

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
        self.end_turn_btn.config(text="roll again" if self.awaiting_reroll else "end frame")

        self.awaiting_reroll = self.game.number_of_matches == 0
        self.end_turn_btn.config(text="roll again" if self.awaiting_reroll else "end frame")

        round_score = self.game.current_score()
        self.turn_label.config(text=f"Frame {self.game.frame_in_round}/8 (Round {self.game.round_number})")
        self.total_score_label.config(text=f"Total Score: {self.game.total_score:.0f}")
        self.round_score_label.config(text=f"Frame Score: {round_score:.0f}")
        round_score_if_ended = self.game.current_round_score + round_score
        self.points_to_go_label.config(text=f"To Bonus Round (88): {max(0, 88 - int(round_score_if_ended))}")

        for i, val in enumerate(self.game.hole):
            self._draw_hole(i, val)

    def on_hole_click(self, idx: int) -> None:
        if self.awaiting_reroll:
            self.status_label.config(text="Frame ended. Tap roll again to start the next frame.")
            return

        if self.game.hole[idx] != idx + 1:
            self.status_label.config(text=f"Hole {idx + 1} is not a match. Choose a green number.")
            return

        if not self.game.return_match_and_roll(idx):
            self.status_label.config(text="Invalid selection. Try another matched hole.")
            return

        if self.game.number_of_matches == 0:
            self._end_frame(automatic=True)
            return

        self.status_label.config(text=f"Returned coin {idx + 1}. Tossed again.")
        self.update_view(after_roll=True)

    def end_turn(self) -> None:
        if self.awaiting_reroll:
            self.awaiting_reroll = False
            self.game.start_next_turn()
            self.status_label.config(text="Started next frame.")
            self.update_view(after_roll=True)
            return

        self._end_frame(automatic=False)

    def _end_frame(self, automatic: bool) -> None:
        prior_frame = self.game.turn
        frame_score = self.game.current_score()

        end_result = self.game.end_turn(start_next_turn=False)
        if bool(end_result["game_over"]):
            final_total = self.game.total_score
            self._record_high_score(final_total)
            messagebox.showinfo(
                "Game Over",
                (
                    f"Round score was {float(end_result['completed_round_score']):.0f} in 8 frames (< 88).\n"
                    f"Final score: {final_total:.0f}.\nStarting a new game."
                ),
            )
            self.game.reset_game()
            self.awaiting_reroll = False
            self.status_label.config(text="New game started.")
            self.update_view(after_roll=True)
            return

        if bool(end_result["earned_bonus_round"]):
            self.awaiting_reroll = True
            self.status_label.config(
                text=(
                    f"Round complete: {float(end_result['completed_round_score']):.0f} points in 8 frames. "
                    "You earned a bonus round! Tap roll again to continue."
                )
            )
            self.update_view(after_roll=False)
            return

        self.awaiting_reroll = True
        if automatic:
            self.status_label.config(
                text=(
                    f"No matches on roll. Frame {prior_frame} ended with {frame_score:.0f} points. "
                    "Tap roll again."
                )
            )
        else:
            self.status_label.config(text=f"Ended frame {prior_frame} with {frame_score:.0f} points. Tap roll again.")
        self.update_view(after_roll=False)

    def new_game(self) -> None:
        if not messagebox.askyesno("New Game", "Start a new game and reset score?"):
            return
        self.game.reset_game()
        self.awaiting_reroll = False
        self.status_label.config(text="Started a new game.")
        self.update_view(after_roll=True)


def main() -> None:
    root = tk.Tk()
    _app = OchoApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
