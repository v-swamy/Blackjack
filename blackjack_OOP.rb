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
    self.number_of_decks.times do
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
    self.cards.shuffle!
  end

  def reshuffle_deck
    puts "Shuffling..."
    sleep 1.5
    @cards = []
    self.number_of_decks.times do
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
    self.cards.shuffle!
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
    self.cards.each do |card|
      @value += card.value
    end
    aces_count = self.number_of_aces
    while aces_count > 0 && @value > 21
      @value -= 10
      aces_count -= 1
    end
    return @value
  end

  def number_of_aces
    self.cards.select { |card| card.number == 'Ace'}.length
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
    puts "#{self.name}'s hand:"
    puts ""
    self.hand.cards.each {|card| puts card.number + " of " + card.suit}
    puts ""
    puts "--------------------"
  end

  def display_value
    puts "#{self.name}: #{self.hand.value} points"
  end

  def hit(deck)
    self.hand.cards << deck.cards.pop
  end

  def bust?
    self.hand.value > 21
  end

  def has_a_blackjack?
    self.hand.cards.length == 2 && self.hand.value == 21
  end

  def clear_hand
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
    puts "#{self.name}'s hand:"
    puts ""
    puts self.hand.cards.first.number + " of " + self.hand.cards.first.suit
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
    self.clear_screen
    puts "*WELCOME TO BLACKJACK!*"
    puts ""
    self.player = Player.new
    self.dealer = Dealer.new
    self.player.get_name
    self.deck = Deck.new
  end

  def need_new_deck?
    self.deck.cards.length < 20
  end

  def check_for_blackjacks
    if self.player.has_a_blackjack? && self.dealer.has_a_blackjack?
      self.clear_screen
      self.show_all_hands
      puts "You both got blackjacks!  It's a tie!"
    elsif self.player.has_a_blackjack?
      self.clear_screen
      self.show_all_hands
      puts "You got a blackjack! You win!"
    elsif self.dealer.has_a_blackjack?
      self.clear_screen
      self.show_all_hands
      puts "The dealer got a blackjack!  You lose."
    end
  end

  def show_all_hands
    self.player.display_cards
    self.dealer.display_cards
    sleep 1
    self.player.display_value
    self.dealer.display_value
    sleep 1
  end


  def initial_deal
    puts "Dealing..."
    sleep 1.5
    self.clear_screen
    self.deck.deal_a_card(player.hand)
    self.deck.deal_a_card(dealer.hand)
    self.deck.deal_a_card(player.hand)
    self.deck.deal_a_card(dealer.hand)
    self.player.display_cards
    self.dealer.display_first_card
    self.player.display_value
    sleep 1
    self.check_for_blackjacks
  end

  def player_turn
    player_action = 'h'
    while !self.player.bust? && player_action == 'h'
      puts "(H)it or (S)tay?"
      player_action = gets.chomp.downcase
      
      until player_action == 'h' || player_action == 's'
        puts "Sorry, please choose (H)it or (S)tay."
        player_action = gets.chomp.downcase
      end

      if player_action == 's'
        next
      end
      self.clear_screen
      self.player.hit(self.deck)
      self.player.display_cards
      self.dealer.display_first_card
      sleep 1
      self.player.display_value
    end
  end

  def computer_turn
    self.clear_screen
    self.show_all_hands
    sleep 1
    if !self.player.bust?
      while dealer.hand.value <= 17
        self.clear_screen
        self.dealer.hit(self.deck)
        self.show_all_hands
      end
    end
  end

  def decide_winner
    if self.player.bust?
      puts "You busted! Dealer wins."
    elsif self.dealer.bust?
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
    self.intro
    continue = 'y'
    while continue == 'y'
      if self.need_new_deck?
        self.clear_screen
        self.deck.reshuffle_deck
      end
      self.player.clear_hand
      self.dealer.clear_hand
      self.initial_deal
      if !self.player.has_a_blackjack? && !self.dealer.has_a_blackjack?
        self.player_turn
        self.computer_turn
        self.decide_winner
      end
      puts ""
      puts "Would you like to continue? (y/n)"
      continue = gets.chomp.downcase
    end
    self.clear_screen
    puts "Thanks for playing!"
  end
end

Blackjack.new.play
