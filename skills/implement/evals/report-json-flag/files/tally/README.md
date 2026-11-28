# tally

Timesheet reports. Each line of a timesheet CSV is `date,project,hours`.

    python3 -m tally report hours.csv

prints the hours per project, largest first, and the total. Run the tests with
`python3 -m unittest discover -s tests -t .`.
