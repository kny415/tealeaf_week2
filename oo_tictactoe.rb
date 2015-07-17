# oo_tictactoe.rb

require 'pry'

class Square
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def to_s
    value
  end
end

class Board
  attr_accessor :size, :squares, :player_score, :computer_score

  def initialize(size)
    @squares = {}
    @size = size
    (1..(size * size)).each { |key| @squares[key] = Square.new(' ') }
  end

  def draw_board
    system 'clear'
    (1..squares.size).each do |count|
      print ' ' + squares[count].to_s
      if (count % size != 0)
        print ' |'
      elsif (count != squares.size)
        print "\n"
        size.to_i.times { print '----' }
        print "\n"
      end
    end
    print "\n\n"
  end

  def board_full?
    squares.select { |key, _| squares[key].value == ' ' }.empty?
  end

  def empty_squares
    squares.select { |key, _| squares[key].value == ' ' }.keys
  end

  def square_not_taken?(index)
    empty_squares.include?(index)
  end
end

class Player
  attr_accessor :score, :name, :mark

  def initialize(name, mark, size)
    @name = name
    @mark = mark
    @score = []
    (0..(size * 2 + 1)).each { |index| @score[index] = 0 }
  end
end

class Game
  def initialize(board_size = 3)
    @board = Board.new(board_size)
    @player = Player.new('Player 1', 'X', board_size)
    @computer = Player.new('Computer', 'O', board_size)
  end

  def player_input
    begin
      puts "enter square index (1 - #{@board.size**2}):"
      players_pick = gets.chomp
    end until (/[1-9]+/.match(players_pick) && @board.square_not_taken?(players_pick.to_i))
    players_pick
  end

  def players_turn
    players_pick = player_input
    @board.squares[players_pick.to_i].value = @player.mark
    update_score(@player.score, (players_pick.to_i - 1))
    @board.draw_board
  end

  def computers_turn
    computers_pick = @board.empty_squares.sample
    @board.squares[computers_pick].value = @computer.mark
    update_score(@computer.score, (computers_pick.to_i - 1))
    @board.draw_board
  end

  def update_row_score(player_score, index)
    player_score[index / @board.size] += 1
  end

  def update_column_score(player_score, index)
    player_score[@board.size + index % @board.size] += 1
  end

  def update_diag1_score(player_score, index)
    player_score[@board.size * 2] += 1 if (index % (@board.size + 1) == 0)
  end

  def update_diag2_score(player_score, index)
    if (index < @board.size * @board.size - 1) && 
       (index % (@board.size - 1) == 0) && 
       (index > 0)
      player_score[@board.size * 2 + 1] += 1
    end
  end

  def update_score(player_score, index)
    # binding.pry
    update_row_score(player_score, index)
    # player_score[index / @board.size] += 1
    update_column_score(player_score, index)
    # player_score[@board.size + index % @board.size] += 1
    update_diag1_score(player_score, index)

    update_diag2_score(player_score, index)
  end

  def winner?(score)
    score.count { |value| value >= @board.size } > 0
  end

  def end_game?
    if winner?(@player.score)
      puts 'You win!'
      true
    elsif winner?(@computer.score)
      puts 'You lose!'
      true
    elsif @board.board_full?
      puts 'Tie!'
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
  puts 'What size board would you like?'
  user_input = gets.chomp.to_i
end until user_input >= 3

Game.new(user_input).play
