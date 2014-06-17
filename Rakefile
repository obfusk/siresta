cuke = ENV['CUKE']

desc 'Run cucumber'
task :cuke do
  sh "cucumber -fprogress #{cuke}"
end

desc 'Run cucumber strictly'
task 'cuke:strict' do
  sh "cucumber -fprogress -S #{cuke}"
end

desc 'Run cucumber verbosely'
task 'cuke:verbose' do
  sh "cucumber #{cuke}"
end

desc 'Run cucumber verbosely, view w/ less'
task 'cuke:less' do
  sh "cucumber -c #{cuke} | less -R"
end

desc 'Cucumber step defs'
task 'cuke:steps' do
  sh 'cucumber -c -fstepdefs | less -R'
end


desc 'Check for warnings'
task :warn do
  sh 'ruby -w -I lib -r siresta -e ""'  # TODO
end


desc 'Generate docs'
task :docs do
  sh 'yardoc | cat'
end

desc 'List undocumented objects'
task 'docs:undoc' do
  sh 'yard stats --list-undoc'
end


desc 'Cleanup'
task :clean do
  sh 'rm -rf .yardoc/ doc/ *.gem example/*/db/*.sqlite3'
end


desc 'Build SNAPSHOT gem'
task :snapshot do
  v = Time.new.strftime '%Y%m%d%H%M%S'
  f = 'lib/siresta/version.rb'
  sh "sed -ri~ 's!(SNAPSHOT)!\\1.#{v}!' #{f}"
  sh 'gem build siresta.gemspec'
end

desc 'Undo SNAPSHOT gem'
task 'snapshot:undo' do
  sh 'git checkout -- lib/siresta/version.rb'
end
