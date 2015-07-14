# oo_rps.rb

require "pry"

class Player
  attr_accessor :name, :hand

  def initialize (name)
    @name = name
  end

end

class RPSGame
  CHOICES = { 'r' => 'Rock', 'p' => 'Paper', 's' => 'Scissors'}

  attr_accessor :player1, :computer

  def initialize
    @player1 = Player.new("Player 1")
    @computer = Player.new("Computer")
  end

  def compare_hands (hand1, hand2)
    puts "You chose #{CHOICES[hand1]}, computer chose #{CHOICES[hand2]}"

    if (hand1 == hand2 ) 
      puts "Its a Tie!"
    elsif (hand1 == 'r' && hand2 == 's') ||
            (hand1 == 'p' && hand2 == 'r') ||
            (hand1 == 's' && hand2 == 'p') 
          puts "You Win!"
    else
      puts "You Lose!"
    end

    puts ""
  end

  def shoot
    computer.hand = CHOICES.keys.sample
    puts "Please choose r/p/s or q to quit"
    player1.hand = gets.chomp
  end

  def play
    loop do
      shoot
      break if player1.hand == 'q'
      # compare_hands (player1.hand, computer.hand) if CHOICES.keys.include? (player1.hand)
      compare_hands(player1.hand, computer.hand) if CHOICES.keys.include? (player1.hand)
    end
  end
end

rps = RPSGame.new.play
