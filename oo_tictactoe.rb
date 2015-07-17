# oo_tictactoe.rb

require 'pry'

class Square
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def to_s
    self.value
  end
end

class Board
  attr_accessor :size, :data, :player_score, :computer_score

  def initialize(size)
    @data = {}
    @size = size
    (1..(size*size)).each { |key| @data[key] = Square.new(' ') }
  end

  def draw_board
    system 'clear'
    (1..data.size).each do |count|  
      print " " + data[count].to_s
      if (count % size != 0)
        print " |" 
      elsif (count != data.size)
        print "\n"
        size.to_i.times { print "----" } 
        print "\n"
      end
    end
    print "\n\n"
  end  

  def board_full?
    data.select { |key, _| data[key].value == ' ' }.empty?
  end 
  
  def get_empty_squares
    data.select { |key, _| data[key].value == ' ' }.keys
  end
  
  def square_not_taken?(index)
    get_empty_squares.include?(index)
  end
end

class Player
  attr_accessor :score, :name, :mark

  def initialize(name, mark, size)
    @name = name
    @mark = mark
    @score = []
    (0..(size*2 + 2)).each { |index| @score[index] = 0 }
  end
end

class Game
  attr_accessor :players_pick, :computers_pick

  def initialize(board_size = 3)
    # players_pick = ''
    @board = Board.new(board_size)
    @player = Player.new("Player 1", "X", board_size)
    @computer = Player.new("Computer", "O", board_size)
  end

  def players_turn
    begin
      puts "enter square index (1 - #{ @board.size**2 }):"
      players_pick = gets.chomp
    end until (/[1-9]+/.match(players_pick) && @board.square_not_taken?(players_pick.to_i))

    @board.data[players_pick.to_i].value = @player.mark
    update_score(@player.score, (players_pick.to_i - 1)) 
    @board.draw_board
  end

  def computers_turn
    computers_pick = @board.get_empty_squares.sample
    @board.data[computers_pick].value = @computer.mark
    update_score(@computer.score, (computers_pick.to_i - 1)) 
    @board.draw_board
  end

  def update_score(player_score, index)
    player_score[index / @board.size] += 1
    player_score[@board.size + index % @board.size] += 1
    if (index % (@board.size + 1) == 0)
      player_score[@board.size * 2] += 1
    end
    if ((index < @board.size * @board.size - 1) && (index % (@board.size - 1) == 0) && (index > 0))
      player_score[@board.size * 2 + 1] += 1
    end
  end

  def winner?(score)
    score.select { |value| value >= @board.size }.size > 0
  end

  def end_game?
    if winner?(@player.score)
      puts "You win!"
      true
    elsif winner?(@computer.score)
      puts "You lose!"
      true
    elsif @board.board_full?
      puts "Tie!"
      true
    else
      false
    end
  end

  def play
    system 'clear'
    @board.draw_board
    
    loop do
      players_turn
      break if end_game?
      computers_turn
      break if end_game?
    end
  end

end

begin
      puts "What size board would you like?"
      user_input = gets.chomp
end until user_input.to_i >= 3

Game.new(user_input.to_i).play