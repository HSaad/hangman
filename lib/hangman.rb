class Game

	def initialize
		@word = Word.new
		@board = Board.new()
		@player = Player.new()
		@game_state = []
	end

	def start
		print_instructions()
		@board.draw(@game_state)
		puts @word.code

	end

	def print_instructions()
		puts "Welcome to Hangman!"

		puts "To win, you must find the hidden word by guessing a letter each turn."
		puts "You'll have 7 turns to guess the word."
	end

	def save_game
		Dir.mkdir("saved") unless Dir.exists? "saved"
		filename = "saved/" #save the game object as json/xml
	end

	class Word
		attr_accessor :code

		def initialize
			pick_word
		end

		def pick_word
			word = File.readlines("5desk.txt").sample 
			@code = word if valid_word?(word) 
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

		def initialize
		end

		def draw(game_state)
		end

	end

	class Player

	end

	class Computer < Player

	end
end

game = Game.new
game.start