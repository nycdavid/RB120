module Displayable
  def clear
    system 'clear'
  end

  def empty_line
    puts ''
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts '     |     |'
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts '     |     |'
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return squares.first.marker if three_identical_markers?(squares)
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end
end

class Round
  include Displayable

  attr_accessor :board, :human, :computer, :current_marker

  FIRST_TO_MOVE = 'X'

  def initialize(human, computer)
    @board = Board.new
    @human = human
    @computer = computer
    @current_marker = FIRST_TO_MOVE
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    empty_line
    board.draw
    empty_line
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    end
  end

  def display_score
    puts '- - - Score Board - - -'
    puts "Player: #{human.score}, Computer: #{computer.score}"
    puts '- - - - - - - - - - - -'
  end

  def joinor(arr, delimiter=', ', word='or')
    case arr.size
    when 0 then ''
    when 1 then arr.first.to_s
    when 2 then arr.join(" #{word} ")
    else
      arr[-1] = "#{word} #{arr.last}"
      arr.join(delimiter)
    end
  end

  def human_moves
    puts "Choose a square between (#{joinor(board.unmarked_keys)}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)

      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    board[board.unmarked_keys.sample] = computer.marker
  end

  def current_player_moves
    if @current_marker == TTTGame::HUMAN_MARKER
      human_moves
      @current_marker = TTTGame::COMPUTER_MARKER
    else
      computer_moves
      @current_marker = TTTGame::HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == TTTGame::HUMAN_MARKER
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts 'You won!'
    when computer.marker
      puts 'Computer won!'
    else
      puts "It's a tie!"
    end
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def continue
    puts "Press enter to continue\r"
    gets
  end

  def start
    display_board
    player_move
    display_result
    update_score
    display_score
    continue
    reset
  end
end

class TTTGame
  include Displayable

  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  MAX_SCORE = 5

  attr_accessor :rounds, :human, :computer

  def initialize
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @rounds = []
  end

  def start_round
    round = Round.new(@human, @computer)
    round.start
    @rounds << round
  end

  def main_game
    loop do
      start_round
      break unless play_again?
      display_play_again_message
    end
  end

  def play
    clear
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def display_welcome_message
    puts 'Welcome to Tic Tac Toe!'
    empty_line
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  # def choose_marker
  #   puts "Choose a marker: O or X"
  #   choice = nil
  #   loop do
  #     choice = gets.chomp.upcase
  #     break if %w(O X).include?(choice)
  #     puts "Sorry, please enter O or X."
  #   end
  #   human.marker = choice
  # end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)

      puts 'Sorry, must be y or n'
    end
    answer == 'y'
  end

  def display_play_again_message
    puts "Let's play again!"
    empty_line
  end
end

game = TTTGame.new
game.play
