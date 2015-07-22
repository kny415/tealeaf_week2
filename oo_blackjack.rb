# oo_blackjack.rb

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

  def count_value
    if /([2-6])/.match(rank)
      count_value = 1
    elsif /([10JQKA])/.match(rank)
      count_value = -1
    else
      count_value = 0
    end
    count_value
  end
end

class Deck
  attr_accessor :cards, :running_count

  def initialize(num_decks = 1)
    @cards = []
    %w(H S C D).each do |suit|
      %w(2 3 4 5 6 7 8 9 10 J Q K A).each do |rank|
        @cards << Card.new(suit, rank)
      end
    end
    @cards *= num_decks
    @running_count = 0
  end

  def deal_one
    card = cards.pop
    self.running_count += card.count_value
    card
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

  def splitable?
    cards.size == 2 ? cards[0].value == cards[1] .value : false
  end

  def doubleable?
    cards.size == 2
  end
end

class Player
  attr_accessor :hand_index, :hand, :name

  def initialize
    @hand = Array(Hand.new)
    @hand_index = 0
    @name = 'Player 1'
  end

  def hit(card)
    hand[hand_index].cards << card
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
  attr_accessor :name, :hand

  def initialize
    @hand = Array(Hand.new)
    @name = 'Dealer'
  end

  def show_hand(turn)
    if (turn == Game::DEALER)
      puts "#{name}: (#{hand.total})"
      hand.print_cards
    else
      puts 'Dealer'
      puts "#{hand.cards[0]}, Xx" 
    end
    puts
  end
end

class Game
  PLAYER = 1
  DEALER = 2

  attr_reader :player1, :dealer, :shoe, :num_decks

  def initialize
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

  def initialize_starting_hands
    player1.hand_index = 0
    player1.hand = []
    player1.hand[0] = Hand.new
    dealer.hand = Hand.new
  end

  def deal_starting_hands
    initialize_starting_hands
    2.times do
      player1.hand[0].cards << shoe.deal_one
      dealer.hand.cards << shoe.deal_one
    end
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
    end
  end

  def players_choice
    options = '(h)it, (s)tand, '
    options += "s(p)lit, " if player1.hand[player1.hand_index].splitable?
    options += "(d)ouble down, " if player1.hand[player1.hand_index].doubleable?
    options += '(help)'

    puts options
    gets.chomp
  end

  def players_turn(user_choice)
    case user_choice
    when 'h'
      player1.hit(shoe.deal_one)
      player1.stay if player1.hand[player1.hand_index].total >= 21
    when 's' then player1.stay
    when 'p'
      if player1.hand[player1.hand_index].splitable?
        player1.split(shoe.deal_one, shoe.deal_one)
      end
    when 'd'
      if player1.hand[player1.hand_index].doubleable?
        player1.double_down(shoe.deal_one)
      end
    when 'help' then show_help
    end
    show_hands
  end

  def dealers_turn
    show_hands(DEALER)
    sleep 1
    dealer.hand.cards << shoe.deal_one
  end

  def new_shoe
    @shoe = Deck.new(num_decks)
    shoe.cards.shuffle!
    system 'clear'
    puts 'new shoe coming in'
    sleep 2
  end

  def count_quiz
    puts 'whats the count?'
    count_answer = gets.chomp.to_i
    print count_answer == shoe.running_count ? 'Correct!  ' : 'Incorrect.  '
    puts "The current count is #{shoe.running_count}."
    puts "Decks remaining = #{(shoe.cards.size / 52.0).round(2)}"
  end

  def show_help
    puts [
      'Insurance: Insure at +3 or higher.',
      '16vT: Stand at 0 or higher, hit otherwise.',
      '15vT: Stand at +4 or higher, hit otherwise.',
      'TTv5: Split at +5 or higher, stand otherwise.',
      'TTv6: Split at +4 or higher, stand otherwise.',
      '10vT: Double at +4 or higher, hit otherwise.',
      '12v3: Stand at +2 or higher, hit otherwise.',
      '12v2: Stand at +3 or higher, hit otherwise.',
      '11vA: Double at +1 or higher, hit otherwise.',
      '9v2: Double at +1 or higher, hit otherwise.',
      '10vA: Double at +4 or higher, hit otherwise.',
      '9v7: Double at +3 or higher, hit otherwise.',
      '16v9: Stand at +5 or higher, hit otherwise.',
      '13v2: Stand at -1 or higher, hit otherwise.',
      '12v4: Stand at 0 or higher, hit otherwise.',
      '12v5: Stand at -2 or higher, hit otherwise.',
      '12v6: Stand at -1 or higher, hit otherwise.',
      "13v3: Stand at -2 or higher, hit otherwise.\n\n",
      '2-6 = +1',
      'T-A = -1'
    ].join("\n") + "\n" 
  
    puts "The current count is #{shoe.running_count}."
    puts "Decks remaining = #{(shoe.cards.size / 52.0).round(2)}"
    puts "\n\nenter to continue"
    gets.chomp
  end

  def play_hands
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
  end

  def low_shoe?
    shoe.cards.size < 52 * num_decks * 0.25
  end

  def play
    puts 'how many decks?'
    @num_decks = gets.chomp.to_i
    new_shoe

    loop do
      new_shoe if low_shoe?
      deal_starting_hands
      play_hands
      count_quiz
      puts 'play again? (y/n)'
      break if gets.chomp == 'n'
    end
  end
end

Game.new.play
