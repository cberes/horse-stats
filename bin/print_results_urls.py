import sys
import requests
from lxml import html

# domain
root_url = sys.argv[1]

# get year and month, convert to int for some validation
year = int(sys.argv[2])
months = [int(a) for a in sys.argv[3:]]

# read calendar
for month in months:
  page_url = root_url + '/index.php/tools/packages/simple_calendar/show_the_month.php?whichAttributes=|results|&underPageCID=620&whichMonth={:d}/1/{:d}&bID=3376'.format(month, year)
  page = requests.get(page_url)
  tree = html.fromstring(page.text)

  # get links
  links = tree.xpath('//table//td//a/@href')
  urls = [root_url + link for link in links]
  for url in urls:
    print(url)
