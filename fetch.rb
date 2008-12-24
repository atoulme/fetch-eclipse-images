if ($*.include? "-h" or $*.include? "--help" or $*.include? "-help" or $*.size != 1)
  puts <<-HELP
  fetch.rb, an image fetcher on all Eclipse repositories
  USAGE: ruby fetch.rb destination_folder
HELP
  exit
end

require "ftools"
require 'yaml'
destination = $*[0]
File.makedirs destination or fail "No access to destination"
IMAGE_FILE_EXTENSIONS = ["png", "gif", "bmp", "jpg", "jpeg", "ico"]

# Copied from http://extensions.rubyforge.org/rdoc/classes/String.html#M000035
def ends_with?(str)
  str = str.to_str
  tail = self[-str.length, str.length]
  tail == str      
end

def get_svn_repository_contents(url)
  puts "Starting to get repository contents #{url}"
  return `svn list -R #{url}`.split("\n") or fail("Failed fetching SVN contents from #{url}")
  puts "Done getting repository contents #{url}"
end

def get_cvs_repository_contents(url)
  puts "Starting to get repository contents #{url}"
  system("cvs -d #{url}) or fail("Failed fetching CVS contents from #{url}")
  
end

def fetch_svn(repo, relative_file_url, destination)
  puts "Downloading #{repo}/#{relative_file_url}"
  system("svn co #{repo}/#{relative_file_url} #{destination}")
end

def fetch_cvs(repo, absolute_file_url, destination)
  raise "Not implemented yet"
end


info = YAML::load_file("#{File.dirname(__FILE__)}/repos.yaml")
info.each_pair {|repo_type, repos|
  repos.each {|repo|
    content_list = case repo_type
      when "CVS": get_cvs_repository_contents(repo)
      when "SVN": get_svn_repository_contents(repo)
      else
        raise "Cannot work with that type of repository: #{repo_type}"
      end
    content_list.each {|content|
      IMAGE_FILE_EXTENSIONS.each {|extension|
        if content.ends_with? extension
          case repo_type
            when "CVS": fetch_cvs(repo, content, destination)
            when "SVN": fetch_svn(repo, content, destination)
            else
              raise "Cannot work with that type of repository: #{repo_type}"
          end
        end
      }
    }
  }
}

  
