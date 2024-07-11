# frozen_string_literal: true

class Game
  LIST = [
    {
      name: "Forest Grid",
      klass: "Grid",
      args: [
        { name: "seed", type: "int", required: true, default: nil },
        { name: "size", type: "int", required: false, default: Grid::DEFAULT_SIZE },
      ],
    },
  ].map { |game| StaticGame.new(**game) }

  def self.list
    LIST
  end
end
