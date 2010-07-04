
namespace :raid do
  desc "build with sdb1 and sdc1"
  task :buildraid1 do
    sh "mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1"
  end

  task :viewconfig do
    sh "mdadm --"
  end

  task :incsync do
    sh "sysctl -w dev.raid.speed_limit_max=100000"
    sh "sysctl -w dev.raid.speed_limit_min=20000"
  end

  task :checkstatus do
    sh "cat /proc/mdstat"
  end
end