#!/bin/bash
#
# installs from inside /scripts/ folder
#
# activeservices,
# allpackages,
# allservices,
# hostip,
# matrix,
# makewebserver
# systemctlenabled,
# temp,
# usergrp,
#
#
echo "This will set permissions and install (x9) scripts in /bin/"
echo "activeservices\n allpackages\n allservices\n hostip\n matrix\n makewebserver\n systemctlenabled\n temp\n usergrp\n "
echo "----------------------------------------------------"
sudo chmod u+rwx,g+rwx,o+r activeservices.list allpackages.list allservices.list hostip.list matrix.sh makewebserver systemctlenabled.list temp.sh usergrp.list
sudo ln -s ~/scripts/activeservices.list /bin/activeservices && sudo ln -s ~/scripts/allpackages.list /bin/allpackages && sudo ln -s ~/scripts/allservices.list /bin/allservices && sudo ln -s ~/scripts/hostip.list /bin/hostip && sudo ln -s ~/scripts/matrix.sh /bin/matrix && sudo ln -s ~/scripts/makewebserver /bin/makewebserver && sudo ln -s ~/scripts/systemctlenabled.list /bin/systemctlenabled && sudo ln -s ~/scripts/temp.sh /bin/temp && sudo ln -s ~/scripts/usergrp.list /bin/usergrp
echo "All scripts installed"