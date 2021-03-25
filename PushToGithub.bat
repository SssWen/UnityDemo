@cd  !cd! 
git add .
git stash
git pull
git stash pop
git commit -m "Auto Update." -a
git push

start /b

pause