require 'socket'
require 'control_helper'
require 'active_support/core_ext/hash/indifferent_access'

class Control_P
	OPTIONS_ATTRIBUTES = {action: 'action', pid: 'pid_filename', find_pid_by: 'find_pid_by',
												app_name: 'app_name', port_num: 'port_num', app_filename: 'app_filename',
												http_server: 'http_server', kill_command: 'kill_command',
												restart_command: 'restart_command', start_command: 'start_command'}.with_indifferent_access

	FIND_BY_OPTIONS = {app_filename: 'app_filename', port_num: 'port_num', app_name: 'app_name', pid_file: 'pid_file'}.with_indifferent_access
	HOSTNAME = Socket.gethostname

	# Main Method for all actions
	def self.do(options)
		options = options.with_indifferent_access
		#TODO options validations
		action 				= options.fetch(OPTIONS_ATTRIBUTES[:action], nil)

		case action
			when 'start'
				start_actions(options)
			when 'stop'
				stop_actions(options)
			when 'restart'
				restart_actions(options)
			else
				raise "action #{action} not implemented"
		end
	end

	def self.helper
		ControlHelper
	end

	def self.restart_actions(options)

		http_server = options.fetch(OPTIONS_ATTRIBUTES[:http_server], false)

		#means it's seamless, just need to send a kill signal and it will restart it self
		if http_server
			helper.restart_the_app!(options)
		else
			helper.kill_the_old_process_if_needed(options)
			helper.start_a_new_process!(options)
		end

		helper.check_for_success_in_starting_new_process!(options)
	end

	def self.start_actions(options)
		helper.exit_if_old_process_is_already_running!(options)

		helper.start_a_new_process!(options)
		helper.check_for_success_in_starting_new_process!(options)
	end

	def self.stop_actions(options)
		helper.exit_if_not_running!(options)

		helper.kill_the_process!(options)
	end

end