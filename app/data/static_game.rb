# frozen_string_literal: true

StaticGame = Data.define(:name, :klass, :args) do
  def initialize(name:, klass:, args: [])
    k = klass.is_a?(String) ? Object.const_get(klass) : klass
    aa = args.map { |arg| Arg.new(**arg) }

    super(name: name, klass: k, args: aa)
  end

  def as_json
    { name: name, klass: klass.to_s, args: args.map(&:as_json) }.stringify_keys
  end
end
