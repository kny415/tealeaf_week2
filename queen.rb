# queen.rb
require 'pry'

class Queen
  def initialize(hsh = {})
    @cords = hsh
    @cords[:white] ||= [4, 5]
    @cords[:black] ||= [7, 3]
  end
end

q = Queen.new
binding.pry