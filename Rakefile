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


desc 'Run specs'
task :spec do
  sh 'rspec -c'
end

desc 'Run specs verbosely'
task 'spec:verbose' do
  sh 'rspec -cfd'
end

desc 'Run specs verbosely, view w/ less'
task 'spec:less' do
  sh 'rspec -cfd --tty | less -R'
end

desc 'Run cucumber & specs w/ coverage'
task :coverage do
  ENV['COVERAGE'] = 'yes'
  Rake::Task['cuke'].execute
  Rake::Task['spec'].execute
end


desc 'Check for warnings'
task :warn do
  sh 'ruby -w -I lib -r siresta -e ""'  # TODO
end

desc 'Check for warnings in specs'
task 'warn:spec' do
  reqs = Dir['spec/**/*.rb'].sort.map { |x| "-r ./#{x}" } * ' '
  sh "ruby -w -I lib -r rspec #{reqs} -e ''"
end

desc 'Check for warnings in specs (but not void context)'
task 'warn:spec:novoid' do
  sh 'rake warn:spec 2>&1 | grep -v "void context"'
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
  sh 'rm -rf .yardoc/ doc/ examples/*/html/*.js *.gem examples/*/db/*.sqlite3'
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
