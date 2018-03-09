class Game
	@@id = 0

	def initialize
		@word_maker = Word.new
		@board = Board.new()
		@player = Player.new()
		@@id += 1
	end

	def start
		print_instructions()
		new_or_save()
		set_word()
		@board.display_word(@player, @word)

		while (!game_over?)
			save_or_guess()
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

	def new_or_save
		puts "Choose your game: "
		puts "1: New Game"
		puts "2: Saved Game"
		get_game()
	end

	def get_game()
		response = gets.chomp
		if (response.strip == "1" || response.downcase.strip == "new game")
		elsif (response.strip == "2" || response.downcase.strip == "saved game")
			load_game()
		elsif (response.strip != "1" || response.downcase.strip != "new game")
			new_or_save()
		end
	end

	def restart()
		@word_maker = Word.new
		@board = Board.new()
		@player = Player.new()

		start()
	end

	def save_or_guess
		puts "To save the current game, type 'save'."
		puts "Your Guess: "
		response = gets.chomp
		if response.downcase.strip == "save"
			save_game()
		else
			@player.guess_word(response)
		end
	end

	#use serialization to save game state
	def save_game
		Dir.mkdir("saved") unless Dir.exists? "saved"
		filename = "saved/game_#{@@id}.json" #save the game object as json/xml with id
		
		File.open(filename, 'w') do |file|
			file.puts #game object serialization
		end
	end

	#method to pick saved game file to open (asks user for filename)
	def choose_saved_game()
		puts "Pick a saved game to load: "
		#print out entries in the directory

		filename = gets.chomp
		#load_game(file) if file_valid
	end

	#use serialization to open up saved game
	def load_game(filename)

	end

	class Word
		attr_accessor :code

		def initialize
		end

		def pick_word
			word = File.readlines("5desk.txt").sample 
			@code = word.strip.downcase if valid_word?(word) 
		end

		def valid_word?(word)
			if word.length > 5 && word.length < 13 #word valid
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

		def guess_word(guess)
			if valid_guess?(guess)
				@guesses << guess.downcase.strip
			end
		end

		def valid_guess?(guess)
			if @guesses.include?(guess.downcase.strip)
				puts "You've already guessed '#{guess}'. Please try another letter."
				response = gets.chomp
				guess_word(response)
				return false
			elsif guess.strip.length == 1 && letter?(guess.strip) == 0 
				return true
			else 
				puts "Invalid Guess. Please try again."
				response = gets.chomp
				guess_word(response)
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