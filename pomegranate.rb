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

	def self.commits
		log = `git log --pretty=oneline`
		log.split("\n").reverse
	end

	def self.get_source_and_spec
		puts "Name of source file:"
		source = STDIN.gets.chomp

		puts "Name of test file:"
		spec = STDIN.gets.chomp
		return [source, spec]
	end


	def self.new_file result = [], selection = 0, array = self.commits
		source, spec = self.get_source_and_spec
		


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
				instruction = STDIN.gets.chomp
				result << {commit: sha, instruction: instruction, source: source, spec: spec}
				array.delete array[selection]
			when "\r"
				break unless result.empty?
			when 'q'
				exit
			end
		end

		self.write_to_file result
	end

	def self.write_to_file hash
		File.open("pomegranate.json", 'w') do |file|
			file.write JSON.pretty_generate hash
			puts "\n \n Your tutorial steps have been written to the file! \n \n"
		end
	end



	def self.edit_file
		file_hash = JSON.parse( IO.read('pomegranate.json') )
		selection = 0
		steps = file_hash.map { |step| [step["commit"], step["instruction"]] }.map {|step| step.join " " }

		loop do 
			puts "\033c"
			puts "\n Press space to choose a commit to edit, or press 'q' to exit \n \n"
			steps.map! {|step| step == steps[selection] ? step.green : step.black}
			puts steps
			c = self.read_char
			case c
			when "\e[A"
				selection -= 1 unless selection == 0
			when "\e[B"
				selection += 1 unless selection == (steps.length - 1)
			when " "
				puts "Do you want to change your commit? y/n"
				change_commit = STDIN.gets.chomp
				if change_commit == 'y'
					commit_selection = 0
					loop do
						puts "\033c"
						puts "\n Press space to choose a commit or 'q' to exit \n \n"
						array = self.commits
						array.map! { |i| i == array[commit_selection] ? i.green : i.black }
						puts array
						choice = self.read_char
						case choice
						when "\e[A"
							commit_selection -= 1 unless commit_selection == 0
						when "\e[B"
							commit_selection += 1 unless commit_selection == (array.length - 1)
						when " "
							sha = array[commit_selection].uncolorize.split(" ").first
							file_hash[selection]["commit"] = sha
							break
						when 'q'
							break
						end
					end

				end

				puts "\n Do you wish to change your instructions? y/n"
				change_instructions = STDIN.gets.chomp
				if change_instructions == 'y'
					puts "Your previous instructions:"
					puts file_hash[selection]["instruction"]
					puts "\n"

					puts "Write your new instructions below:"
					new_instructions = STDIN.gets.chomp
					file_hash[selection]["instruction"] = new_instructions
				end
			when "\r"
				break
			when 'q'
				exit
			end
		end

		self.write_to_file file_hash

	end























end