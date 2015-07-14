# oo_rps.rb

require "pry"

class Player
  attr_accessor :name, :hand

  def initialize (name)
    @name = name
  end

end

class RPSGame
  CHOICES = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors' }

  attr_accessor :player1, :computer

  def initialize
    @player1 = Player.new("Player 1")
    @computer = Player.new("Computer")
  end

  def compare_hands
    puts "#{ player1.name } chose #{ CHOICES[player1.hand] }, #{ computer.name } chose #{ CHOICES[computer.hand] }"

    if (player1.hand == computer.hand) 
      puts "Its a Tie!"
    elsif (player1.hand == 'r' && computer.hand == 's') ||
            (player1.hand == 'p' && computer.hand == 'r') ||
            (player1.hand == 's' && computer.hand == 'p') 
      puts "You Win!"
    else
      puts "You Lose!"
    end

    puts ""
  end

  def shoot
    computer.hand = CHOICES.keys.sample
    puts "Please choose r/p/s or q to quit"
    player1.hand = gets.chomp.downcase
  end

  def play
    loop do
      shoot
      break if player1.hand == 'q'
      # compare_hands (player1.hand, computer.hand) if CHOICES.keys.include? (player1.hand)
      compare_hands if CHOICES.keys.include? (player1.hand)
    end
  end
end

rps = RPSGame.new.play
