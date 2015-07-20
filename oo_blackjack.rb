# oo_blackjack.rb

require 'pry'
require 'pry-rescue'
require 'pry-stack_explorer'

class Card
  attr_accessor :suit, :rank

  def initialize (suit, rank)
    @suit = suit
    @rank = rank
  end

  def to_s
    "#{rank}#{suit}"
  end

  def value
    if v = /(\d+)/.match(rank)
      card_value = v[0].to_i
    elsif v = /([JQK])/.match(rank)
      card_value = 10
    elsif v = /(A)/.match(rank)
      card_value = 11
    end
    card_value
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['H', 'S', 'C', 'D'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |rank|
        @cards << Card.new(suit, rank)
      end
    end
  end

  def deal_one
    cards.pop
  end
end

class Player
  attr_accessor :hand_index, :hand, :name

  def initialize
    @hand = {}
    @hand_index = 0
    @name = 'Player 1'
  end

  def hit(card)
    hand[hand_index] << card
  end

  def stay
    if hand.size > 0 && hand_index < hand.size
      self.hand_index += 1
    end
  end

  def double_down(card)
    hand[hand_index] << card
    stay
  end

  def split (card1, card2)
    hand[hand.size] = Array(hand[hand_index].pop)
    # binding.pry

    hand[hand_index] << card1
    hand[hand.size-1] << card2
  end
end

class Dealer
  attr_accessor :name, :hand

  def initialize
    @hand = []
    @name = 'Dealer'
  end

  def hit(card)
    hand[hand_index] << card
  end
end

class Game
  PLAYER = 1
  DEALER = 2

  def initialize
    @deck = Deck.new
    @deck.cards.shuffle!
    @player1 = Player.new
    @dealer = Dealer.new
  end

  def total_cards(cards)
    hand_total = 0
    num_aces = 0
    cards.each do |card| 
      num_aces += 1 if /(A)/.match(card.rank)
      hand_total += card.value
    end
  
    while hand_total > 21 && num_aces > 0
      hand_total -= 10
      num_aces -= 1
    end 
  
    hand_total
  end 

  def bust?(hand)
   total_cards(hand) > 21
  end

  def print_cards(hand)
    hand.each do |card|
      print "#{card} "
    end
    puts
  end

  def show_hands(turn = PLAYER)
    system 'clear'
    
    @player1.hand.each do |key, value|
      # binding.pry
      hand_title =  @player1.name + ": (#{ total_cards(value) })"
      if turn == DEALER && total_cards(@dealer.hand) >= 17
        hand_title += " #{show_winner(value)}!"
      end
      puts hand_title
      print '=> ' if @player1.hand_index == key
      print_cards(value)
    end
  
    print "\n\n"
  
    if (turn == DEALER)
      puts "Dealer: (#{ total_cards(@dealer.hand) })"
      print_cards(@dealer.hand)
    else
      puts 'Dealer:'
      print @dealer.hand[0]
      puts ', Xx'
    end
  end

  def end_player_turn?
    @player1.hand_index > (@player1.hand.size - 1)
  end

  def deal_starting_hands
    @player1.hand_index = 0
    @player1.hand = {}
    @dealer.hand = []

    @player1.hand[0] = Array(@deck.deal_one)
    @dealer.hand << @deck.deal_one
    @player1.hand[0] << @deck.deal_one
    @dealer.hand << @deck.deal_one
  end

  def blackjack?
    total_cards(@dealer.hand) == 21 || total_cards(@player1.hand[0]) == 21
  end

  def show_blackjack_winner
    show_hands(DEALER)

    if total_cards(@dealer.hand) == 21 && @dealer.hand.size == 2
      if total_cards(@player1.hand[@player1.hand_index]) == 21
        puts "Push"
      else
        puts "Dealer has Blackjack!"
      end
    elsif total_cards(@player1.hand[@player1.hand_index]) == 21 && @player1.hand[0].size == 2
      puts "You have Blackjack!"
    end
  end

  def show_winner(player_hand)
    if total_cards(player_hand) == total_cards(@dealer.hand) && !bust?(player_hand)
      "its a push"
    elsif bust?(player_hand) || (total_cards(player_hand) < total_cards(@dealer.hand) && !bust?(@dealer.hand))
      "House wins"
    elsif bust?(@dealer.hand) && !bust?(player_hand) || 
            (total_cards(player_hand) > total_cards(@dealer.hand) && !bust?(player_hand)) || 
            total_cards(player_hand) == 21
      "#{@player1.name} wins"
    end
  end

  def players_choice
    puts "(h)it, (s)tand, s(p)lit, or (d)ouble down"
    gets.chomp
  end

  def players_turn(user_choice)
    case user_choice
    when 'h'
      @player1.hit(@deck.deal_one)
      @player1.stay if total_cards(@player1.hand[@player1.hand_index]) >= 21
    when 's' then @player1.stay
    when 'p' 
      if @player1.hand[@player1.hand_index][0].value == 
         @player1.hand[@player1.hand_index][1].value
           @player1.split(@deck.deal_one, @deck.deal_one)
           @player1.stay if total_cards(@player1.hand[@player1.hand_index]) == 21
      end
    when 'd' then @player1.double_down(@deck.deal_one)
    end
  end

  def dealers_turn
    show_hands(DEALER)
    sleep 1
    @dealer.hand << @deck.deal_one
  end

  def play
    loop do
      deal_starting_hands
      show_hands
  
      if blackjack?
        show_blackjack_winner
      else
        loop do
          players_turn(players_choice)
          show_hands
          break if end_player_turn?
        end
  
        loop do
          break if total_cards(@dealer.hand) >= 17
          dealers_turn
        end 
        show_hands(DEALER)
      end

      puts "play again? (y/n)"
      user_input = gets.chomp
      break if user_input.downcase == 'n' || @deck.cards.size < @deck.cards.size * 0.25
    end
  end
end

Game.new.play
