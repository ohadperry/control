class Control

	def initialize(start_command: nil, kill_command: nil, port: nil, app_name: nil)
		@start_command 	= start_command
		@kill_command 	= kill_command
		@port 			= port
		@app_name 		= app_name
	end

	def do(action)
		action = action.to_s
		case action
		when 'start'
			exit_if_old_process_is_already_running!(APP_NAME, PORT_NUM)

			new_pid = start_a_new_process!(ENVIRONMENT, PORT_NUM, APP_FILE_NAME)
			check_for_success_in_starting_new_process!(hostname, new_pid)

		when 'stop'

			old_pid = pull_old_pid_and_exit_if_not_running!(APP_NAME, PORT_NUM)
			kill_the_process!(old_pid)

		when 'restart'

			kill_the_old_process_if_needed(PORT_NUM, APP_NAME, APP_FILE_NAME)

			new_pid = start_a_new_process!(ENVIRONMENT, PORT_NUM, APP_FILE_NAME)
			check_for_success_in_starting_new_process!(hostname, new_pid)

		else
			raise "action #{action} not implemnted"	


		end
	end
end  