#!/usr/bin/ruby

@alarm_thread = @timer_thread = Thread.new {}

def start_alarm
  return if @alarm_thread.alive?
  @alarm_thread = Thread.new do
    loop do      
      system "beep -f 5000 -l 300 >/dev/null"
      sleep 1
    end
  end
end

def stop_alarm
  @alarm_thread.kill
end

def log start_date, start_time, end_time
  text = `zenity --entry --title='Toma #{start_time}-#{end_time}' --text='What are you doing?'`
  File.open(ENV['HOME']+"/toma/#{start_date}.log", 'a') do |file|
    file.write "#{start_time}-#{end_time} #{text.split.first}\n"
  end
end

def start_timer delay
  return if @timer_thread.alive?
  @timer_thread = Thread.new do
    stop_alarm
    time = Time.now
    start_date = time.strftime("%Y-%m-%d")
    start_time = time.strftime("%H:%M")
    end_time = (time + delay*60).strftime("%H:%M")
    puts "Delay: #{delay}"
    puts "Start time: \t" + start_time
    puts "End time: \t" + end_time
    sleep delay*60
    start_alarm
    fork { log start_date, start_time, end_time }
  end
end

def stop_timer
  @timer_thread.kill
  sleep 0.1 while @timer_thread.alive?
end

def delay_parser
  delay = @inp.delete("^0-9").to_i
  delay.zero? ? 15 : delay
end

def input
  puts 'Hello!'

  case @inp = gets.chomp
  when /start/
    start_timer delay_parser

  when /stop/
    stop_timer
    puts 'Alarm stopped!'

  when /next/
    stop_timer
    start_timer delay_parser

  when /exit/
    puts 'Good-bye!'
    return false

  when /status/
    puts "Alarm status: \t" + (@alarm_thread.alive? ? 'True' : 'False')
    puts "Timer status: \t" + (@timer_thread.alive? ? 'True' : 'False')
  else
    puts 'Wrong parameter!'
  end while true
end

input
