# frozen_string_literal: true

require 'fileutils'

namespace :glpk do
  desc 'Download, build, and install GLPK'
  task :install do
    app_root = Rails.root.to_s

    # Download and untar source
    unless Dir.exist?('glpk-5.0')
      system('wget https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz')
      system('tar -xzf glpk-5.0.tar.gz')
      File.delete('glpk-5.0.tar.gz')
    end

    # Build and install GLPK
    Dir.chdir('glpk-5.0') do
      system("./configure --prefix=#{app_root}")
      system('make -j4') # Can use make -j to run faster
      system('make install')
    end

    puts '------------------------------------------------------------'
    puts 'GLPK install complete'
  end

  desc 'Uninstall GLPK'
  task :uninstall do
    app_root = Rails.root.to_s
    if Dir.exist?('glpk-5.0')
      Dir.chdir('glpk-5.0')
      system('make uninstall')
      Dir.chdir('..')
      FileUtils.remove_dir('glpk-5.0')
    else
      puts "Can't find glpk source directory within #{app_root}"
    end
  end
end
