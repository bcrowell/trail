csv:
	# reads matches.json
	./make_csv.rb >power.csv

matches:
	# run this first
	./match.rb >matches.json
