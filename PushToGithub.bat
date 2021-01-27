@cd  !cd! 
git add .
git stash
git pull
git stash pop
git commit -m "Update Demo." -a
git push

start /b

pause