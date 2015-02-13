require 'socket'
require 'control_helper'

class Control
	extend self

	def do(action: nil,
				 start_command: nil,
				 kill_command: nil,
				 port: nil,
				 app_name: nil,
				 env: nil,
				 app_file_name = nil)

		action 				= action.to_s
		hostname 			= Socket.gethostname

		case action
			when 'start'
				start_actions(hostname, app_name, port, app_file_name)
			when 'stop'
				stop_actions(app_name, port)
			when 'restart'
				restart_actions(hostname, port, app_name, app_file_name)
			else
				raise "action #{action} not implemented"
		end
	end

	def helper
		ControlHelper
	end

	def restart_actions(hostname, port, app_name, app_file_name)
		helper.kill_the_old_process_if_needed(port, app_name, app_file_name)

		new_pid = helper.start_a_new_process!(environment, port, app_file_name)
		helper.check_for_success_in_starting_new_process!(hostname, new_pid)
	end
	def start_actions(hostname, app_name, port, app_file_name)
		helper.exit_if_old_process_is_already_running!(app_name, port)

		new_pid = helper.start_a_new_process!(environment, port, app_file_name)
		helper.check_for_success_in_starting_new_process!(hostname, new_pid)
	end

	def stop_actions(app_name, port)
		old_pid = helper.pull_old_pid_and_exit_if_not_running!(app_name, port)
		helper.kill_the_process!(old_pid)
	end

end  