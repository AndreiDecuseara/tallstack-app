#!/bin/bash

GREEN='\033[1;32m';
YELLOW='\033[1;33m';
ORANGE='\033[0;33m';
RED='\033[0;31m';

# var declaration
pr_name='';
db_name='';
db_username='';
db_password='';
# screen 1
while [[ $pr_name == '' ]] || [[ $db_name == '' ]] || [[ $db_username == '' ]]
do
     dataform=`
     zenity --forms --title="Create new project" \
          --text="Let's get started with the basics" \
          --separator=$'\034'\
          --add-entry="Project name 🧐"\
          --add-entry="Database name 🗄️"\
          --add-entry="Database username 👤️"\
          --add-password="Database password 🔑️"\
          --width 500
     `
     case $? in
         0) IFS=$'\034' read -r pr_name db_name db_username db_password <<< "$dataform"
	 	echo "Project name: `echo $pr_name | cut -d'|' -f1`"
	 	echo "Database name : `echo $db_name | cut -d'|' -f2`"
          echo "Database username : `echo $db_username | cut -d'|' -f3`"
          echo "Database password : `echo $db_password | cut -d'|' -f4`"
		;;
         1)
                echo "Stop login."; exit 1;;
        -1)
                echo "An unexpected error has occurred."; exit -1;;
     esac
     pr_name=${pr_name//' '/'-'};
     pr_name=${pr_name//'_'/'-'};
     echo $pr_name;
     if  [[ $pr_name == '' ]] 
     then
          error_pr_name='<span color=\"orange\"><b>Project Name</b></span> is required! \n';
     else
          error_pr_name='';
     fi

     if  [[ $db_name == '' ]] 
     then
          error_db_name='<span color=\"orange\"><b>Database Name</b></span> is required! \n';
     else
          error_db_name='';
     fi

     if  [[ $db_username == '' ]] 
     then
          error_db_username='<span color=\"orange\"><b>Database Username</b></span> is required! \n';
     else
          error_db_username='';
     fi

     if  [[ $pr_name == '' ]] || [[ $db_name == '' ]] || [[ $db_username == '' ]]
     then
          zenity    --warning \
                    --text="$error_pr_name$error_db_name$error_db_username"\
                    --width 500
     fi
done

#ecran 2 select file
FILE=`zenity  --file-selection --title="Where do you want to create the project?" --directory`

case $? in
         0)
                echo "\"$FILE\" selected.";;
         1)
                echo "No file selected.";;
        -1)
                echo "An unexpected error has occurred.";;
esac

# info state 
zenity --info \
--extra-button "Buy PRO" \
--title "Free Version" \
--width 500 \
--text "<span color=\"orange\"><b>What you get in free version: </b></span>\n
1. Setup and create new project
2. Install TALL Stack (Laravel, Tailwind, AlpineJs, Livewire) and jQuery
3. Create optimization and install Laravel Mix. Run all npm commands
4. Create optimized file structure ready to be used in a new TALL Stack application
5. Create Livewire example, instead of Laravel
6. Create new TALL Stack start page with all the required resources
7. Use your latest Node version, changed automatically from script
8. Auto-open browser on your new TALL Stack project when setup is complete
9. Create all you need for auth (Login, Reset, Register)
10. Install Backpack for admin panel

 <span color=\"green\"><b>What you can get in PRO version (comming soon): </b></span>\n
1. Components
2. Fully automated install of enviorment
3. Themes Templates 
4. Payments methods
5. Multiple screens for a complete web application
 " 

case $? in
     1) google-chrome updivision.com ; exit 1;;
    -1) echo "some error occurred"; exit -1 ;;
esac

datachecklist=$(
zenity --list --checklist --title="Options"\
    --text="Please select whether you want the script to also install the following features:"\
    --separator=$'\034'\
    --column="Install"\
    --column="Feature"\
    --column="Description"\
    --width 500 \
    False backpack "Installs the Backpack admin panel builder"\
    False authentication "Creates full auth with Login, Reset, Register"\
)

case $? in
     1) echo "you cancelled"; exit 1 ;;
    -1) echo "some error occurred"; exit -1 ;;
     0) IFS=$'\034' read -r var1 var2 <<< "$datachecklist" ;;
esac
(
#----------logic of the script-----------
echo "# Starting ..." ;
source ~/.nvm/nvm.sh
nvm use node  
# create new laravel application
echo "# Create Laravel project" ;
cd /$FILE/

#check if dir already exists 

if [ -d "$pr_name" ]; then
  # Take action if $DIR exists. #
  zenity    --warning \
                    --text="The name of the project <b>$pr_name</b> already exists in this directory!"\
                    --width 500
    case $? in
         1) exit -1 ;;
        -1) echo "some error occurred"; exit -1 ;;
         0) exit -1 ;;
    esac
fi
composer create-project laravel/laravel $pr_name

# go to root
cd $pr_name
echo -e "${GREEN}Laravel was installed! 🦄"
echo "# Laravel was installed! 🦄" ;
echo "30"

sed -i 's/DB_DATABASE=laravel/DB_DATABASE='$db_name'/' .env
sed -i 's/DB_USERNAME=root/DB_USERNAME='$db_username'/' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD='$db_password'/' .env


# composer install and setup
echo "# Installing Livewire... "
composer require livewire/livewire
 echo "35"
 echo "# Installing Laravel/UI..."
composer require laravel/ui
 echo "45"

#setup the project with node packages
echo "# Set up the project with Node packages (saves you ≈2 hrs of setup time)";
npm install
echo "# Installing jQuery...";
npm install jquery
echo "50"
echo "# Installing Alpine.js...";
npm install alpinejs
echo "55"
echo "# Installing Tailwind...";
npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
echo "65"

# tallstack optimisations
echo "# Pulling the package optimizations & creating app layout (saves you ≈5 hrs of setup time)";
composer require andreidecuseara/tallstack
php artisan ui tallstack
echo "70"


case $var1 in
     'backpack') 
          echo "# Installing Backpack for Laravel...";
          php artisan migrate:fresh
          composer require backpack/crud:"4.1.*"; 
          composer require --dev backpack/generators; 
          echo -ne '\n' | php artisan backpack:install;;
     'authentication') echo "# Adding full auth (saves you ≈8 hrs of setup time)"; sleep 2;
                              php artisan ui tallstack --auth;;
esac
echo "80"

case $var2 in
     'authentication') 
          echo "# Adding full auth (saves you ≈8 hrs of setup time)"; sleep 2; 
                php artisan ui tallstack --auth;;
esac
echo "90"
# run optimisation and the project
 echo "# Running optimizations & preparing project for development (saves you ≈2 hrs of setup time)"; sleep 2;
npm run development

google-chrome $pr_name.'test'

echo "# Build something amazing! Your project is ready! (20h saved)"
echo -e "${GREEN}Build something amazing! 👨‍💻️"
) |
zenity --progress \
  --title="Your app is building!" \
  --text="Start..." \
  --width 500 \
  --percentage=0

  if [ "$?" = -1 ] ; then
        zenity --error \
          --text="Create canceled."
fi
