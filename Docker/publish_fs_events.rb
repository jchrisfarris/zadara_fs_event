#!/usr/bin/ruby
#
#
require 'aws-sdk'
#require 'rb-inotify'
require 'open3'


CloudMAS_ARN="arn:aws:sns:us-east-1:682036268439:CloudMAS"
# Assumes EC2 IAM role
@sns = Aws::SNS::Client.new(region: 'us-east-1')

def process_event(event) 
  timestamp, filename, event_types = event.split(':')
  event_types.split(',').each do |t|
    send_message(filename, t, timestamp)
  end
end


def send_message(file, event, timestamp)
  resp = @sns.publish({
    target_arn: CloudMAS_ARN,
    message: "{ filename: \"#{file}\", event: \"#{event}\", timestamp: \"#{timestamp}\" }",
    subject: "#{event} on #{file}",
    message_structure: "I dont know waht a message struct is",
  })
  puts resp.inspect
end


# TIMEFMT="%s"
# FMT="%T:%w%f:%e"
# sudo inotifywait -m -e $EVENTS --timefmt "$TIMEFMT" --format "$FMT" $DIRS

# Open the shell script to watch for events 
Open3.popen3("/home/ec2-user/start_inotify.sh") do |i,o,e,t |
  while line=o.gets do
    puts "got: " + line
    process_event(line)
  end
end
   
exit


