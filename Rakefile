require 'rubygems'


def storageroomkit_version
  return @storageroomkit_version if defined?(@storageroomkit_version) 
  @storageroomkit_version = ENV['VERSION'] || storageroomkit_version_from_file
end

def storageroomkit_version_from_file
  File.read("Code/SRObjectManager.m").each_line do |line|
    if line =~ /#define kCurrentVersion @"(.*)"/
      return $1
    end
  end
  
  nil
end

def apple_doc_command
  "Vendor/appledoc/appledoc -t Vendor/appledoc/Templates -o Docs/API -p StorageRoomKit -v #{storageroomkit_version} -c \"StorageRoomKit\" " +
  "--company-id org.storageroomkit --warn-undocumented-object --warn-undocumented-member  --warn-empty-description  --warn-unknown-directive " +
  "--warn-invalid-crossref --warn-missing-arg --no-repeat-first-par "
end

def run(command, min_exit_status = 0)
  puts "Executing: `#{command}`"
  system(command)
  if $?.exitstatus > min_exit_status
    puts "[!] Failed with exit code #{$?.exitstatus} while running: `#{command}`"
    exit($?.exitstatus)
  end
  return $?.exitstatus
end

desc "Generate documentation via appledoc"
task :docs => 'docs:generate'

namespace :docs do
  task :generate do
    command = apple_doc_command << " --no-create-docset --keep-intermediate-files --create-html Code/"
    run(command, 1)
    puts "Generated HTML documentationa at Docs/API/html"
  end
  
  desc "Check that documentation can be built from the source code via appledoc successfully."
  task :check do
    command = apple_doc_command << " --no-create-html --verbose 5 Code/"
    exitstatus = run(command, 1)
    if exitstatus == 0
      puts "appledoc generation completed successfully!"
    elsif exitstatus == 1
      puts "appledoc generation produced warnings"
    elsif exitstatus == 2
      puts "! appledoc generation encountered an error"
    else
      puts "!! appledoc generation failed with a fatal error"
    end
    
    exit(exitstatus)
  end
  
  desc "Generate & install a docset into Xcode from the current sources"
  task :install do
    command = apple_doc_command << " --install-docset Code/"
    run(command, 1)
  end
  
  # desc "Build and upload the documentation set to the remote server"
  # task :upload do
  #   version = ENV['VERSION'] || File.read("VERSION").chomp
  #   puts "Generating StorageRoomKit docset for version #{version}..."
  #   command = apple_doc_command <<
  #           " --keep-intermediate-files" <<
  #           " --docset-feed-name \"StorageRoomKit #{version} Documentation\"" <<
  #           " --docset-feed-url http://storageroomkit.org/api/%DOCSETATOMFILENAME" <<
  #           " --docset-package-url http://storageroomkit.org/api/%DOCSETPACKAGEFILENAME --publish-docset --verbose 3 Code/"
  #   run(command, 1)
  #   puts "Uploading docset to storageroomkit.org..."
  #   command = "rsync -rvpPe ssh --delete Docs/API/html/ storageroomkit.org:/var/www/public/storageroomkit.org/public/api/#{version}"
  #   run(command)
  #   
  #   if $?.exitstatus == 0
  #     command = "rsync -rvpPe ssh Docs/API/publish/ storageroomkit.org:/var/www/public/storageroomkit.org/public/api/"
  #     run(command)
  #   end
  # end
end

