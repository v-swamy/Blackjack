class Card
  attr_accessor :suit, :number, :value
  CARD_NUMBERS = ['Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
                'Jack', 'Queen', 'King', 'Ace']
  CARD_SUITS = ['Clubs', 'Diamonds', 'Hearts', 'Spades']
  CARD_VALUES = {'Two' => 2, 'Three' => 3, 'Four' => 4, 'Five' => 5, 'Six' => 6, 'Seven' => 7, 
               'Eight' => 8, 'Nine' => 9, 'Ten' => 10, 'Jack' => 10, 'Queen' => 10, 'King' => 10,
               'Ace' => 11}
end

class Deck
  attr_reader :cards, :number_of_decks
  def initialize
    @cards = []
    get_number_of_decks
    number_of_decks.times do
      Card::CARD_SUITS.each do |suit|
        Card::CARD_NUMBERS.each do |number|
          card = Card.new
          card.suit = suit
          card.number = number
          card.value = Card::CARD_VALUES[card.number]
          @cards << card
        end
      end
    end
    cards.shuffle!
  end

  def reshuffle_deck
    puts "Shuffling..."
    sleep 1.5
    @cards = []
    number_of_decks.times do
      Card::CARD_SUITS.each do |suit|
        Card::CARD_NUMBERS.each do |number|
          card = Card.new
          card.suit = suit
          card.number = number
          card.value = Card::CARD_VALUES[card.number]
          @cards << card
        end
      end
    end
    cards.shuffle!
  end  

  def get_number_of_decks
    puts "Please enter the number of decks for this game (1 - 6)."
    @number_of_decks = gets.chomp.to_i
    until @number_of_decks >= 1 && @number_of_decks <= 6
      puts "Sorry! Please enter a number 1 - 6."
    end
  end

  def deal_a_card(hand)
    hand.cards << cards.pop
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def value
    @value = 0
    cards.each do |card|
      @value += card.value
    end
    aces_count = number_of_aces
    while aces_count > 0 && @value > 21
      @value -= 10
      aces_count -= 1
    end
    @value
  end

  def number_of_aces
    cards.select { |card| card.number == 'Ace'}.length
  end
end

class Player
  attr_accessor :name, :hand

  def initialize
    @hand = Hand.new
  end

  def get_name
    puts "Please enter your name:"
    self.name = gets.chomp
  end

  def display_cards
    puts "--------------------"
    puts "#{name}'s hand:"
    puts ""
    hand.cards.each {|card| puts card.number + " of " + card.suit}
    puts ""
    puts "--------------------"
  end

  def display_value
    puts "#{name}: #{hand.value} points"
  end

  def hit(deck)
    hand.cards << deck.cards.pop
  end

  def bust?
    hand.value > 21
  end

  def has_a_blackjack?
    hand.cards.length == 2 && hand.value == 21
  end

  def create_new_hand
    @hand = Hand.new
  end
end

class Dealer < Player

  def initialize
    @name = 'Dealer'
    @hand = Hand.new
  end

  def display_first_card
    puts "--------------------"
    puts "#{name}'s hand:"
    puts ""
    puts hand.cards.first.number + " of " + hand.cards.first.suit
    puts "????????"
    puts "--------------------"
  end
end

class Blackjack
  attr_accessor :deck, :player, :dealer

  def clear_screen
    system 'clear'
  end

  def intro
    clear_screen
    puts "*WELCOME TO BLACKJACK!*"
    puts ""
    self.player = Player.new
    self.dealer = Dealer.new
    player.get_name
    self.deck = Deck.new
  end

  def need_new_deck?
    deck.cards.length < 20
  end

  def check_for_blackjacks
    if player.has_a_blackjack? && dealer.has_a_blackjack?
      clear_screen
      show_all_hands
      puts "You both got blackjacks!  It's a tie!"
    elsif player.has_a_blackjack?
      clear_screen
      show_all_hands
      puts "You got a blackjack! You win!"
    elsif dealer.has_a_blackjack?
      clear_screen
      show_all_hands
      puts "The dealer got a blackjack!  You lose."
    end
  end

  def show_all_hands
    player.display_cards
    dealer.display_cards
    sleep 1
    player.display_value
    dealer.display_value
    sleep 1
  end


  def initial_deal
    puts "Dealing..."
    sleep 1.5
    clear_screen
    deck.deal_a_card(player.hand)
    deck.deal_a_card(dealer.hand)
    deck.deal_a_card(player.hand)
    deck.deal_a_card(dealer.hand)
    player.display_cards
    dealer.display_first_card
    player.display_value
    sleep 1
    check_for_blackjacks
  end

  def player_turn
    player_action = 'h'
    while !player.bust? && player_action == 'h'
      puts "(H)it or (S)tay?"
      player_action = gets.chomp.downcase
      
      until player_action == 'h' || player_action == 's'
        puts "Sorry, please choose (H)it or (S)tay."
        player_action = gets.chomp.downcase
      end

      if player_action == 's'
        next
      end
      clear_screen
      player.hit(deck)
      player.display_cards
      dealer.display_first_card
      sleep 1
      player.display_value
    end
  end

  def computer_turn
    clear_screen
    show_all_hands
    sleep 1
    if !player.bust?
      while dealer.hand.value <= 17
        clear_screen
        dealer.hit(deck)
        show_all_hands
      end
    end
  end

  def decide_winner
    if player.bust?
      puts "You busted! Dealer wins."
    elsif dealer.bust?
      puts "Dealer busted!  You win!"
    elsif player.hand.value == dealer.hand.value
      puts "It's a tie!"
    elsif player.hand.value > dealer.hand.value
      puts "#{player.name} wins!"
    elsif player.hand.value < dealer.hand.value
      puts "Dealer wins!"
    end
  end


  def play
    intro
    continue = 'y'
    while continue == 'y'
      if need_new_deck?
        clear_screen
        deck.reshuffle_deck
      end
      player.create_new_hand
      dealer.create_new_hand
      initial_deal
      if !player.has_a_blackjack? && !dealer.has_a_blackjack?
        player_turn
        computer_turn
        decide_winner
      end
      puts ""
      puts "Would you like to continue? (y/n)"
      continue = gets.chomp.downcase
    end
    clear_screen
    puts "Thanks for playing!"
  end
end

Blackjack.new.play
