class GameController < ApplicationController

  def game
    @grid = generate_grid(9)
  end

  def score
    @attempt = params[:response]
    @start_t = params[:time]
    @end_t = Time.now
    @dictionary = parse(@attempt)
    time = ((@end_t - @start_t.to_i)).round
    session[:games].present? ? session[:games] += 1 : session[:games] = 0
    session[:time].present? ? session[:time] += time : session[:time] = time
    @valid = validity_check(grid_hash(params[:grid]), attempt_hash(@attempt))
    @results = { time: time,
                message: message(@valid, @dictionary),
                score: scr(@valid, @dictionary, @end_t, @start_t),
                total_score: session[:total_score],
                games: session[:games],
                avg_score: session[:total_score] / session[:games],
                avg_time: sessions[:time] / session[:games]
              }
  end

  private

  def grid_hash(grid)
    grid_hash = {}
    grid.chars.each { |char| grid_hash.include?(char) ?
                grid_hash[char] += 1 :
                grid_hash[char] = 1 }
    return grid_hash
  end

  def attempt_hash(attempt)
    attempt_hash = {}
    attempt.upcase.chars.each { |char| attempt_hash.include?(char) ?
                              attempt_hash[char] += 1 :
                              attempt_hash[char] = 1 }
    return attempt_hash
  end


  def generate_grid(grid_size)
    grid_array = []
    alpha = ("A".."Z").to_a
    x = 0
    while x < grid_size
      grid_array << alpha.sample
      x += 1
    end
    return grid_array
  end

  def validity_check(grid_hash, attempt_hash)
    p attempt_hash
    p grid_hash
    attempt_hash.each do |k, v| # STATEMENT CHECKING THE VALIDITY WITH CONTROL FLOW
      return false unless grid_hash.key?(k) && (v <= grid_hash[k])
    end
    return true # RETURNS TRUE IF ALL CHARS ARE CONSIDERED TRUE
  end

  def parse(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    response = open(url).read # API RESPONSE
    JSON.parse(response) # API PARSE
  end

  def message(valid, api_response)
    if valid == false
      return "not in the grid"
    elsif api_response["found"] == false
      return "not an english word"
    else
      return "well done"
    end
  end

  def scr(valid, api_response, end_time, start_time)
    if valid == false || api_response["found"] == false
      score = 0
    else
      p api_response
      p api_response["length"]
      score = ((api_response["length"].to_i * 10) - (end_time.to_i - start_time.to_i)).round
    end
    if session[:score].exists?
      session[:score] += score
    else
      session[:score] = score
    end
  end
end
