class RunBackups
  require 'yaml'
  TARGETS = 'BACKUP.yml' # default list of remote directories to backup
  BACKUP_DIR = '.'
  LOG_FILE = './backup.log'

  def log(message, failed = false)
    # a lot of opening and closing but nbd for this application
    File.open(LOG_FILE, 'a'){ |file|
      unless failed
        file.puts "#{Time.now}: #{message}"
      else
        file.puts "#{Time.now}: FAILED: #{message}"
        file.puts "REASON: #{failed}"
      end
    }
  rescue
    $stderr.puts 'ERROR: faiure in logger (backup.rb)'
    exit 5
  end

  def run(command)
    # log command
    responce = `#{command} 2>&1`
    if $?.to_i != 0 # error!
      log command, responce
      $stderr.puts 'ERROR: faiure in backup.rb:'
      $stderr.puts "FAILED: #{command}"
      $stderr.puts "RETURNED: #{responce}"
      exit 5
    end
  end
  
  def initialize(targets = TARGETS)
    log 'Hello, backup.rb starting up'
    @y = YAML.load_file targets
    @y.each{ |t|
      host = t[0]
      opts = t[1]
      port = opts['port'] ? opts['port'] : '22'
      ssh_opts = "--rsh='ssh -x -p #{ port }'"
      log "syncing from #{host}"    
      for dir in opts['dirs'].split(' ')
        run "mkdir -p #{BACKUP_DIR}/#{host}#{dir}"
        p rsync = "rsync -az --delete #{ssh_opts} #{opts['login']}@#{host}:#{dir}/ #{BACKUP_DIR}/#{host}#{dir}"
        run rsync
      end
      p rdiff = "rdiff-backup #{host} #{host}.rdiff-backup"
      run rdiff
    }
    log 'backup.rb finished'
  end
end

if ARGV[0]
  RunBackups.new(ARGV[0])
else
  RunBackups.new
end
