require 'io/console'
require 'colorize'
require 'json'

class Pomegranate

	def self.read_char
	  begin
	    old_state = `stty -g`
	    system "stty raw -echo"
	    c = STDIN.getc.chr
	    if(c=="\e")
	      extra_thread = Thread.new{
	        c = c + STDIN.getc.chr
	        c = c + STDIN.getc.chr
	      }
	      extra_thread.join(0.00001)
	      extra_thread.kill
	    end
	  rescue => ex
	    puts "#{ex.class}: #{ex.message}"
	    puts ex.backtrace
	  ensure
	    system "stty #{old_state}"
	  end
	  return c
	end


	def self.new_file
		log = `git log --pretty=oneline`

		array = log.split("\n").reverse

		selection = 0

		result = []

		puts "Name of source file:"
		source = gets.chomp

		puts "Name of test file:"
		spec = gets.chomp

		loop do
			puts "\033c"
			puts "\n Press space to choose a commit and fill in your instructions to the user, or 'q' to exit \n \n"

			array.map! { |i| i == array[selection] ? i.green : i.black }
			puts array
			c = self.read_char
			case c
			when "\e[A"
				selection -= 1 unless selection == 0
			when "\e[B"
				selection += 1 unless selection == (array.length - 1)
			when " "
				sha = array[selection].uncolorize.split(" ").first
				puts "\n \n Instructions: \n \n"
				instruction = gets.chomp
				result << {commit: sha, instruction: instruction, source: source, spec: spec}
				array.delete array[selection]
			when "\r"
				break unless result.empty?
			when 'q'
				exit
			end
		end

		File.open("pomegranate.json", 'w') do |file|
			file.write JSON.pretty_generate result
			puts "\n \n Your tutorial steps have been written to the file! \n \n"
		end
	end
end