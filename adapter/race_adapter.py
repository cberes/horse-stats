from datetime import datetime
from db.race import Race
from db.location import Location

class RaceAdapter:

  def __init__(self, location, race_number, race_date, metadata):
    metadata['Off Time'] = self.parse_time(metadata['Off Time'] if 'Off Time' in metadata else None, race_date)
    if 'Purse' in metadata:
      metadata['Purse'] = self.parse_money(metadata['Purse'])
    if 'Dis' in metadata:
      metadata['Dis'] = self.parse_distance(metadata['Dis'])
    if 'Temp-Allow' in metadata:
      parts = metadata['Temp-Allow'].split('-', 1)
      metadata['Temp'] = int(parts[0])
      metadata['Allow'] = int(parts[1])
    if 'Gait' in metadata:
      metadata['Gait'] = metadata['Gait'][:1] if metadata['Gait'] else None
    if 'Class' in metadata:
      metadata['Class'] = metadata['Class'] if metadata['Class'] else None
    if 'Track Cond' in metadata:
      metadata['Track Cond'] = metadata['Track Cond'] if metadata['Track Cond'] else None

    self.race = Race(location = location, number = race_number,
                     started = metadata['Off Time'],
                     purse = metadata['Purse'] if 'Purse' in metadata else None,
                     gait = metadata['Gait'] if 'Gait' in metadata else None,
                     race_class = metadata['Class'] if 'Class' in metadata else None,
                     distance = metadata['Dis'] if 'Dis' in metadata else None,
                     temp = metadata['Temp'] if 'Temp' in metadata else None,
                     allow = metadata['Allow'] if 'Allow' in metadata else None,
                     conditions = metadata['Track Cond'] if 'Track Cond' in metadata else None)

  def parse_money(self, s):
    return int(round(float(s.strip('$').replace(',', '')) * 100))

  def parse_time(self, s, base_date):
    if s is not None:
      base_time = datetime.strptime(s, "%I:%M %p").time()
      return int(datetime.combine(base_date.date(), base_time).timestamp())
    else:
      return int(race_date.timestamp())

  def parse_distance(self, s):
      parts = s.split(' ', 1)
      if parts[1].lower().rstrip('s') == 'mile':
        return float(parts[0])
      else:
        raise Exception('Unknown distance unit: ' + parts[1])

  def get_race(self):
    return self.race

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

