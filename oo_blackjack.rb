# oo_blackjack.rb

require 'pry'
require 'pry-rescue'
require 'pry-stack_explorer'
require 'pry-nav'

class Card
  attr_accessor :suit, :rank

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
  end

  def to_s
    "#{rank}#{suit}"
  end

  def value
    if v = /(\d+)/.match(rank)
      card_value = v[0].to_i
    elsif /([JQK])/.match(rank)
      card_value = 10
    elsif /(A)/.match(rank)
      card_value = 11
    end
    card_value
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    %w(H S C D).each do |suit|
      %w(2 3 4 5 6 7 8 9 10 J Q K A).each do |rank|
        @cards << Card.new(suit, rank)
      end
    end
  end

  def deal_one
    cards.pop
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def print_cards
    cards.each do |card|
      print "#{card} "
    end
    puts
  end

  def total
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

  def bust?
    total > 21
  end
end

class Player
  PLAYER = 1
  DEALER = 2
  attr_accessor :hand_index, :hand, :name

  def initialize
    @hand = Array(Hand.new)
    @hand_index = 0
    @name = 'Player 1'
  end

  def hit(card)
    hand[hand_index].cards << card
    stay if hand[hand_index].total >= 21
  end

  def stay
    self.hand_index += 1 if hand.size > 0 && hand_index < hand.size
  end

  def double_down(card)
    hand[hand_index].cards << card
    stay
  end

  def split(card1, card2)
    hand[hand.size] = Hand.new
    hand[hand.size - 1].cards = Array(hand[hand_index].cards.pop)

    hand[hand_index].cards << card1
    hand[hand.size - 1].cards << card2

    stay if hand[hand_index].total == 21
  end

  def show_hand(key, msg)
    puts name + ": (#{hand[key].total}) " + msg
    print '=> ' if hand_index == key
    hand[key].print_cards
  end
end

class Dealer
  PLAYER = 1
  DEALER = 2
  attr_accessor :name, :hand

  def initialize
    @hand = Array(Hand.new)
    @name = 'Dealer'
  end

  def hit(card)
    hand[hand_index] << card
  end

  def show_hand(turn)
    if (turn == DEALER)
      puts "#{name}: (#{hand.total})"
      hand.print_cards
    else
      puts 'Dealer'
      puts "#{hand.cards[0]}, Xx" 
    end
  end
end

class Game
  PLAYER = 1
  DEALER = 2

  attr_reader :player1, :dealer

  def initialize
    @deck = Deck.new
    @deck.cards.shuffle!
    @player1 = Player.new
    @dealer = Dealer.new
  end

  def show_hands(turn = PLAYER)
    system 'clear'

    player1.hand.each_with_index do |hand, key|
      msg = 
        turn == DEALER && @dealer.hand.total >= 17 ? " #{show_winner(hand)}!" : '' 
      player1.show_hand(key, msg)
    end

    print "\n\n"
    dealer.show_hand(turn)
  end

  def end_player_turn?
    player1.hand_index > (player1.hand.size - 1)
  end

  def deal_starting_hands
    player1.hand_index = 0
    player1.hand = []
    player1.hand[0] = Hand.new
    dealer.hand = Hand.new

    player1.hand[0].cards = Array(@deck.deal_one)
    dealer.hand.cards << @deck.deal_one
    player1.hand[0].cards << @deck.deal_one
    dealer.hand.cards << @deck.deal_one

    show_hands
  end

  def show_blackjack_winner
    show_hands(DEALER)
    player_hand = player1.hand[player1.hand_index]
    if push?(player_hand) && dealer.hand.cards.size == 2
      puts 'Push'
    elsif house_wins?(player_hand)
      puts 'Dealer has Blackjack'
    else
      puts 'You have Blackjack!'
    end
  end

  def push?(player_hand)
    player_hand.total == dealer.hand.total && !player_hand.bust?
  end

  def house_wins?(player_hand)
    player_hand.bust? ||
      (player_hand.total < dealer.hand.total && !dealer.hand.bust?)
  end

  def player_wins?(player_hand)
    dealer.hand.bust? && !player_hand.bust? ||
      (player_hand.total > dealer.hand.total && !player_hand.bust?) ||
      player_hand.total == 21
  end

  def show_winner(player_hand)
    if push?(player_hand) 
      'its a push'
    elsif house_wins?(player_hand)
      'House wins'
    elsif player_wins?(player_hand)
      "#{player1.name} wins"
    else
      ''
    end
  end

  def players_choice
    puts '(h)it, (s)tand, s(p)lit, or (d)ouble down'
    gets.chomp
  end

  def players_turn(user_choice)
    case user_choice
    when 'h'
      player1.hit(@deck.deal_one)
    when 's' then player1.stay
    when 'p'
      if player1.hand[player1.hand_index].cards[0].value ==
         player1.hand[player1.hand_index].cards[1].value
          player1.split(@deck.deal_one, @deck.deal_one)
      end
    when 'd' then player1.double_down(@deck.deal_one)
    end
    show_hands
  end

  def dealers_turn
    show_hands(DEALER)
    sleep 1
    dealer.hand.cards << @deck.deal_one
  end

  def play
    loop do
      deal_starting_hands

      if dealer.hand.total == 21 || player1.hand[0].total == 21
        show_blackjack_winner
      else
        loop do
          end_player_turn? ? break : players_turn(players_choice)
        end

        loop do
          dealer.hand.total >= 17 ? break : dealers_turn
        end
        show_hands(DEALER)
      end

      puts 'play again? (y/n)'
      break if gets.chomp == 'n' || @deck.cards.size < 52 * 0.25
    end
  end
end

Game.new.play