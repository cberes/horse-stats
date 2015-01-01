import sys
import os
import itertools
from lxml import html
from datetime import datetime, date, time
from db.location import Location
from adapter.raw_race_data import RawRaceData
from horse_racing_results_loader import HorseRacingResultsLoader
from pending_race_adapter_factory import PendingRaceAdapterFactory

def parse_file(filename, location):
  # read the file
  with open(filename, 'r') as htmlfile:
    page = htmlfile.read()
  tree = html.fromstring(page)

  # all items for this day will start with this prefix
  xpath_start = '//div[@id = "innerContent"]/div[1]'

  # race date
  date_tag = tree.xpath(xpath_start + '//font[1]//text()[2]')
  race_date = datetime.strptime(date_tag[0], "%A, %B %d, %Y")

  # race time
  time_tag = tree.xpath(xpath_start + '//span[1]//text()')[0].strip().split(chr(160))

  raw_data = []
  race_count = int(tree.xpath('count(' + xpath_start + '/table)'))
  for i in range(1, race_count + 1):
    # all items for this race will start with this prefix
    xpath_start_item = xpath_start + '/table[' +  str(i) + ']'

    # race metadata
    metadata = tree.xpath(xpath_start_item + '//table[2]//tr[1]//td//text()') + time_tag
    # strip colons from heads and tails of fields
    metadata = [x.strip(' :') for x in metadata]

    # entry headers
    entry_headers = tree.xpath(xpath_start_item + '//table[3]//tr[1]//td//text()')
    entry_headers = [x.strip(' :') for x in entry_headers]

    # entry data
    entry_data = []
    entry_count = int(tree.xpath('count(' + xpath_start_item + '//table[3]//tr)'))
    for j in range(2, entry_count + 1):
      # cannot use text() because empty text elements are not included
      # so get the elements containing text and use the text property
      # maybe there is better way?
      xpath_start_subitem = xpath_start_item + '//table[3]//tr[' + str(j) + ']//td'
      entry_datum = tree.xpath(xpath_start_subitem + '/span|' + xpath_start_subitem + '/p')
      entry_datum = [x.text.strip() if x.text is not None else '' for x in entry_datum]
      entry_data.append(entry_datum)

    # convert to data objects
    raw_data.append(RawRaceData(race_date, location, metadata, entry_headers, entry_data))

  # return data for the race
  return raw_data

# hard-code location
location = Location(int(sys.argv[2]), None)

# create the results data loader
loader = HorseRacingResultsLoader(sys.argv[3])
loader.set_race_adapter_factory(PendingRaceAdapterFactory())

# get html files in specified folder
root = sys.argv[1]
for f in os.listdir(root):
  if not f.endswith('.html'):
    continue

  # load results from this file
  filename = os.path.join(root, f)
  raw_data = parse_file(filename, location)
  loader.load(raw_data)
  loader.commit()
  print('Done parsing ' + filename)

# close the loader
loader.close()

