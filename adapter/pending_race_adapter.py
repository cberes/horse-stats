from datetime import datetime
from db.pending_race import PendingRace
from db.location import Location
from adapter.race_adapter import RaceAdapter

class PendingRaceAdapter(RaceAdapter):

  def __init__(self, location, race_number, race_date, metadata):
    metadata['Post Time'] = self.parse_time(metadata['Post Time'] if 'Post Time' in metadata else None, race_date)
    if 'Purse' in metadata:
      metadata['Purse'] = self.parse_money(metadata['Purse'])
    if 'Dis' in metadata:
      metadata['Dis'] = self.parse_distance(metadata['Dis'])
    if 'Gait' in metadata:
      metadata['Gait'] = metadata['Gait'][:1] if metadata['Gait'] else None
    if 'Class' in metadata:
      metadata['Class'] = metadata['Class'] if metadata['Class'] else None

    self.race = PendingRace(location = location, number = race_number,
                     scheduled = metadata['Post Time'],
                     purse = metadata['Purse'] if 'Purse' in metadata else None,
                     gait = metadata['Gait'] if 'Gait' in metadata else None,
                     race_class = metadata['Class'] if 'Class' in metadata else None,
                     distance = metadata['Dis'] if 'Dis' in metadata else None)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

