# frozen_string_literal: true

class Game
  LIST = [
    {
      name: "Forest Grid",
      klass: "Grid",
      args: [
        { name: "seed", type: "int" },
        { name: "size", type: "int" },
      ],
    },
  ].map { |game| StaticGame.new(**game) }

  def self.list
    LIST
  end
end
