

CARD_NUMBERS = ['Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
                'Jack', 'Queen', 'King', 'Ace']
CARD_SUITS = ['Clubs', 'Diamonds', 'Hearts', 'Spades']

CARD_VALUES = {'Two' => 2, 'Three' => 3, 'Four' => 4, 'Five' => 5, 'Six' => 6, 'Seven' => 7, 
               'Eight' => 8, 'Nine' => 9, 'Ten' => 10, 'Jack' => 10, 'Queen' => 10, 'King' => 10,
               'Ace' => [1, 11]}

def make_game_deck(number_of_decks)
  deck = []
  number_of_decks.times do
    CARD_SUITS.each do |suit|
      CARD_NUMBERS.each do |number|
        deck << number + " of " + suit
      end
    end
  end
  return deck
end

def deal_a_hand(deck)
  new_hand = deck.pop(2)
end

def get_value_of_hand(hand)
  value = [0,0]
  hand.each do |card|
    if card.split[0] == 'Ace'
      value[0] += CARD_VALUES[card.split[0]][0]
      value[1] += CARD_VALUES[card.split[0]][1]
    else
      value[0] += CARD_VALUES[card.split[0]]
      value[1] += CARD_VALUES[card.split[0]]
    end
  end
  return value
end

def display_hands_player_turn(player_hand, computer_hand)
  system 'clear'
  puts "--------------------"
  puts "#{NAME}'s hand:"
  puts ""
  player_hand.each {|card| puts card}
  puts ""
  puts "--------------------"
  puts "Computer's hand:"
  puts ""
  puts "#{computer_hand[0]}"
  puts "???????"
  puts ""
  puts "--------------------"
end

def display_hands_computer_turn(player_hand, computer_hand)
  system 'clear'
  puts "--------------------"
  puts "#{NAME}'s hand:"
  puts ""
  player_hand.each {|card| puts card}
  puts ""
  puts "--------------------"
  puts "Computer's hand:"
  puts ""
  computer_hand.each {|card| puts card}
  puts ""
  puts "--------------------"
end

def display_value_of_player_hand(hand_value)
  if hand_value[0] == hand_value[1]
    puts "#{NAME}'s hand: #{hand_value[0]} points"
  else
    puts "#{NAME}'s hand: #{hand_value[0]} or #{hand_value[1]} points"
  end
  puts ""
end

def display_value_of_computer_hand(hand_value)
  if hand_value[0] == hand_value[1]
    puts "Computer's hand: #{hand_value[0]} points"
  else
    puts "Computer's hand: #{hand_value[0]} or #{hand_value[1]} points"
  end
  puts ""
end

def hit(hand, deck)
  hand << deck.pop
end

def hand_is_bust?(hand_value)
  hand_value[0] > 21 && hand_value[1] > 21
end

def hand_is_blackjack?(hand, hand_value)
  hand.length == 2 && hand_value[1] == 21
end

def pick_the_best_value(hand_value)
  if hand_value.max <= 21
    best_value = hand_value.max
  else
    best_value = hand_value.min
  end
  return best_value
end

system 'clear'
puts "*WELCOME TO BLACKJACK!*"
puts ""
puts "Please enter your name: "
NAME = gets.chomp
puts "Please enter the number of decks for this game (1 - 6)."
number_of_decks = gets.chomp.to_i

until number_of_decks >= 1 && number_of_decks <= 6
  puts "Sorry! Please enter a number 1 - 6."
end

game_deck = []
game_deck = make_game_deck(number_of_decks)
game_deck.shuffle!

continue = 'y'

while continue == 'y'

  if game_deck.length < 20
    system 'clear'
    game_deck = make_game_deck(number_of_decks)
    game_deck.shuffle! 
    puts "Shuffling..."
    sleep 1.5
  end
 
  player_hand = deal_a_hand(game_deck)
  computer_hand = deal_a_hand(game_deck)

  player_hand_value = get_value_of_hand(player_hand)
  computer_hand_value = get_value_of_hand(computer_hand)

  display_hands_player_turn(player_hand, computer_hand)
  display_value_of_player_hand(player_hand_value)

  sleep 1.5

  player_action = 'h'

  if hand_is_blackjack?(player_hand, player_hand_value) && 
     hand_is_blackjack?(computer_hand, computer_hand_value)
    display_hands_computer_turn(player_hand, computer_hand)
    sleep 1
    puts "You both got blackjacks!  It's a tie!"
  elsif hand_is_blackjack?(player_hand, player_hand_value)
    puts "You got a blackjack! You win!"
  elsif hand_is_blackjack?(computer_hand, computer_hand_value)
    display_hands_computer_turn(player_hand, computer_hand)
    sleep 1
    puts "The computer got a blackjack! You lose."
  end

  if !hand_is_blackjack?(player_hand, player_hand_value) && 
     !hand_is_blackjack?(computer_hand, computer_hand_value)

    while (player_hand_value[0] <= 21 || player_hand_value[1] <= 21) && 
          player_action == 'h'
      puts "(H)it or (S)tay?"
      player_action = gets.chomp.downcase

      until player_action == 'h' || player_action == 's'
        puts "Sorry, please choose (H)it or (S)tay."
        player_action = gets.chomp.downcase
      end

      if player_action == 's'
        next
      end

      hit(player_hand, game_deck)
      player_hand_value = get_value_of_hand(player_hand)
      display_hands_player_turn(player_hand, computer_hand)
      display_value_of_player_hand(player_hand_value)
    end

    if !hand_is_bust?(player_hand_value)
      display_hands_computer_turn(player_hand, computer_hand)
      display_value_of_player_hand(player_hand_value)
      display_value_of_computer_hand(computer_hand_value)

      while computer_hand_value[0] <= 17 || computer_hand_value[1] <= 17
        hit(computer_hand, game_deck)
        computer_hand_value = get_value_of_hand(computer_hand)
        display_hands_computer_turn(player_hand, computer_hand)
        display_value_of_player_hand(player_hand_value)
        display_value_of_computer_hand(computer_hand_value)
      end
    end

    if hand_is_bust?(computer_hand_value)
      puts "Computer busted! You win!"
    elsif hand_is_bust?(player_hand_value)
      puts "You busted! Computer wins."
    elsif pick_the_best_value(player_hand_value) == pick_the_best_value(computer_hand_value)
      puts "It's a tie!"
    elsif pick_the_best_value(player_hand_value) > pick_the_best_value(computer_hand_value)
      puts "#{NAME} wins!"
    elsif pick_the_best_value(player_hand_value) < pick_the_best_value(computer_hand_value)
      puts "Computer wins!"
    end
  end

  puts ""
  puts "Would you like to continue? (Y/N)"
  continue = gets.chomp.downcase
end












