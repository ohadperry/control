module ControlHelper
	extend self
# todo find a better way to find the pid , there might be two process
def find_app_pid(port_num = nil)
	pid = nil
	procs = `ps aux`

	procs.each_line do |proc|
		if proc.include?(port_num)
			res = proc.split(' ')
			old_pid = res[1]
			return old_pid.to_i
		end
	end

	pid
end

def pull_old_pid_and_exit_if_not_running!(app_name, port_num)
	old_pid = find_app_pid(port_num)
	unless app_running?(old_pid)
		p "app #{app_name} is already NOT running"
		exit(1)
	end

	old_pid
end

def app_running?(pid)
	!pid.nil?
end

def start_a_new_process!(environment, port_num, app_file_name)
	p "trying to start a new one in port #{port_num}"
  # command = "bundle exec shotgun -E #{environment} --port=#{port_num} config.ru"
  p "dir is #{Dir.pwd}"
  command = "cd #{Dir.pwd}; sudo pip install -r requirements.txt; nohup python #{app_file_name} #{environment} &"
  # command = "echo '1'"
  pid = spawn(command)
  Process.detach(pid) if pid
  sleep 5 # give the new app enough time to crash
  find_app_pid(app_file_name)
end

def exit_if_old_process_is_already_running!(app_name, port_num)
	p 'checking if there\'s a running process'
	old_pid = find_app_pid(port_num)
	if old_pid
		p "#{app_name} is already running. old_pid is #{old_pid} exiting"
		exit(1)
	end
end

def kill_the_process!(app_name)
	`pkill -f #{app_name}`
  #Process.kill('SIGINT', pid)
  false
rescue Errno::ESRCH
	p 'no such process returning true for kill_the_process!'
	true
rescue => e
	p "error in killing process #{e.inspect}"
end

def kill_with_retries!(pid, app_name)
	num_tries = 4
	(1..num_tries).to_a.each do |try|
		res = kill_the_process!(app_name)
		return true if res
		sleep 5
		old_pid = find_app_pid(app_name)
		if old_pid
			p "error in kill process #{app_name}. found pid #{old_pid} try number #{try}"
			exit(1) if try == num_tries
		else
			p "#{app_name}, it's dead."
			return true
		end
	end

end


def check_for_success_in_starting_new_process!(hostname, pid)
	if pid
		p "[#{hostname}] Ok, Restarted. new pid #{pid}"
		exit(0)
	else
		p "[#{hostname}] problem restarting. Check your code. #{pid}"
		exit(1)
	end
end

def kill_the_old_process_if_needed(port_num, app_name, specific_file_name = nil)
	find_by = specific_file_name ? specific_file_name : port_num
	old_pid = find_app_pid(find_by)
	if app_running?(old_pid)
    # TODO should wait ??
    kill_with_retries!(old_pid, app_name)
else
	p "There's no app up to restart (#{app_name}), Trying to start a new one.."
	true
end
end

end