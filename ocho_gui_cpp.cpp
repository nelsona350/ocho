#include <algorithm>
#include <array>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <iomanip>
#include <numeric>
#include <random>
#include <sstream>
#include <string>
#include <vector>

#include <gtk/gtk.h>

class OchoGame {
 public:
  OchoGame(int frames_per_round = 8, int bonus_round_threshold = 88)
      : frames_per_round_(frames_per_round), bonus_round_threshold_(bonus_round_threshold) {
    reset_game();
  }

  struct EndTurnResult {
    bool game_over = false;
    bool round_completed = false;
    double completed_round_score = 0.0;
    bool earned_bonus_round = false;
  };

  void reset_game() {
    turn_ = 1;
    frame_in_round_ = 1;
    round_number_ = 1;
    total_score_ = 0.0;
    current_round_score_ = 0.0;
    reset_board();
  }

  bool return_match_and_roll(int hole_index) {
    if (hole_index < 0 || hole_index > 7) return false;
    if (hole_[hole_index] != hole_index + 1) return false;

    int returned_ball = hole_index + 1;
    hole_[hole_index] = 0;
    number_of_matches_--;

    const int insert_at = 7 - number_of_matches_;
    ball_.insert(ball_.begin() + std::min(insert_at, static_cast<int>(ball_.size())), returned_ball);
    number_of_balls_remaining_ = static_cast<int>(ball_.size());
    roll_balls();
    return true;
  }

  void roll_again() { roll_balls(); }
  void start_next_turn() { this->start_new_turn(); }
  void clear_board_for_next_turn() { reset_board(); }

  EndTurnResult end_turn(bool start_next_turn = true) {
    const double turn_score = current_score();
    total_score_ += turn_score;
    current_round_score_ += turn_score;
    turn_++;

    const bool round_completed = frame_in_round_ >= frames_per_round_;
    if (round_completed) {
      const double completed_round_score = current_round_score_;
      if (completed_round_score >= bonus_round_threshold_) {
        frame_in_round_ = 1;
        round_number_++;
        current_round_score_ = 0.0;
        if (start_next_turn) {
          this->start_new_turn();
        }
        return {false, true, completed_round_score, true};
      }
      return {true, true, completed_round_score, false};
    }

    frame_in_round_++;
    if (start_next_turn) {
      this->start_new_turn();
    }
    return {false, false, 0.0, false};
  }

  void reload_non_matches() {
    std::vector<int> reloaded;
    for (int i = 0; i < 8; ++i) {
      if (hole_[i] != i + 1) {
        reloaded.push_back(hole_[i]);
        hole_[i] = 0;
      }
    }
    ball_ = reloaded;
    number_of_balls_remaining_ = static_cast<int>(ball_.size());
  }

  double current_score() const {
    double score = 0.0;
    for (int i = 0; i < 8; ++i) {
      if (hole_[i] == i + 1) score += (i + 1);
    }
    return score;
  }

  int frame_in_round() const { return frame_in_round_; }
  int round_number() const { return round_number_; }
  double total_score() const { return total_score_; }
  double current_round_score() const { return current_round_score_; }
  const std::array<int, 8>& hole() const { return hole_; }
  int number_of_matches() const { return number_of_matches_; }

 private:
  void reset_board() {
    ball_.clear();
    for (int i = 1; i <= 8; ++i) ball_.push_back(i);
    hole_.fill(0);
    number_of_matches_ = 0;
    number_of_balls_remaining_ = 8;
  }

  void start_new_turn() {
    while (true) {
      reset_board();
      roll_balls();
      if (number_of_matches_ > 0) return;
    }
  }

  void roll_balls() {
    for (int i = 0; i < 8; ++i) {
      if (hole_[i] == 0) {
        const int n =
            std::uniform_int_distribution<int>(0, static_cast<int>(ball_.size()) - 1)(rng_);
        hole_[i] = ball_[n];
        ball_.erase(ball_.begin() + n);
        number_of_balls_remaining_ = static_cast<int>(ball_.size());
      }
    }

    number_of_matches_ = 0;
    for (int i = 0; i < 8; ++i) {
      if (hole_[i] == i + 1) number_of_matches_++;
    }
  }

  int frames_per_round_;
  int bonus_round_threshold_;
  int turn_ = 1;
  int frame_in_round_ = 1;
  int round_number_ = 1;
  double total_score_ = 0.0;
  double current_round_score_ = 0.0;

  std::vector<int> ball_;
  std::array<int, 8> hole_{};
  int number_of_matches_ = 0;
  int number_of_balls_remaining_ = 8;

  std::mt19937 rng_{static_cast<unsigned int>(std::time(nullptr))};
};

struct HighScoreEntry {
  std::string name;
  double score;
};

class OchoGui {
 public:
  OchoGui() {
    load_high_scores();
    build_ui();
    awaiting_reroll_ = true;
    set_status("Click ROLL AGAIN to start frame 1.");
    update_view(false);
  }

  void show() { gtk_widget_show_all(window_); }

 private:
  static constexpr int kHighScoreLimit = 8;

  static void on_hole_clicked(GtkButton*, gpointer data) {
    auto* ctx = static_cast<std::pair<OchoGui*, int>*>(data);
    ctx->first->handle_hole_click(ctx->second);
  }

  static void on_end_frame(GtkButton*, gpointer data) {
    static_cast<OchoGui*>(data)->end_turn();
  }

  static void on_new_game(GtkButton*, gpointer data) {
    static_cast<OchoGui*>(data)->new_game();
  }

  static void on_show_scores(GtkButton*, gpointer data) {
    static_cast<OchoGui*>(data)->show_high_scores();
  }

  void build_ui() {
    window_ = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window_), "OCHO (C++ Port)");
    gtk_window_set_default_size(GTK_WINDOW(window_), 440, 640);
    g_signal_connect(window_, "destroy", G_CALLBACK(gtk_main_quit), nullptr);

    auto* outer = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8);
    gtk_container_set_border_width(GTK_CONTAINER(outer), 12);
    gtk_container_add(GTK_CONTAINER(window_), outer);

    turn_label_ = gtk_label_new("");
    gtk_box_pack_start(GTK_BOX(outer), turn_label_, FALSE, FALSE, 0);

    total_label_ = gtk_label_new("");
    gtk_box_pack_start(GTK_BOX(outer), total_label_, FALSE, FALSE, 0);

    round_label_ = gtk_label_new("");
    gtk_box_pack_start(GTK_BOX(outer), round_label_, FALSE, FALSE, 0);

    points_to_go_label_ = gtk_label_new("");
    gtk_box_pack_start(GTK_BOX(outer), points_to_go_label_, FALSE, FALSE, 0);

    auto* grid = gtk_grid_new();
    gtk_grid_set_row_spacing(GTK_GRID(grid), 4);
    gtk_grid_set_column_spacing(GTK_GRID(grid), 8);
    gtk_box_pack_start(GTK_BOX(outer), grid, FALSE, FALSE, 0);

    hole_buttons_.resize(8);
    frame_score_labels_.resize(8);

    for (int i = 0; i < 8; ++i) {
      auto* frame_score = gtk_label_new("0");
      gtk_grid_attach(GTK_GRID(grid), frame_score, 0, i, 1, 1);
      frame_score_labels_[i] = frame_score;

      auto* btn = gtk_button_new_with_label(std::to_string(i + 1).c_str());
      gtk_widget_set_size_request(btn, 80, 34);
      hole_click_context_[i] = std::make_pair(this, i);
      g_signal_connect(btn, "clicked", G_CALLBACK(on_hole_clicked), &hole_click_context_[i]);
      gtk_grid_attach(GTK_GRID(grid), btn, 1, i, 1, 1);
      hole_buttons_[i] = btn;
    }

    auto* actions = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 8);
    gtk_box_pack_start(GTK_BOX(outer), actions, FALSE, FALSE, 0);

    end_button_ = gtk_button_new_with_label("END FRAME");
    g_signal_connect(end_button_, "clicked", G_CALLBACK(on_end_frame), this);
    gtk_box_pack_start(GTK_BOX(actions), end_button_, TRUE, TRUE, 0);

    auto* new_btn = gtk_button_new_with_label("NEW GAME");
    g_signal_connect(new_btn, "clicked", G_CALLBACK(on_new_game), this);
    gtk_box_pack_start(GTK_BOX(actions), new_btn, TRUE, TRUE, 0);

    auto* score_btn = gtk_button_new_with_label("HIGH SCORES");
    g_signal_connect(score_btn, "clicked", G_CALLBACK(on_show_scores), this);
    gtk_box_pack_start(GTK_BOX(actions), score_btn, TRUE, TRUE, 0);

    status_label_ = gtk_label_new("Click a matching number to return it and roll again.");
    gtk_label_set_line_wrap(GTK_LABEL(status_label_), TRUE);
    gtk_box_pack_start(GTK_BOX(outer), status_label_, FALSE, FALSE, 0);
  }

  void update_view(bool after_roll) {
    if (after_roll) game_.reload_non_matches();
    gtk_button_set_label(GTK_BUTTON(end_button_), awaiting_reroll_ ? "ROLL AGAIN" : "END FRAME");

    std::ostringstream turn_text;
    turn_text << "Frame " << game_.frame_in_round() << "/8 (Round " << game_.round_number() << ")";
    gtk_label_set_text(GTK_LABEL(turn_label_), turn_text.str().c_str());

    std::ostringstream total_text;
    total_text << "Total Score: " << static_cast<int>(game_.total_score());
    gtk_label_set_text(GTK_LABEL(total_label_), total_text.str().c_str());

    const int frame_score = static_cast<int>(game_.current_score());
    std::ostringstream frame_text;
    frame_text << "Frame Score: " << frame_score;
    gtk_label_set_text(GTK_LABEL(round_label_), frame_text.str().c_str());

    const int needed = std::max(0, 88 - static_cast<int>(game_.current_round_score() + frame_score));
    std::ostringstream needed_text;
    needed_text << "To Bonus Round (88): " << needed;
    gtk_label_set_text(GTK_LABEL(points_to_go_label_), needed_text.str().c_str());

    for (int i = 0; i < 8; ++i) {
      int value = game_.hole()[i];
      bool match = value == i + 1;

      const std::string text = value == 0 ? std::to_string(i + 1) : std::to_string(value);
      gtk_button_set_label(GTK_BUTTON(hole_buttons_[i]), text.c_str());

      GtkStyleContext* context = gtk_widget_get_style_context(hole_buttons_[i]);
      gtk_style_context_remove_class(context, "suggested-action");
      if (match) gtk_style_context_add_class(context, "suggested-action");

      gtk_label_set_text(GTK_LABEL(frame_score_labels_[i]), match ? std::to_string(i + 1).c_str() : "0");
    }
  }

  void handle_hole_click(int idx) {
    if (awaiting_reroll_) {
      set_status("Frame ended. Click ROLL AGAIN to start the next frame.");
      return;
    }

    if (game_.hole()[idx] != idx + 1) {
      set_status("That hole is not a match. Choose a highlighted number.");
      return;
    }

    if (!game_.return_match_and_roll(idx)) {
      set_status("Invalid selection. Try another matching hole.");
      return;
    }

    if (game_.number_of_matches() == 0) {
      finish_frame(true);
      return;
    }

    set_status("Returned matched coin and rolled again.");
    update_view(true);
  }

  void end_turn() {
    if (awaiting_reroll_) {
      awaiting_reroll_ = false;
      game_.start_next_turn();
      set_status("Started next frame.");
      update_view(true);
      return;
    }

    finish_frame(false);
  }

  void finish_frame(bool automatic) {
    const int frame_score = static_cast<int>(game_.current_score());
    const int prior_frame = game_.frame_in_round();
    const auto result = game_.end_turn(false);

    if (result.game_over) {
      const double final_total = game_.total_score();
      record_high_score(final_total);

      std::ostringstream msg;
      msg << "Round score was " << static_cast<int>(result.completed_round_score)
          << " in 8 frames (< 88).\nFinal score: " << static_cast<int>(final_total)
          << ". Starting a new game.";
      info_dialog("Game Over", msg.str());

      game_.reset_game();
      awaiting_reroll_ = true;
      set_status("New game started. Click ROLL AGAIN to begin.");
      update_view(false);
      return;
    }

    if (result.earned_bonus_round) {
      game_.clear_board_for_next_turn();
      std::ostringstream msg;
      msg << "Round complete: " << static_cast<int>(result.completed_round_score)
          << " points in 8 frames. You earned a bonus round! Click ROLL AGAIN to continue.";
      awaiting_reroll_ = true;
      set_status(msg.str());
      update_view(false);
      return;
    }

    std::ostringstream msg;
    awaiting_reroll_ = true;
    game_.clear_board_for_next_turn();
    if (automatic) {
      msg << "No matches on roll. Frame " << prior_frame << " ended with " << frame_score
          << " points. Click ROLL AGAIN.";
    } else {
      msg << "Ended frame " << prior_frame << " with " << frame_score
          << " points. Click ROLL AGAIN.";
    }
    set_status(msg.str());
    update_view(false);
  }

  void new_game() {
    GtkWidget* dialog = gtk_message_dialog_new(GTK_WINDOW(window_), GTK_DIALOG_MODAL,
                                               GTK_MESSAGE_QUESTION, GTK_BUTTONS_YES_NO,
                                               "Start a new game and reset score?");
    int response = gtk_dialog_run(GTK_DIALOG(dialog));
    gtk_widget_destroy(dialog);
    if (response != GTK_RESPONSE_YES) return;

    game_.reset_game();
    awaiting_reroll_ = true;
    set_status("Started a new game. Click ROLL AGAIN to begin.");
    update_view(false);
  }

  void show_high_scores() {
    info_dialog("High Scores", high_score_text());
  }

  void set_status(const std::string& msg) {
    gtk_label_set_text(GTK_LABEL(status_label_), msg.c_str());
  }

  void info_dialog(const std::string& title, const std::string& body) {
    GtkWidget* dialog = gtk_message_dialog_new(GTK_WINDOW(window_), GTK_DIALOG_MODAL,
                                               GTK_MESSAGE_INFO, GTK_BUTTONS_OK, "%s", body.c_str());
    gtk_window_set_title(GTK_WINDOW(dialog), title.c_str());
    gtk_dialog_run(GTK_DIALOG(dialog));
    gtk_widget_destroy(dialog);
  }

  void load_high_scores() {
    high_scores_.clear();
    std::ifstream in("ocho_high_scores.csv");
    std::string line;
    while (std::getline(in, line)) {
      if (line.empty()) continue;
      std::istringstream iss(line);
      std::string name;
      std::string score_txt;
      if (!std::getline(iss, name, ',')) continue;
      if (!std::getline(iss, score_txt)) continue;
      try {
        high_scores_.push_back({name.empty() ? "Anonymous" : name, std::stod(score_txt)});
      } catch (...) {
      }
    }
    normalize_scores();
  }

  void save_high_scores() {
    std::ofstream out("ocho_high_scores.csv", std::ios::trunc);
    for (const auto& entry : high_scores_) {
      out << entry.name << "," << entry.score << "\n";
    }
  }

  std::string high_score_text() const {
    std::ostringstream out;
    out << "High Scores (Top " << kHighScoreLimit << ")\n";
    if (high_scores_.empty()) {
      out << "No scores yet.";
    } else {
      for (size_t i = 0; i < high_scores_.size(); ++i) {
        out << (i + 1) << ". " << high_scores_[i].name << " - "
            << static_cast<int>(high_scores_[i].score) << "\n";
      }
    }
    return out.str();
  }

  bool is_high_score(double score) const {
    if (static_cast<int>(high_scores_.size()) < kHighScoreLimit) return true;
    return score > high_scores_.back().score;
  }

  void record_high_score(double score) {
    if (!is_high_score(score)) return;

    GtkWidget* dialog = gtk_dialog_new_with_buttons(
        "New High Score", GTK_WINDOW(window_), GTK_DIALOG_MODAL,
        "_OK", GTK_RESPONSE_OK, "_Cancel", GTK_RESPONSE_CANCEL, nullptr);
    GtkWidget* box = gtk_dialog_get_content_area(GTK_DIALOG(dialog));
    GtkWidget* entry = gtk_entry_new();
    gtk_entry_set_placeholder_text(GTK_ENTRY(entry), "Enter your name");
    gtk_box_pack_start(GTK_BOX(box), entry, FALSE, FALSE, 8);
    gtk_widget_show_all(dialog);

    int response = gtk_dialog_run(GTK_DIALOG(dialog));
    std::string name = "Anonymous";
    if (response == GTK_RESPONSE_OK) {
      const char* text = gtk_entry_get_text(GTK_ENTRY(entry));
      if (text && *text) name = text;
    }
    gtk_widget_destroy(dialog);

    high_scores_.push_back({name, score});
    normalize_scores();
    save_high_scores();
  }

  void normalize_scores() {
    std::sort(high_scores_.begin(), high_scores_.end(), [](const auto& a, const auto& b) {
      return a.score > b.score;
    });
    if (static_cast<int>(high_scores_.size()) > kHighScoreLimit) {
      high_scores_.resize(kHighScoreLimit);
    }
  }

  OchoGame game_;
  std::vector<HighScoreEntry> high_scores_;

  GtkWidget* window_ = nullptr;
  GtkWidget* turn_label_ = nullptr;
  GtkWidget* total_label_ = nullptr;
  GtkWidget* round_label_ = nullptr;
  GtkWidget* points_to_go_label_ = nullptr;
  GtkWidget* end_button_ = nullptr;
  GtkWidget* status_label_ = nullptr;

  std::vector<GtkWidget*> hole_buttons_;
  std::vector<GtkWidget*> frame_score_labels_;
  std::array<std::pair<OchoGui*, int>, 8> hole_click_context_{};
  bool awaiting_reroll_ = false;
};

int main(int argc, char** argv) {
  gtk_init(&argc, &argv);
  OchoGui app;
  app.show();
  gtk_main();
  return 0;
}
