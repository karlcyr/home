#!/usr/bin/ruby

require 'FileUtils'

# Backup the iPhoto Library on this computer to a backup Volume.
# Getting the year right depends on mtime being reliable, which, of course, it is not. We'll assume the mtime of the original file is correct. 

sourcedir = '/Users/karl.cyr/Pictures/iPhoto Library.photolibrary/Masters/'
destinationdir = '/Volumes/My Book/Pictures/'

Dir.chdir(sourcedir)

print Dir.pwd, "\n"

filefinder = File.join("./","**","*.*")
files = Dir.glob(filefinder)
print "files.size after collecting files: ", files.size, "\n"

copycount = 0
files.each{ |file|

	destfile = File.join(destinationdir, "#{File.mtime(file).year}", File.basename(file))
  	if !File.exists?(destfile)		
		print "Attempting copy of: ", destfile, "\n"
		#preserve flag here will ensure that the original mtime is retained. 
		FileUtils.cp(file, destfile, :verbose => true, :preserve => true, :verbose => true)
		copycount += 1
	end	
	
}

print "Total files scanned: ", files.size, "\n"
print "Total files copied: ", copycount, "\n"
