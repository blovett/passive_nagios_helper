#!/usr/bin/env ruby

# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <ben@biggiantnerds.com> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.
#    - Ben Lovett
# ----------------------------------------------------------------------------

require 'optparse'
require 'yaml'

running_on = %x{uname -m}.chomp
case running_on
  when 'i386', 'i686'
    nagios_path = "/usr/lib/nagios/plugins"
  when 'x86_64'
    nagios_path = "/usr/lib64/nagios/plugins"
  else
    raise "unknown arch #{running_on}"
end

@options = {
  :config => nil,
  :hostname => nil,
  :verbose  => false,
}

OptionParser.new do |opt|
  opt.on("-c", "--config FILE", "Config file") do |o|
    @options[:config] = o
  end
  opt.on("-H", "--hostname HOSTNAME", "Hostname override") do |o|
    @options[:hostname] = o
  end
  opt.on("--verbose", "Be more verbose") do |o|
    @options[:verbose] = true
  end
end.parse!

def verbose(str)
  puts "[#{Time.now}]: #{str}" if @options[:verbose]
end

services = Hash.new
if @options[:config].nil?
  raise "Config file must be passed!"
else
  yaml = YAML.load_file(@options[:config])
  services.merge!(yaml[:services])
  @options.merge!(yaml[:config])
end

if @options[:hostname].nil?
  begin
    require 'facter'
    @options[:hostname] = Facter.hostname
  rescue LoadError
    raise "Unable to load facter, can't determine hostname"
  end
end

success_count=0
fail_count=0

services.each_key do |s|
  verbose "running service check #{s}"

  nagios_wrapper = "#{nagios_path}/nsca_wrapper.sh"

  unless /^\/usr\/lib/.match(services[s][:command])
    command_base = "#{nagios_path}"
  end

  command = "#{command_base}/#{services[s][:command]}"
  unless services[s][:args].nil?
    command = "#{command} #{services[s][:args]}"
  end

  command_opts = ["-H", @options[:hostname],
                  "-N", @options[:nagios],
                  "-S", services[s][:description],
                  "-C", "\'#{command}\'"]
  command_str = "#{nagios_wrapper} #{command_opts.join(" ")}"

  verbose "Running: #{command_str}"
  result = %x{#{command_str}}
  exit_code = $?

  if exit_code.to_i > 0
    STDERR.puts "#{Time.now}: had a problem while running service check #{s}"
    fail_count += 1
  else
    success_count += 1
  end
end

puts "Reporting done. #{success_count} were successful; #{fail_count} failed."
