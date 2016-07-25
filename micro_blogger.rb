require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Warning: Message longer than 140 characters!"
    end
  end

  def run
    puts "Welcome to the Twitter Bot Client"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then dm_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        when 's' then shorten(parts[1..-1].join("").strip)
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]).strip)
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name}
    if screen_names.include?(target)
      tweet(message)
    else
      puts "Error: You can only direct message people who follow you."
    end
  end

  def followers_list
    screen_names = []
    @client.followers.collect do |follower| 
      screen_names << @client.user(follower).screen_name
    end
    screen_names
  end

  def dm_my_followers(message)
    screen_names = followers_list
    screen_names.each do |follower|
      dm(follower, message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends
    friends.sort_by do |friend|
      friend.screen_name.downcase
    end
    friends.each do |friend|
      timestamp = friend.status.created_at
      last_tweet = friend.status.text
      friend_name = friend.screen_name
      puts "#{friend_name} said this at #{timestamp.strftime("%A, %b %d")}"
      puts "#{last_tweet}"
      puts ""
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    shorter = bitly.shorten(original_url).short_url
    puts shorter
    shorter
  end

end

blogger = MicroBlogger.new
blogger.run