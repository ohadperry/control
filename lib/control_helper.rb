module ControlHelper
	extend self

	def find_app_pid(options)
		pid_filename = options.fetch(Control_P::OPTIONS_ATTRIBUTES[:pid], nil)

		if pid_filename
			get_pid_from_file(pid_filename)
		else
			search_by_string = retreive_search_string(options)
			find_pid_with_ps(search_by_string)
		end
	end
	
	def retreive_search_string(options)
		attributes = Control_P::OPTIONS_ATTRIBUTES
		find_by = options.fetch(attributes[:find_pid_by], Control_P::FIND_BY_OPTIONS[:app_filename])
		#TODO validate find_by is in Control_P::FIND_BY_OPTIONS
		search_string = options.fetch(attributes[find_by], nil)
		raise "no idea how to search for old pid. find_by is #{find_by}" if search_string.nil?

		search_string
	end

	def get_pid_from_file(pid_filename)
		File.open(pid_filename, &:readline).strip
	end
	

	def find_pid_with_ps(search_by_string)
		pid = nil
		procs = `ps aux`

		procs.each_line do |proc|
			if proc.include?(search_by_string)
				res = proc.split(' ')
				old_pid = res[1]
				return old_pid.to_i
			end
		end

		pid
	end

	def exit_if_not_running!(options)
		old_pid = find_app_pid(options)
		unless app_running?(old_pid)
			app_name = options.fetch(Control_P::OPTIONS_ATTRIBUTES[:app_name], '')

			p "app #{app_name} is already NOT running"
			exit(1)
		end

		old_pid
	end

	def app_running?(pid)
		!pid.nil?
	end

	def start_a_new_process!(options)
		attributes = Control_P::OPTIONS_ATTRIBUTES

		start_command = options.fetch(attributes[:start_command])

		p "trying to start a new using  start_command: #{start_command}"

		pid = spawn(start_command)
		Process.detach(pid) if pid
		sleep 5 # give the new app enough time to crash
		find_app_pid(options)
	end

	def exit_if_old_process_is_already_running!(options)
		p 'checking if there\'s a running process'
		old_pid = find_app_pid(options)
		if old_pid
			p "#{app_name} is already running. old_pid is #{old_pid} exiting"
			exit(1)
		end
	end

	def kill_the_process!(options)
		kill_command = options.fetch(Control_P::OPTIONS_ATTRIBUTES[:kill_command])
		`#{kill_command}`
		false
	rescue Errno::ESRCH
		p 'no such process returning true for kill_the_process!'
		true
	rescue => e
		p "error in killing process #{e.inspect}"
	end

	def restart_the_app!(options)
		restart_command = options.fetch(Control_P::OPTIONS_ATTRIBUTES[:restart_command])
		`#{restart_command}`
	end

	def kill_with_retries!(options)
		num_tries = 4
		(1..num_tries).to_a.each do |try|
			res = kill_the_process!(options)
			return true if res
			sleep 5
			old_pid = find_app_pid(options)
			if old_pid
				p "error in kill process #{app_name}. found pid #{old_pid} try number #{try}"
				exit(1) if try == num_tries
			else
				app_name = options.fetch(Control_P::OPTIONS_ATTRIBUTES[:app_name], '')
				p "#{app_name}, it's dead."
				return true
			end
		end
	end

	def check_for_success_in_starting_new_process!(options)
		prefix = "#{Control_P::HOSTNAME}"

		pid = find_app_pid(options)
		if pid
			p "#{prefix} Ok, Restarted. new pid #{pid}"
			exit(0)
		else
			p "#{prefix} problem restarting. Check your code. #{pid}"
			exit(1)
		end
	end

	def kill_the_old_process_if_needed(options)

		old_pid = find_app_pid(options)
		if app_running?(old_pid)
			# TODO should wait ??
			kill_with_retries!(options)
		else
			app_name = options.fetch(Control_P::OPTIONS_ATTRIBUTES[:app_name], '')
			p "There's no app up to restart (#{app_name}), Trying to start a new one.."
			true
		end
	end

end