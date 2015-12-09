require 'socket'
require 'control_helper'
require 'active_support/core_ext/hash/indifferent_access'

class Control_P
	OPTIONS_ATTRIBUTES = {action: 'action', pid_filename: 'pid_filename', find_pid_by: 'find_pid_by',
							app_name: 'app_name', port_num: 'port_num', app_filename: 'app_filename',
							http_server: 'http_server', kill_command: 'kill_command',
							restart_command: 'restart_command', environment: 'environment',
							start_command: 'start_command', skip_workers_message: 'skip_workers_message'}.with_indifferent_access

	FIND_BY_OPTIONS = {app_filename: 'app_filename', port_num: 'port_num', app_name: 'app_name', pid_file: 'pid_file'}.with_indifferent_access
	WORKERS_STARTED_EXTENSION = '*.started'
	WORKERS_CLOSED_EXTENSION = '*.closed'

	HOSTNAME = Socket.gethostname

	# Main Method for all actions
	def self.do(options)
		options = options.with_indifferent_access
		#TODO options validations
		action 				= options.fetch(OPTIONS_ATTRIBUTES[:action], nil)
		environment 	= options.fetch(OPTIONS_ATTRIBUTES[:environment], nil)

		if action.nil? || environment.nil?
			p "didn't pass enough arguments"
			p 'Usage: {start|stop|restart|status} {env}, exiting'
			exit(1)
		end

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
		# drom some reason the remote ssh is not exiting, making sure it exit here
		exit(0)
	end

	def self.helper
		ControlHelper
	end

	def self.restart_actions(options)

		http_server = options.fetch(OPTIONS_ATTRIBUTES[:http_server], false)

		#means it's seamless, just need to send a kill signal and it will restart it self
		if http_server
			helper.restart_the_app!(options)
			sleep(5)
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

