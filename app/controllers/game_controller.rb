require 'open-uri'
require 'json'

class GameController < ApplicationController

  def game
    grid = generate_grid(9)
    @grid_letters = grid.join(" ")
    @start_time = Time.now
  end

  def score
    attempt = params[:word]
    grid = params[:letters]
    start_time = params[:time]
    end_time = Time.now
    @result = run_game(attempt, grid, start_time, end_time)
  end

  def generate_grid(grid_size)
  # TODO: generate random grid of letters
    (0...grid_size).map { (65 + rand(26)).chr }
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    return_hash = {}

    attempt_answer = JSON.parse(open('https://wagon-dictionary.herokuapp.com/' + attempt).read)

    attempt_hash = Hash.new(0)
    attempt_array = attempt.scan(/\w/)
    attempt_array.each { |letter| attempt_hash[letter] += 1 }

    grid = grid.split(" ")
    grid.each { |letter| letter.downcase! }
    grid_hash = Hash.new(0)
    grid.each { |letter| grid_hash[letter] += 1 }

    return_hash[:score] = 0
    return_hash[:message] = "well done"

    unless attempt_answer["found"] == true
      return_hash[:message] = "not an english word"
      return return_hash
    end

    unless attempt_hash.all? { |o| attempt_hash[o[0]] <= grid_hash[o[0]] }
      return_hash[:message] = "not in the grid"
      return return_hash
    end

    return_hash[:score] = (attempt_array.count * (1 / (end_time - Time.parse(start_time))) * 100).to_i

    return return_hash
  end
end
