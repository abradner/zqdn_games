# frozen_string_literal: true

require "matrix"

class Grid
  PRINT_COMPONENTS = {
    tl: "⌜",
    bl: "⌞",
    br: "⌟",
    tr: "⌝",
    d: "+",
    zero: "0️⃣",
    one: "1️⃣",
    two: "2️⃣",
    three: "3️⃣",
    four: "4️⃣",
    empty: "⚔️",
    onethree: "🔺",
    zerotwo: "🔵",
    tree: "🌲",
  }.freeze

  JSON_COMPONENTS = {
    empty: 0,
    onethree: 1,
    zerotwo: 2,
    tree: 4,
  }.freeze

  SUB_GRIDS = {
    1 => 2,
    2 => 2,
    3 => 2,
    4 => 1,
  }.freeze
  DEFAULT_SIZE = 6.freeze

  CELL_CAPACITY = 4.freeze

  def initialize(seed:, size: DEFAULT_SIZE)
    @rng = Random.new(seed)
    @size = size
    @matrix = Matrix.build(@size) { 0 }
    @proposed = Matrix.build(@size) { 0 }
    @construction = []

    build_solution
  end

  def add_to_proposed_solution!(size, top_left)
    test = @proposed + place_matrix(size, top_left)
    if (@matrix - test).any? { |el| el < 0 }
      raise ArgumentError, "bad solution".freeze
    end
    @proposed = test
  end

  def matrix
    @matrix
  end

  def construction
    @construction
  end

  def solved?
    @matrix == @proposed
  end

  def show
    puts to_s(hide_vals: true)
  end

  def show!
    puts to_s(hide_vals: false)
  end

  def proposed_as_json
    matrix_as_json(@proposed, hide_vals: false)
  end

  def as_json(hide_vals: true, matrix: @matrix)
    h = {
      seed: @rng.seed,
      size: @size,
      sub_grids: SUB_GRIDS.map { | k, v | Array.new(v, k) }.flatten,
      matrix: matrix_as_json(matrix, hide_vals: hide_vals),
    }
    h[:construction] = @construction unless hide_vals
    h
  end

  def as_json!
    as_json(hide_vals: false)
  end

  def to_s(hide_vals: false)
    g = PRINT_COMPONENTS
    local_rng = Random.new(@rng.seed)

    # Padding
    output = "Seed: #{@rng.seed}\n"
    output += g[:tl] + ("  " * @size) + g[:tr] + "\n"

    # Translate (if required) and print the matrix
    @matrix.row_vectors.each do |row|
      result_row = (hide_vals ? do_hide_vals(row, g, local_rng) : row).to_a
      output += " " + result_row.join("") + " \n"
    end

    # Padding
    output + g[:bl] + ("  " * @size) + g[:br] + "\n"
  end

  private

  def build_solution
    # For each component type, starting from the largest
    SUB_GRIDS.sort_by { |k, _v| k }.reverse.each do |size, count|
      furthest_position = @size - size + 1
      count.times do
        top_left = [ @rng.rand(furthest_position), @rng.rand(furthest_position) ]
        add_to_solution!(size, top_left)
      rescue RangeError
        puts "seed #{@rng.seed} failed to place a #{size}x#{size} component at #{top_left}, retrying..."
        retry
      end
    end
  end

  def add_to_solution!(size, top_left)
    test = @matrix + place_matrix(size, top_left)
    if test.any? { |el| el > CELL_CAPACITY }
      raise RangeError, "placement is out of bounds".freeze
    end
    @matrix = test
    @construction << { size: size, top_left: top_left }
  end

  def matrix_as_json(matrix, hide_vals: false)
    local_rng = Random.new(@rng.seed)
    matrix.row_vectors.map do |row|
      (hide_vals ? do_hide_vals(row, JSON_COMPONENTS, local_rng) : row).to_a
    end
  end

  def do_hide_vals(row, mapping, rng)
    row.map do |el|
      case el
      when 4
        mapping[:tree]
      when 1, 3
        mapping[:onethree]
      when 2
        mapping[:zerotwo]
      when 0
        rng.rand(2).even? ? mapping[:empty] : mapping[:zerotwo]
      end
    end
  end

  def place_matrix(size, top_left)
    start_row, start_col = top_left

    # Ensure the placement is within bounds
    if start_row + size > @size || start_col + size > @size
      raise ArgumentError, "The smaller matrix doesn't fit at the specified coordinates."
    end

    in_grid = Matrix.build(@size) { 0 }
    size.times do |i|
      size.times do |j|
        in_grid[start_row + i, start_col + j] = 1
      end
    end

    in_grid
  end
end
