#!/usr/bin/ruby

# Check for duplicate image and video files

# Define Statics
debug = true

puts Dir.pwd if debug 
starttime = Time.now

# store entries for all files in the Pictures subdirectory with md5sum as key and filename as value.
filemap = Hash.new
dupes = []
filefinder = File.join("./","**","{.*,*}.{jpg,JPG,img,IMG,gif,GIF,mp4,MP4,mov,MOV,mpg,MPG,mpeg,MPEG}")
files = Dir.glob(filefinder)
puts "files.size after collecting files: ", files.size if debug

files.each{ |file|
	#http://developers.appoxy.com/2010/05/md5-hash-of-file-in-ruby.html
	md5 = Digest::MD5.file(file).hexdigest
	if filemap.key?(md5) 
		dupe = []
		dupe[0] = filemap.fetch md5
		dupe[1] = file
		dupes.push dupe
	else
		filemap[md5] = file
	end
	
}

puts "filemap.size after processing: ", filemap.size if debug
puts "dupes.size: ", dupes.size if debug

File.open('duplicates.out','w') { |output|
	output.write(dupe.inspect)
}

puts "Elapsed Time: ", (Time.now - starttime), " in seconds." if debug