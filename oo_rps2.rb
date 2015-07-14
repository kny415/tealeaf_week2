# oo_rps2.rb
require "pry"

class Hand
  include Comparable

  attr_reader :value

  def initialize(v)
    @value = v
  end

  def <=>(another_hand)
    if @value == another_hand.value
      0
    elsif (value == 'r' && another_hand.value == 's') ||
            (value == 'p' && another_hand.value == 'r') ||
            (value == 's' && another_hand.value == 'p') 
      1
    else
      -1
    end
  end

  def display_winning_message
    case @value
    when 'r'
      puts "rock crushes scissors"
    when 'p'
      puts "paper wraps rock"
    when 's'
      puts "scissors cuts paper"
    end
  end
end

class Player
  attr_accessor  :name, :hand

  def initialize(n)
    @name = n
  end

  def to_s
    "#{name} has #{self.hand.value}"
  end

end

class Human < Player
  def pick_hand
    begin
      puts "pick one:  rps"
      c = gets.chomp.downcase
    end until Game::CHOICES.keys.include?(c)

    self.hand = Hand.new(c)
  end
end

class Computer < Player
  def pick_hand
    self.hand = Hand.new(Game::CHOICES.keys.sample)
  end
end

class Game
  CHOICES = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors' }

  attr_reader :player, :computer

  def initialize
    @player = Human.new("Player 1")
    @computer = Computer.new("Computer")
  end

  def compare_hands
    if player.hand == computer.hand
      puts "tie"
    elsif player.hand > computer.hand
      puts player.hand.display_winning_message
      puts "you win"
    else
      puts computer.hand.display_winning_message
      puts "you lose"
    end
  end

  def play
    player.pick_hand
    computer.pick_hand

    puts "player: #{player.hand.value}, computer: #{computer.hand.value}"
    compare_hands
  end

end

Game.new.play
