#!/usr/bin/ruby
require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"


%w[rubygems looksee/shortcuts wirble].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end


def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end


def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end

def did *args
  require 'thor'
  load File.expand_path('~/dotfiles/thor/did.thor')
  @did ||= Did.new
end
load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']
IRB.conf[:IRB_NAME] = `hostname`.strip
IRB.conf[:PROMPT][:HOSTED] = {:PROMPT_I => "%N> ", :RETURN=>"=> %s\n", :PROMPT_N=>"%N> ", :PROMPT_S=>nil, :PROMPT_C=>"?> " }
IRB.conf[:PROMPT_MODE] = :HOSTED
