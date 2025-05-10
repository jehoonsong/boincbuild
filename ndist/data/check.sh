#172.30.1.41     baby1.nx baby1
#172.30.1.117    baby2.nx baby2
#172.30.1.102    baby3.nx baby3
#172.30.1.104    baby4.nx baby4

boinccmd --host 172.30.1.41 --passwd 123 --project http://219.254.89.60:8089/ndist update
boinccmd --host 172.30.1.117 --passwd 123 --project http://219.254.89.60:8089/ndist update
boinccmd --host 172.30.1.102 --passwd 123 --project http://219.254.89.60:8089/ndist update
boinccmd --host 172.30.1.104 --passwd 123 --project http://219.254.89.60:8089/ndist update

