class ED
	def initialize
		@file_name = ARGV[0]
		begin
			open(@file_name) do |file| @buffer = file.readlines end
			p @buffer
		rescue
			puts '開けない'
			exit
		end
		@current = 1
		loop {
			edRead
			edEval
			@addr1 = @addr2 = @cmd = @prmt = nil
		}
	end

	def edRead
		@line = STDIN.gets.chop
		#		sleep 100
	end

	def edEval
		r_addr = '\d+|[.,;$]'; r_cmd = 'wq|[apnqcidjng=]'; r_prmt = '.*'
		if @line =~ /^(?:(#{r_addr})(?:,(#{r_addr})?)?)?(#{r_cmd})?(#{r_prmt})?$/
			puts "#{$1} #{$2} #{$3} #{$4}"
			@cmd = $3; @prmt = $4
			setAddr($1, $2)
			send "command_#{cmd}"
		else
			puts '?'
		end
	end

	def changeAddr(idx)
		addr = "@addr#{idx}"
		unless instance_variable_get(addr).nil?
			case instance_variable_get(addr)
			when '.'
				instance_variable_set(addr, @current)
			when ','
				@addr1 = 0
				@addr2 = last_idx
				@current = @addr2
			when ';'
				@addr1 = @current
				@addr2 = last_idx
				@current = @addr2
			when '$'
				instance_variable_set(addr, last_idx)
				@current = last_idx
			end
			#						puts "sf #{@addr1} #{@addr2}"
		end
	end

	def command_d
		if @addr1.nil?
			@buffer.delete_at @current
		elsif @addr2.nil?
			@buffer.delete_at @addr1
			@current = @addr1
		else
			@buffer.slice! @addr1..@addr2
			@current = @addr1
		end
	end

	def integer_string?(str)
		Integer(str)
		true
	rescue ArgumentError
		false
	end

	def next_idx(idx)
		idx + 1
	end

	def previous_idx(idx)
		idx - 1
	end


	def last_idx
		@buffer.size - 1
	end
	def edit_mode
		strs = []
		while (str = STDIN.gets.chop) != '.'
			strs.push str
		end
		strs
	end

	def command_a
		strs = edit_mode
		if @addr1.nil?
			@buffer.insert next_idx(@current), strs
		elsif @addr2.nil?
			@buffer.insert next_idx(@addr1), strs
		else
			@buffer.insert next_idx(@addr2), strs
		end
	end

	def command_i
		strs = edit_mode
		if @addr1.nil?
			@buffer.insert @current, strs
		elsif @addr2.nil?
			@buffer.insert @addr1, strs
		else
			@buffer.insert @addr2, strs
		end
	end

	def command_c
		command_d
		strs = edit_mode
		@buffer.insert next_idx(@current), strs
	end

	def command_g
		if @prmt.nil?
			puts '?'
			return
		end
		if @prmt =~ /\/(.*)\/(.*)/
			g_reg = $1
			cmd_list = $2
			start = @addr1; finish = @addr2
			@buffer[start..finish].each_with_index do |line, idx|
				@addr1 = @addr2 = idx
				if line =~ g_reg
					cmd_list.each do |cmd|
						send "command_#{cmd}"
					end
				end
			end
		end
	end

	def command_j
		join = buffer[@attr1..@attr2].join ''
		command_d
		@buffer.insert @current, join
	end

	def command_n
		unless @addr1.nil?
			changeAddr 1
			if @addr2.nil?
				puts "#{@addr1} #{@buffer[@addr1]}"
			else
				changeAddr 2
				@addr1..@addr2.times do |idx|
					puts "#{idx} #{@buffer[idx]}"
				end
			end
		end
	end

	def command_p
		#						puts "sf #{@addr1} #{@addr2}"
		unless @addr1.nil?
			changeAddr 1
			if @addr2.nil?
				puts @buffer[@addr1]
			else
				changeAddr 2
				@addr1..@addr2.times do |idx|
					puts @buffer[idx]
				end
			end
		end
	end

	def command_q
		exit
	end

	def command_w
		exit
	end

	def command_w
		open(@file_name, 'w') do |file|
			file.write @buffer
		end
	end

	def command_w
		command_w
		command_q
	end

	def command_=

		puts @addr1.nil? ? @buffer[last_idx] : @current
	end

	def command_
		if @addr1.nil?
			if (idx = @current + 1) > last_idx
				@current = idx
			else
				puts '?'
			end
		end
		puts @buffer[@current]
	end

	def setAddr(addr1, addr2)
		unless addr1.nil?
			if integer_string?(@addr1)
				@current = @addr1 = addr1.to_i - 1
			else
				changeAddr 1
			end
			unless addr2.nil?
				if integer_string?(@addr2)
					@current = @addr2 = addr2.to_i - 1
				else
					changeAddr 2
				end
			end
			if @addr1 > last_idx || @addr2 > last_idx
				puts '?'
				return
			end
		end
	end
end
ED.new
