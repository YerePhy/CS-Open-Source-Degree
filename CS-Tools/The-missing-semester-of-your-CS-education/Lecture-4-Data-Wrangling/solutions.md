## Solutions of Lecture 4

2. Find the number of words (in /usr/share/dict/words) that contain at least three a's and don’t have a 's ending:

```
#/bin/bash

cat /usr/share/dict/words | tr '[:upper:]' '[:lower:]' | grep -E "\b([^a]*a){3}.*\b" | grep -Ev "'s" 
```

What are the three most common last two letters of those words? sed’s y command, or the tr program, may help you with case insensitivity. 

```
#/bin/bash

cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" |  grep -E "\b([^a]*a){3}.*\b" | grep -Ev "'s" | sed -E 's/.+([a-z]{2})/\1/' | sort | uniq -c
```

```
#/bin/bash

cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" |  grep -E "\b([^a]*a){3}.*\b" | grep -Ev "'s" | sed -E 's/.+([a-z]{2})/\1/' | sort | uniq -c | sort -n | tail -3
```

```
#/bin/bash

cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" |  grep -E "\b([^a]*a){2}.*\b" | grep -Ev "'s" | sed -E 's/.+([a-z]{2})/\1/' | sort | uniq -c | sort -n 
```

How many of those two-letter combinations are there?

```
#/bin/bash

cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" |  grep -E "\b([^a]*a){2}.*\b" | grep -Ev "'s" | sed -E 's/.+([a-z]{2})/\1/' | sort | uniq -c | sort -n | wc -l
```

And for a challenge: which combinations do not occur?

```
#/bin/bash

cat /usr/share/dict/words | tr "[:upper:]" "[:lower:]" |  grep -E "\b([^a]*a){3}.*\b" | grep -Ev "'s" | sed -E 's/.+([a-z]{2})/\1/' | sort | uniq > letters 
source ./letters.sh > all_letters 
diff --changed-group-format="%<" --unchanged-group-format="" all_letters letters
```

4. Find your average, median, and max system boot time over the last ten boots. Use journalctl on Linux and log show on macOS, and look for log timestamps near the beginning and end of each boot. On Linux, they may look something like:

```
Logs begin at ...
```

and 

```
systemd[577]: Startup finished in ...
```

On macOS, look for:

```
systemd[577]: Startup finished in ...
```

On macOS, look for:

```
=== system boot:
```

and

```
Previous shutdown cause: 5
```

```
See solution to Exercise 5
```

5. Look for boot messages that are not shared between your past three reboots (see journalctl’s -b flag). Break this task down into multiple steps. First, find a way to get just the logs from the past three boots. There may be an applicable flag on the tool you use to extract the boot logs, or you can use sed '0,/STRING/d' to remove all lines previous to one that matches STRING. Next, remove any parts of the line that always varies (like the timestamp). Then, de-duplicate the input lines and keep a count of each one (uniq is your friend). And finally, eliminate any line whose count is 3 (since it was shared among all the boots).

```
#/bin/bash

journalctl | grep -E 'Startup finished in (\w\.?)+ \(kernel\) \+' | tail -n 10 | sed -E 's/(.*) = (.*s)\./\2/g' | awk '{if ($0 ~ /^(.*)min (.*)s$/) {print (60 * $1) + $2} else {gsub("s", "", $0); print $0}}' | R --slave -e 'x <- scan(file="stdin", quiet=TRUE); summary(x)'
```

6. Find an online data set like this one, this one, or maybe one from here. Fetch it using curl and extract out just two columns of numerical data. If you’re fetching HTML data, pup might be helpful. For JSON data, try jq. Find the min and max of one column in a single command, and the difference of the sum of each column in another.

```
#!/bin/bash

awk 'FNR==NR{f1[FNR]=$0; next}{if (NF!=0 && f1[FNR]!="") print $0", "f1[FNR]}' \
<(curl -s https://ucr.fbi.gov/crime-in-the-u.s/2016/crime-in-the-u.s.-2016/topic-pages/tables/table-1 | pup --color "div#table-data-container td.group2 text{}") \
<(curl -s https://ucr.fbi.gov/crime-in-the-u.s/2016/crime-in-the-u.s.-2016/topic-pages/tables/table-1 | pup --color "div#table-data-container td.group1 text{}") \
| sed 's/,//g;s/\s$//g;s/\s/,/g' | R --slave -e 'x <- file("stdin"); t <- read.csv(x); summary(t)'
```

