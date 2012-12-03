#!/usr/bin/ruby

# Check the status of each of the photo directories and print out basic stats.

# Define Statics
debug = false

puts Dir.pwd if debug 

filestats = []  
Dir.foreach(Dir.pwd) do |picdir|
	if picdir =~ /^20.*/
		# pro tip: find valid file extensions with 'find . | rev | cut -b-3 | rev | sort | uniq -d'
		# I test these sections with find . | grep -i jpg | wc -l & find . | grep -iv jpg | wc -l
		
		picdirstats = []
		picdirstats.push picdir
		jpgfinder = File.join("./",picdir,"**","{.*,*}.{jpg,JPG,img,IMG,gif,GIF}")
		vidfinder = File.join("./",picdir,"**","{.*,*}.{mp4,MP4,mov,MOV,mpg,MPG,mpeg,MPEG}")
		
		picdirstats.push Dir.glob(jpgfinder).size
		picdirstats.push Dir.glob(vidfinder).size
		
		filestats.push picdirstats
	end

end

filestats.sort! 

print "Year \tPics \tVids \n"
filestats.each { |pds|
	print pds[0], "\t", pds[1], "\t", pds[2], "\n"
}


