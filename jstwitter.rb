require 'rubygems'
require 'jumpstart_auth'
require 'googl'

class JSTwitter
  attr_accessor :client
  
  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    @followers = @client.follower_ids["ids"]
    @friends = @client.friend_ids["ids"]
  end
  
  def tweet message
    if message.length <= 140
      @client.update message
    else
      puts "Don't you know how to use twitter?"
    end
  end
  
  def run
    puts "Welcome to the DBC Twitter Client!"
    command = ''
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet parts[1..-1].join(" ")
        when 'dm' then direct_message(parts[1],parts[2..-1].join(' '))
        when 'spam' then spam_my_friends(parts[1..-1].join(' '))
        when 'turl' then tweet(parts[1..-2].join(' ') + ' ' + shorten(parts[-1]))
        else 
          puts "Sorry, I dont know how to #{command}."
        end
      end
  end
  
  def direct_message target, message
    puts "Trying to send #{target} this direct messsage:"
    puts message
    begin
      if Twitter.friendship?(target, @client.verify_credentials['screen_name'])
        @client.direct_message_create(target, message)
      else
        puts "You can only message your followers!"
      end
    rescue => msg
      puts "#{msg}"
    end
  end
  
  def followers_list
   screen_names = @followers.map do |id|
     lookup = Twitter.user(id)
     lookup['screen_name']
    end  
  end
  
  def spam_my_friends message
    friends = followers_list
    friends.each do |friend|
      direct_message(friend,message)
    end
  end
  
  def everyones_last_tweet
    unsorted = @friends.map do |friend|
        friend = Twitter.user(friend)
    end
    
    sorted = unsorted.sort_by {|friend| friend.screen_name.downcase}
    
    sorted.each do |pal|
      begin
        time_stamp = pal.status.created_at
        print "#{pal.screen_name} said this on #{time_stamp.strftime("%A, %b %d")}\n"
        print "#{pal.status.text}"
        puts "\n"
      rescue => msg
        puts "#{msg}"
      end
    end
  end
  
  def shorten original_url
    url = Googl::Shorten.new(original_url)
    url.short_url
  end
end

twitter = JSTwitter.new
twitter.run
#twitter.everyones_last_tweet
# text = ''
# until text.length > 140
#   text=text + "abcd"
# end
# #twitter.run
# twitter.followers_list
# 
# url = Googl::Shorten.new('http://www.somefakeurlthatislong.biz')
# puts url.short_url