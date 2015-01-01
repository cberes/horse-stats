import re
from db.entry import Entry
from db.horse import Horse
from db.person import Person

class RaceEntryAdapter:

  def __init__(self, race, headers, data):
    self.fail_if_bad_data_size(headers, data)

    number = self.parse_int(data[headers.index('HN')]) if 'HN' in headers else None
    post_position = self.text_or_none(data[headers.index('PP')]) if 'PP' in headers else None
    odds = self.parse_odds(data[headers.index('Odds')]) if 'Odds' in headers else None
    time = self.parse_time(data[headers.index('Time')]) if 'Time' in headers else None
    timeq4 = self.parse_time(data[headers.index('Last Q')]) if 'Last Q' in headers else None
    meds = self.text_or_none(data[headers.index('Meds')]) if 'Meds' in headers else None
    self.horse = self.parse_horse(data[headers.index('Horse')] if 'Horse' in headers else None)
    self.driver = self.parse_person(data[headers.index('Driver')] if 'Driver' in headers else None)
    self.trainer = self.parse_person(data[headers.index('Trainer')] if 'Trainer' in headers else None)

    finish_position = None
    if 'FIN' in headers:
      # there might be a dash and then some junk after the finish position
      parts = data[headers.index('FIN')].split('-', 1)
      # can be '8p7', 'x7', or 'be7'
      # split by any letters
      parts = re.split(r'[^\d]+', parts[0], 1)
      # prefer the latter part
      if len(parts) == 2 and parts[1].isdigit():
        finish_position = int(parts[1])
      elif parts[0].isdigit():
        finish_position = int(parts[0])

    self.entry = Entry(race = race, horse = self.horse, driver = self.driver,
                       trainer = self.trainer, horse_number = number,
                       post_position = post_position,
                       finish_position = finish_position, time = time,
                       time_last_quarter = timeq4, odds = odds, meds = meds)

  def fail_if_bad_data_size(self, headers, data):
    if len(headers) != len(data):
      raise Exception('Data size ' + str(len(data)) + ' does not match headers size ' + str(len(headers)))

  def parse_int(self, s):
    return int(re.sub(r'[^\d]+', '', s))

  def parse_time(self, s):
    # filter out other junk
    s = re.sub(r'[^\d:.]+', '', s)
    if not s:
      return None

    # could be mm:ss.fff or ss.fff
    parts = s.split(':', 1)
    if len(parts) != 2:
      return int(round(float(parts[0]) * 1000))
    else:
      return (int(parts[0]) * 60000) + int(round(float(parts[1]) * 1000))

  def parse_odds(self, s):
    try:
      return float(s.strip('E*'))
    except ValueError:
      return None

  def parse_horse(self, s):
    return Horse(name = s) if s else None

  def parse_person(self, s):
    if s and s.upper() != 'TBA':
      parts = s.split(' ', 1)
      return Person(firstname = parts[0], lastname = parts[1])
    else:
      return None

  def text_or_none(self, s):
    return s if s else None

  def get_horse(self):
    return self.horse

  def get_driver(self):
    return self.driver

  def get_trainer(self):
    return self.trainer

  def get_entry(self):
    return self.entry

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

