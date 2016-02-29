require 'active_record'
require 'mysql2'
require 'benchmark'

require_relative 'app/models/unique_key_value'
require_relative 'app/models/simple_key_value'
require_relative 'my_real_transaction'

my_logger = Logger.new('log/experiments.log')
my_logger.level= Logger::DEBUG
ActiveRecord::Base.logger = my_logger
configuration = YAML::load(IO.read('config/database.yml'))
#ActiveRecord::Base.establish_connection(configuration['development'])

#Set the required isolation level
$level = :read_committeddependen

arr = [1,2,4]#,8,16,32,64]
arr.each do |v1|
  timeset = 0.0
  opset = 0
  puts v1

  for k in 1..3
    ActiveRecord::Base.establish_connection(configuration['development'])
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE unique_key_values")

    #print v1
    for i in 1..10
      v1.times do
        Process.fork do
          pk = Process.pid
          sk = UniqueKeyValue.new(key: i, value: "a#{i}a")
          ttkn = Benchmark.realtime {
            sk.save
          }

          fd = File.open("temp_data/tproc_#{pk}.txt","a")
          fd.puts(ttkn)
          fd.close

        end
      end
      Process.waitall
    end

    tval = `./testScript.sh`
    puts tval

    sleep(5)

    # Now catching duplicates
    ActiveRecord::Base.establish_connection(configuration['development'])
    # Command for postgresql
    #dups = ActiveRecord::Base.connection.execute("SELECT key, COUNT(key)-1 FROM unique_key_values GROUP BY key HAVING COUNT(key) > 1")

    # Command for mysql2
    dups = ActiveRecord::Base.connection.execute("SELECT COUNT(U.key) from unique_key_values as U GROUP BY U.key HAVING COUNT(U.key) > 1")

    #sum = 0
    #dups.each do |dp|
    #  count = dp["?column?"]
    #  sum = sum + Integer(count)
    #end

    sum = 0
    dups.each do |dp|
      dp.each do |count|
        sum = sum + Integer(count)
      end
    end

    timeset = timeset + tval.to_f
    opset = opset + sum
  end
  avgdups = opset/3
  avgtime = 0
  avgtime = timeset/(3.0)


  fd = File.open("time_ser_validate_key.txt","a")
  fd.print(v1)
  fd.print("\t")
  fd.print(avgtime)
  fd.puts("")
  fd.close


  # Storing dups count in the file
  fd = File.open("ser_validate_key.txt","a")
  fd.print(v1)
  fd.print("\t")
  fd.print(avgdups)
  fd.puts("")
  fd.close

end
