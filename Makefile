matches:
	# run this first
	./match.rb >matches.json

csv:
	# reads matches.json
	./make_csv.rb >power.csv

significance:
	R --quiet --slave --no-save --no-restore-data <significance.r

