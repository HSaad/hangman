class Game

	def initialize
		@word_maker = Word.new
		@board = Board.new()
		@computer = Computer.new()
		@player = Player.new()
	end

	def start
		print_instructions()
		#open saved game? or new game
		set_word()
		@board.display_word(@player, @word)

		while (!game_over?)
			# ask to save game?
			@player.guess_word()
			@board.draw(@player, @word)
		end

		restart if (play_again?)
	end

	def print_instructions()
		puts "Welcome to Hangman!"

		puts "To win, you must find the hidden word by guessing a letter each turn."
		puts "You'll have 6 chances to guess the word."	
	end

	def set_word
		@word_maker.pick_word
		@word = @word_maker.code
	end


	def game_over?()
		if check_win()
			print_win
			return true
		elsif @board.number_of_chances == 0
			print_lose
			return true		
		else
			return false
		end
	end 

	def check_win()
		#return true if there are no dashes in word, else return false
		if @board.game_word == ""
			return false
		elsif @board.game_word.include?("__")
			return false
		else 
			return true
		end
	end

	def print_win
		puts "Congratulations!"
		puts "You Win! You found the word!"
	end

	def print_lose
		puts "You Lose!"
		puts "The word was #{@word}"
	end

	def play_again?
		puts "Play Again? (y/n)"
		response = gets.chomp
		if (response.downcase.strip == "y" || response.downcase.strip == "yes")
			return true
		else
			return false
		end
	end

	def restart
		#ask if they would like to start new game or open saved game
		puts "Choose your game: "
		puts "1: New Game"
		puts "2: Saved Game"
		get_game()
	end

	def get_game()
		response = gets.chomp
		if (response.strip == "1" || response.downcase.strip == "new game")
			new_game()
		elsif (response.strip == "2" || response.downcase.strip == "saved game")
			load_game()
		else
			restart()
		end
	end

	def new_game()
		@word_maker = Word.new
		@board = Board.new()
		@computer = Computer.new()
		@player = Player.new()

		start()
	end

	def save_game
		Dir.mkdir("saved") unless Dir.exists? "saved"
		filename = "saved/" #save the game object as json/xml
	end

	def load_game

	end

	class Word
		attr_accessor :code

		def initialize
		end

		def pick_word
			word = File.readlines("5desk.txt").sample 
			@code = word.strip if valid_word?(word) 
		end

		def valid_word?(word)
			if word.length > 4 && word.length < 13 #word valid
				return true
			else
				pick_word
				return false
			end
		end

	end

	class Board
		attr_accessor :number_of_chances, :game_word

		def initialize
			@number_of_chances = 6
			@game_word = ""
			@incorrect_guesses = []
		end

		def draw(player, word)
			display_score(player, word)

			display_word(player, word)

			display_guesses()
		end

		def display_score(player, word)
			get_score_guesses(player, word)
			puts "Total number of chances: 6"
			puts "Number of chances remaining: #{@number_of_chances}"

		end

		def get_score_guesses(player, word)
			@number_of_chances = 6
			@incorrect_guesses = []
			player.guesses.each do |letter|
				if !word.include?(letter)
					@incorrect_guesses << letter
					@number_of_chances -= 1
				end
			end
		end

		def display_word(player, word)
			@game_word = ""
			word.each_char do |letter| 
				if player.guesses.include? (letter)
					@game_word += letter + " "
				else
					@game_word += "__ " 
				end
			end
			puts @game_word
		end

		def display_guesses()
			puts "Incorrect Guesses: "
			puts @incorrect_guesses.inspect
		end

	end

	class Player
		attr_accessor :guesses

		def initialize()
			@guesses = []
		end

		def guess_word()
			puts "\nYour Guess: "
			guess = gets.chomp
			if valid_guess?(guess)
				@guesses << guess.downcase.strip
			end
		end

		def valid_guess?(guess)
			if @guesses.include?(guess.downcase.strip)
				puts "You've already guessed '#{guess}'. Please try another letter."
				guess_word
				return false
			elsif guess.strip.length == 1 && letter?(guess.strip) == 0 
				return true
			else 
				puts "Invalid Guess. Please try again."
				guess_word
				return false
			end
		end

		def letter?(char)
			char =~ /[[:alpha:]]/
		end

	end

	class Computer < Player

	end
end

game = Game.new
game.start