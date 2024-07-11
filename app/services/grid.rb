# frozen_string_literal: true

require "matrix"

class Grid
  GRID_COMPONENTS = {
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

  GRID_SIZE = 5.freeze

  def initialize
    @matrix = Matrix.build(GRID_SIZE) { 0 }
    @proposed = Matrix.build(GRID_SIZE) { 0 }
  end

  def add_to_solution!(size, top_left)
    @matrix += place_matrix(size, top_left)
  end

  def add_to_proposal!(size, top_left)
    test = @proposed + place_matrix(size, top_left)
    if (@matrix - test).any? { |el| el < 0 }
      raise ArgumentError, "bad solution"
    end
    @proposed = test
  end

  def matrix
    @matrix
  end

  def show
    puts to_s(hide_vals: true)
  end

  def show!
    puts to_s(hide_vals: false)
  end

  def to_s(hide_vals: false)
    g = GRID_COMPONENTS
    output = ""
    output += g[:tl] + ("  " * GRID_SIZE) + g[:tr] + "\n"
    @matrix.row_vectors.each do |row|
      result_row = if hide_vals
                     row.map do |el|
                       case el
                       when 4
                         g[:tree]
                       when 1, 3
                         g[:onethree]
                       when 2
                         g[:zerotwo]
                       when 0
                         rand(2).even? ? g[:empty] : g[:zerotwo]
                       end
                     end
      else
                     row
      end.to_a
      output += " " + result_row.join("") + " \n"
    end
    output + g[:bl] + ("  " * GRID_SIZE) + g[:br] + "\n"
  end

  private


  def place_matrix(size, top_left)
    start_row, start_col = top_left

    # Ensure the placement is within bounds
    if start_row + size > GRID_SIZE || start_col + size > GRID_SIZE
      raise ArgumentError, "The smaller matrix doesn't fit at the specified coordinates."
    end

    in_grid = Matrix.build(GRID_SIZE) { 0 }
    size.times do |i|
      size.times do |j|
        in_grid[start_row + i, start_col + j] = 1
      end
    end

    in_grid
  end
end
