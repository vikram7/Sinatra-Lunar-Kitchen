def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')
    yield(connection)
  ensure
    connection.close
  end
end

def get_all_recipes_from_the_recipes_table
  sql = "SELECT * FROM recipes"
  results = db_connection do |db|
    db.exec(sql)
  end
  results
end

def find_recipe_on_id(id)
  sql = "SELECT * FROM recipes where id = $1"
  result = db_connection do |db|
    db.exec(sql,[id])
  end
  result.to_a.first
end

def get_ingredients_on_id(id)
  sql = "SELECT ingredients.name FROM ingredients
  JOIN recipes ON recipes.id = ingredients.recipe_id
  WHERE recipes.id = $1"
  result = db_connection do |db|
    db.exec(sql,[id])
  end
  result.to_a
end

class Recipe
  attr_reader :id, :name, :instructions, :description

  def initialize(recipe)
    @id = recipe["id"]
    @name = recipe["name"]
    @instructions = recipe["instructions"]
    @description = recipe["description"]

    @description == nil ? @description = "This recipe doesn't have a description." : @description
    @instructions == nil ? @instructions = "This recipe doesn't have any instructions." : @instructions
  end

  def self.all
    array = []
    get_all_recipes_from_the_recipes_table.each do |each_recipe|
      array << Recipe.new(each_recipe)
    end
    array
  end

  def self.find(an_id)
    Recipe.new(find_recipe_on_id(an_id.to_i))
  end

  def ingredients
    array_of_ingredient_objects = []
    get_ingredients_on_id(id).each do |each_ingredient|
      array_of_ingredient_objects << Ingredient.new(each_ingredient)
    end
    array_of_ingredient_objects
  end
end
