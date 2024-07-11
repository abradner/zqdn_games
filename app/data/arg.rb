# frozen_string_literal: true

Arg = Data.define(:name, :type, :required, :default) do
  Boolean = ActiveModel::Type::Boolean # local alias, making underlying datastructures less AM-dependent
  WHITELIST = %w[String Integer Float Hash] << Boolean.to_s
  MAPPABLE_WHITELIST = {
    int: "Integer",
    float: "Float",
    bool: Boolean.to_s,
    string: "String",
    object: "Hash",
  }.stringify_keys

  def initialize(name:, type:, required:, default: nil)
    t_class =
      if %w[String Symbol].include? type.class.to_s
        t_sanitised = MAPPABLE_WHITELIST.include?(type) ? MAPPABLE_WHITELIST[type] : type
        raise ArgumentError, "Unexpected type #{type}" unless WHITELIST.include? t_sanitised

        Object.const_get(t_sanitised)
      elsif type.is_a? Class
        type
      else
        raise ArgumentError, "Unexpected type #{type}"
      end

    super(name: name, type: t_class, required: required, default: default)
  end

  def type_as_json
    MAPPABLE_WHITELIST.key(type.to_s)
  end

  def as_json
    { name: name, type: type_as_json, required: required, default: default }.stringify_keys
  end
end
