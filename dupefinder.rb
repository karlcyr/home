#!/usr/bin/ruby
# Check for duplicate files.
# This version will check for all file types including .files (dotfiles).

require 'pathname'
require 'digest'

# Define Statics
debug = (ARGV[1] == 'debug')

pwd = Dir.pwd
starttime = Time.now

arg = ARGV[0] || Dir.pwd
rootpath = Pathname.new(arg).realpath.to_s
puts "Examining #{rootpath}"
Dir.chdir(rootpath)

filemap = Hash.new
dupes = []
filefinder = File.join("./","**","{.*,*}")
files = Dir.glob(filefinder)
print "files.size after collecting files: ", files.size, "\n" if debug

count = 0
files.each{ |file|
	if Pathname.new(file).directory? then next end
	if Pathname.new(file).size > (1024 * 1024 * 100) then 
		print "Refusing to calculate digest of large file: #{file} \n"
		next
	 end
	begin
		md5 = Digest::MD5.file(file).hexdigest
	rescue Exception => e
		print "Digest calculation failed:\n"
		puts e.message
		puts e.backtrace.inspect
		next	
	end

	if filemap.key?(md5) 
		dupe = []
		dupe[0] = filemap.fetch md5
		dupe[1] = file
		dupes.push dupe
	else
		filemap[md5] = file
	end
	count += 1
	print "Processed #{count} files in #{(Time.now-starttime)} seconds.\n" if debug && count%1000==0
}

print "Total Files Scanned: #{count}\n"
print "Unique Files: #{filemap.size}\n"
print "Duplicate Files: #{dupes.size}\n"

outfile = "#{pwd}/duplicates.out"
File.open(outfile,'w') { |output|
	output.write("Duplicates detected in #{pwd}:\n")
	dupes.each { |dupe|
		output.write("#{dupe[0]} |::| #{dupe[1]}\n")
	}
}

print "Refer to duplicates.out for full list of duplicate files\n"
print "Elapsed Time: ", (Time.now - starttime), " in seconds.\n" if debug
