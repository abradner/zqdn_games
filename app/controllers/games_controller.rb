class GamesController < ApplicationController
  def index
    games = Game.list
    render json: games
  end
end
