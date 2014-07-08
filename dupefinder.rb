#!/usr/bin/ruby
# Check for duplicate files.
# This version will check for all file types including .files (dotfiles).

require 'thor'
require 'pathname'
require 'digest'
require 'fileutils'

class DupeFinder < Thor		
	class_option :verbose, :type => :boolean, :aliases => :v

	desc 'display DIR', 'print out the duplicates contained in DIR'
        long_desc <<-LONGDESC
	  Print out the duplicates contained in DIR to a file named duplicates.out. 
	 
	  Files over 100 MB are excluded from comparison for performance reasons.
	LONGDESC
	def display(directory=nil)
		directory = Dir.pwd if !directory
			
		dupes = find_dupes(directory)

		outfile = "#{Dir.pwd}/duplicates.out"
		File.open(outfile,'w') { |output|
			output.write("Duplicates detected in #{directory}:\n")
			dupes.each { |dupe|
				output.write("#{dupe[0]} |::| #{dupe[1]}\n")
			}
		}

		print "Refer to duplicates.out for full list of duplicate files\n"
	end #display

	desc 'dedupe DIR', 'find and remove duplicate files contained in DIR'
	long_desc <<-LONGDESC
	  Find and remove duplicate files contained in DIR. Comparisons are made using a md5 hash of the file contents so collisions are possible but extremely unlikely. 

	  With --safe/-s option, dedupe performs a safe removal. Duplicated files are copied to a directory for review. This is the default option; only with --safe false will
          dedupe remove files. 

	  With --target/-t option, dedupe copies files to target directory during a safe removal. 

    	  Files over 100 MB are excluded from comparison for performance reasons.
	LONGDESC
	option :safe, :type => :boolean, :default => :true,  :aliases => :s
	option :target, :type => :string, :aliases => :t
	def dedupe(directory)
		directory = Dir.pwd if !directory

		dupes = find_dupes(directory)

		if options[:target]
			dupedir = options[:target]
		else
			dupedir = "dupes"
		end
		if !File.exists?(dupedir)
			puts "creating #{dupedir}"
			FileUtils.mkdir dupedir
		end
		
		dupes.each { |dupe|
			if options[:verbose]
				FileUtils.mv(dupe[1], dupedir, :force => true, :verbose => true)
			else
				FileUtils.mv(dupe[1], dupedir, :force => true)
			end
		}

		puts "#{dupes.size} duplicate files moved from #{directory} to #{dupedir}"	
	end #dedupe

	no_commands do
		def log(str)
			puts str if options[:verbose]
		end

		def find_dupes(directory)
			pwd = Dir.pwd
			starttime = Time.now

			arg = directory || Dir.pwd
			rootpath = Pathname.new(arg).realpath.to_s
			puts "Examining #{rootpath}"
			Dir.chdir(rootpath)

			filemap = Hash.new
			dupes = []
			filefinder = File.join("./","**","{.*,*}")
			files = Dir.glob(filefinder)
			log ( "files.size after collecting files: #{files.size}" )

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
				log ("Processed #{count} files in #{(Time.now-starttime)} seconds.") if count%1000==0
			}

			print "Total Files Scanned: #{count}\n"
			print "Unique Files: #{filemap.size}\n"
			print "Duplicate Files: #{dupes.size}\n"

			log ( "Elapsed Time: #{(Time.now - starttime)} in seconds.")

			return dupes
		end #find_dupes
	end
end

DupeFinder.start
