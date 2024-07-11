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

  def update
    seed = params.require(:id).to_i
    size = params.require(:size).to_i

    proposals = params.require(:proposals)
    raise "Expected proposals to be an array" unless proposals.is_a?(Array)

    proposals_count = proposals.count
    expected_count = Grid::SUB_GRIDS.values.sum
    raise "need the right number of proposals (#{proposals_count} of #{expected_count}" if proposals_count != expected_count

    grid = Grid.new(seed: seed, size: size)

    errors = []
    proposals.each do |proposal|
      top_left = proposal[:top_left]
      if top_left.nil? ||
        !top_left.is_a?(Array) ||
        top_left.size != 2 ||
        !top_left.all? { |el| el.is_a?(Integer) }
        raise "Expected top_left (#{top_left}) to be an array of int len(2)"
      end
      size = proposal[:size]
      if size.nil? || !size.is_a?(Integer)
        raise "Expected size (#{size}) to be an integer"
      end

      grid.add_to_proposed_solution!(size, top_left)

    rescue ArgumentError => e
      errors << [proposal, e.message]
    end

    payload = { seed: seed, size: size, proposed_solution: grid.proposed_as_json, solved: grid.solved?, grid: grid }
    payload[:errors] = errors if errors.any?

    render json: payload
  end
end
