echo $1
echo $2
find . -name "*.h" -or -name "*.m" -or -name "*.mm" |sed -e 's/^/"/g' -e 's/$/"/g'|xargs sed -i.bak -e "s#"$1"#"$2"#g"
