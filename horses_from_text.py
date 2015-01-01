import sys
import os
import re
from datetime import datetime
from db.location import Location
from adapter.raw_race_data import RawRaceData
from horse_racing_results_loader import HorseRacingResultsLoader

def split_at(s, indices):
  # add len of this line because we want the end of this line!
  bounds = indices + [len(s)]
  # use bounds to split line into columns
  return [s[b:e].strip() for b, e in zip(bounds, bounds[1:])]

def parse_file(filename, location):
  # read the file
  with open(filename, 'r') as textfile:
    data = textfile.readlines()

  # trim every line
  data = [line.replace(chr(3), ' ').replace(chr(160), ' ').strip() for line in data]

  # remove blank lines and headers/footers (start with file path, date, or location name)
  data = filter(lambda x: not (re.match(r'^\s*$', x) or re.match(r'^\s*\d+/\d+/\d{4}\s+', x) or x.startswith('file:///') or x.upper().startswith(location.get_name().upper())), data)

  # group lines by race
  # first item will be race day metadata
  i = 0
  races = [[]]
  for line in data:
    if line.endswith(' RACE'):
      i = i + 1
      races.append([])
    else:
      races[i].append(line)
  metadata = races[0]
  races = races[1:]

  # find the first line where the data ends and remove item
  # then remove that line and the following liness
  # note: first line is not important, second line is irrelevant for now
  for g in range(0, len(races)):
    # find first line where the data ends
    d = {}
    d['other'] = [races[g][0]]
    d['metadata'] = races[g][1]
    d['headers'] = races[g][2]
    del races[g][:3]
    for i in range(0, len(races[g])):
      # there are no blank lines
      if not races[g][i][0].isdigit():
        # use [:i] because end index is exclusive
        d['data'] = [line for line in races[g][:i]]
        # add remaining lines to the 'other' list
        d['other'] = d['other'] + races[g][i:]
        # assign dist to this group
        races[g] = d
        break

  # find where columns begin for each group of lines
  for race in races:
    # start with index 0 in the list because we know a character is there (because lines were trimmed)
    col_indices = [0]
    for line in [race['headers']] + race['data']:
      # get indexes of the string where there is a character after 3 spaces
      col_indices = list(set(col_indices) | set([m.start(0) for m in re.finditer(r'(?<=\s{3})\S', line)]))
    col_indices = sorted(col_indices)

    # split each column at those indexes
    race['headers'] = split_at(race['headers'], col_indices)
    for i in range(0, len(race['data'])):
      race['data'][i] = split_at(race['data'][i], col_indices)

  # the last 2 columns have weird spaces sometimes
  for race in races:
    for line in race['data']:
      size = len(line)
      for i in range(size - 2, size):
        line[i] = re.sub(r'\s+([a-z])', r'\1', line[i])

  # go back and split each race metadata
  for race in races:
    # this is blowing my mind
    # split the line by occurrences of 3 or more spaces, then split by spaces preceded by a colon, finally put all items in the list
    race['metadata'] = [x for x in re.split(r'\s{3,}', race['metadata']) for x in re.split(r'(?<=:)\s+', x.strip(), 1)]
    # strip colons from heads and tails of fields
    race['metadata'] = [x.strip(' :') for x in race['metadata']]

  # strip all cells and remove multiple spaces
  #races = [[[re.sub(r'\s{2,}', ' ', cell) for cell in line] for line in race for race in races]
  for race in races:
    race['headers'] = [re.sub(r'\s{2,}', ' ', cell) for cell in race['headers']]
    race['metadata'] = [re.sub(r'\s{2,}', ' ', cell) for cell in race['metadata']]
    race['other'] = [re.sub(r'\s{2,}', ' ', line) for line in race['other']]
    race['data'] = [[re.sub(r'\s{2,}', ' ', cell) for cell in line] for line in race['data']]
  # do the same for metadata (it was not split into cells)
  metadata = [re.sub(r'\s{2,}', ' ', line) for line in metadata]

  # race date
  race_date = datetime.strptime(metadata[0], "%A, %B %d, %Y")

  # convert to data objects
  return [RawRaceData(race_date, location, race['metadata'], race['headers'], race['data']) for race in races]

# hard-code location
location = Location(int(sys.argv[2]), None)

# create the results data loader
loader = HorseRacingResultsLoader(sys.argv[3])

# get text files in specified folder
root = sys.argv[1]
for f in os.listdir(root):
  if not f.endswith('.txt'):
    continue

  # load results from this file
  filename = os.path.join(root, f)
  raw_data = parse_file(filename, location)
  loader.load(raw_data)
  loader.commit()
  print('Done parsing ' + filename)

# close the loader
loader.close()

