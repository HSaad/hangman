require 'json'

class Game
	@@serializer = JSON

	def initialize
		@word_maker = Word.new
		@board = Board.new()
		@player = Player.new()
	end

	def start
		print_instructions()
		new_or_save()
		set_word()

		@board.display_word(@player, @word)

		play()
	end

	def play()
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
			exit
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
			choose_saved_game()
			@board.draw(@player, @word)
			play()
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

	def serialize
		obj = {}
		obj['@word_maker'] = @word_maker.serialize
		obj['@board'] = @board.serialize
		obj['@player'] = @player.serialize
	
		@@serializer.dump obj
	end

	def unserialize(file)
		obj = @@serializer.load(file)

		@word_maker = Word.new
		@word_maker.unserialize(obj['@word_maker'])

		@board = Board.new
		@board.unserialize(obj['@board'])
	
		@player = Player.new
		@player.unserialize(obj['@player'])	

		@word = @word_maker.code
	end

	#use serialization to save game state
	def save_game
		Dir.mkdir("saved") unless Dir.exists? "saved"
		date = Time.new
		filename = "saved/game_#{date}.json".gsub(" ", "_") #save the game object as json using date as uniq id
		
		File.open(filename, 'w') do |file|
			file.puts self.serialize #game object serialization
		end
	end

	#method to pick saved game file to open (asks user for filename)
	def choose_saved_game()
		puts "Pick a saved game to load: "

		if Dir["saved/*"].length == 0
			puts "Sorry there are no saved games"
			set_word()
			@board.display_word(@player, @word)

			play()
		else
			#print out entries in the directory
			Dir["saved/*"].each_with_index do |file, index|
				puts "#{index}: #{file.gsub(".json", "").gsub("saved/", "")}"
			end
		
			filename = gets.chomp
			load_game(Dir["saved/*"][filename.to_i]) if filename_valid(filename)
		end
	end

	def filename_valid(file)
		size = Dir["saved/*"].length
		filename = file.downcase.strip
		if filename.to_i < size && filename.to_i > 0 
			return true
		elsif filename == "0"
			return true
		else
			choose_saved_game()
			return false
		end
	end

	#use serialization to open up saved game
	def load_game(filename)
		File.open(filename, 'r') do |file|
			self.unserialize(file)
		end
	end

	class Word
		attr_accessor :code
		@@serializer = JSON

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
	 	
	 	def serialize
  	  obj = {}
    	instance_variables.map do |var|
     	 obj[var] = instance_variable_get(var)
    	end

    	@@serializer.dump obj
  	end
  	
  	def unserialize(string)
    	obj = @@serializer.parse(string)
    	obj.keys.each do |key|
      	instance_variable_set(key, obj[key])
    	end
  	end

	end

	class Board
		attr_accessor :number_of_chances, :game_word
		@@serializer = JSON

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

		def serialize
  	  obj = {}
    	instance_variables.map do |var|
     	 obj[var] = instance_variable_get(var)
    	end

    	@@serializer.dump obj
  	end
  	
  	def unserialize(string)
    	obj = @@serializer.parse(string)
    	obj.keys.each do |key|
      	instance_variable_set(key, obj[key])
    	end
  	end
	end

	class Player
		attr_accessor :guesses
		@@serializer = JSON

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

		def serialize
  	  obj = {}
    	instance_variables.map do |var|
     	 obj[var] = instance_variable_get(var)
    	end

    	@@serializer.dump obj
  	end
  	
  	def unserialize(string)
    	obj = @@serializer.parse(string)
    	obj.keys.each do |key|
      	instance_variable_set(key, obj[key])
    	end
  	end

	end
end

game = Game.new
game.start