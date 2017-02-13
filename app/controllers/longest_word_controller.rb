class LongestWordController < ApplicationController

  URL = "https://api-platform.systran.net/translation/text/\
translate?source=en&target=fr&key=61864558-9515-498b-b68f-1d6817f4ccc6&input="
  def game
    @grid = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid].split(" ")
    @start_time = params[:start_time].to_time
    @end_time = Time.now
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    (0...grid_size).map { (65 + rand(26)).chr }
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    time_to_choose = end_time - start_time
    word_translate = take_the_translation(attempt)
    define_the_situation(attempt, grid, time_to_choose, word_translate)
  end

  def take_the_translation(attempt)
    url_word = URL + attempt
    json_string = open(url_word).read
    json_hash = JSON.parse(json_string)
    json_hash["outputs"][0]["output"]
  end

  def define_the_situation(attempt, grid, time_to_choose, word_translate)
    if word_translate != attempt
      if attempt_correspond_with_grid?(grid, attempt)
        return attempt_is_good(time_to_choose, word_translate, grid)
      else
        return attempt_not_in_the_grid(time_to_choose)
      end
    else
      return attempt_not_in_the_grid(time_to_choose) unless attempt_correspond_with_grid?(grid, attempt)
      return attempt_not_english(time_to_choose)
    end
  end

  def attempt_correspond_with_grid?(grid, attempt)
    grid.each { |letter| return false if grid.join.count(letter) < attempt.upcase.count(letter) }
    attempt.upcase.each_char { |letter| return false unless grid.include?(letter) }
    true
  end

  def attempt_not_in_the_grid(time_to_choose)
    word_translate = nil
    player_score = 0
    score_message = "not in the grid"
    return { time: time_to_choose, translation: word_translate, score: player_score, message: score_message }
  end

  def attempt_is_good(time_to_choose, word_translate, grid)
    score_message = "well done"
    player_score = ((word_translate.size.to_f / grid.size.to_f) / time_to_choose.to_f) * 10
    return { time: time_to_choose, translation: word_translate, score: player_score, message: score_message }
  end

  def attempt_not_english(time_to_choose)
    score_message = "not an english word"
    word_translate = nil
    player_score = 0
    return { time: time_to_choose, translation: word_translate, score: player_score, message: score_message }
  end

end
