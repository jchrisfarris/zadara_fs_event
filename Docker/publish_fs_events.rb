#!/usr/bin/ruby
#
#
require 'aws-sdk'
require 'open3'

# Things we need to get passed in
SNS_Target_ARN, *DIRS = ARGV

mydirs=""
DIRS.each do |d|
  mydirs = mydirs + " " + d
end

# Assumes EC2 IAM role
@sns = Aws::SNS::Client.new()

def process_event(event) 
  timestamp, filename, event_types = event.split(':')
  event_types.split(',').each do |t|
    send_message(filename, t, timestamp)
  end
end


def send_message(file, event, timestamp)
  begin
    resp = @sns.publish({
      target_arn: SNS_Target_ARN,
      message: "{ \"filename\": \"#{file}\", \"event\": \"#{event}\", \"timestamp\": \"#{timestamp}\" }",
    })
    # puts resp.inspect
  rescue Exception => e
    puts "ERROR: #{e.message}"
    exit 1
  end
end


# These are inotifywait formatting paramaters
TIMEFMT="%s"
FMT="%T:%w%f:%e"
EVENTS="close_write,moved_to,create,moved_from,delete"
# sudo inotifywait -m -e $EVENTS --timefmt "$TIMEFMT" --format "$FMT" $DIRS

COMMAND="inotifywait -m -e " + EVENTS + " --timefmt " + TIMEFMT + " --format " + FMT + " " + mydirs
puts "Command: " + COMMAND

# Open the shell script to watch for events 
Open3.popen3(COMMAND) do |i,o,e,t |
  while line=o.gets do
    line.chomp!
    puts "got: " + line
    process_event(line)
  end
end
   
exit


