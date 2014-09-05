class Ingredient
  attr_reader :name

  def initialize(ingredient)
    @name = ingredient["name"]
  end

end
