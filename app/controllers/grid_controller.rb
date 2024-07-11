class GridController < ApplicationController
  def new
    params.permit(:seed, :size)
    print params[:seed]
    seed = params[:seed].present? ? params[:seed].to_i : Random.new_seed
    size = params[:size].present? ? params[:size].to_i : Grid::DEFAULT_SIZE

    grid = Grid.new(seed: seed, size: size)
    render json: { seed: seed, size: size, solution: false, grid: grid }
  end

  def show
    seed = params.require(:id).to_i

    params.permit(:size)
    size = params[:size].present? ? params[:size].to_i : Grid::DEFAULT_SIZE

    grid = Grid.new(seed: seed, size: size)
    render json: { seed: seed, size: size, solution: true, grid: grid.as_json! }
  end
end
