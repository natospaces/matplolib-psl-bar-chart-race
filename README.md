# matplolib-psl-bar-chart-race

<p>A matplolib based bar chart race by goals scored from either beginning of 2009 season or the year 2010 for South Africa's Premier Soccer League Clubs</p>


Click on the picture below to see the chart animation(data filtered by beginning of season 2009-2010 to end of 2019)

[![Watch the video](http://www.xhosanostra.co.za/izinto/barcharac.GIF)](https://www.youtube.com/watch?v=IgaGzYMjc_s)

<b>bcrseason2009.sql</b> - sql file that prepares the data from match results to a format with running goals counts, filtering either by beginning of season 2009 or 2010 calendar year

<b>diskistats.xlsx</b> - raw data including both the processed data in excel format

<b>diskistats_season2009.csv</b> - data file used by pls_bar_chart_race_2020.py to create the bar chart race, data filtered by beginning of season 2009-2010 to end of 2019

<b>diskistats_calendar2010.csv</b> - data file used by pls_bar_chart_race_2020.py to create the bar chart race, data filtered by beginning of year 2010 to end of 2019

<b>pls_bar_chart_race_2020.py</b> - creates the chart animation using matplolib, code sourced from 
[Gabriel Berardi](https://github.com/6berardi/racingbarchart/) and [PratapVardhan](https://github.com/6berardi/racingbarchart/)
<br>also note FFMpegWriter saving is windows 10 based, might be different for a Mac and Linux, it is assumed the data files are in the data subdirectory



The background music added using openshot and audacity.


