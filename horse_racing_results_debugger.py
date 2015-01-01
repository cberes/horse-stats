import sys
import itertools
import sqlite3
from datetime import datetime, date, time
from db.location import Location
from db.race import Race
from db.entry import Entry
from db.horse import Horse
from db.person import Person
from adapter.race_adapter import RaceAdapter
from adapter.race_entry_adapter import RaceEntryAdapter
from adapter.raw_race_data import RawRaceData

class HorseRacingResultsLoader:

  def __init__(self):
    pass

  def commit(self):
    pass

  def close(self):
    pass

  def set_race_adapter_factory(self, race_adapter_factory):
    pass

  def load(self, data):
    for datum in data:
      print('Date', datum.get_race_date())
      print('Location', datum.get_location())
      print('Metadata', datum.get_metadata())
      print('+ ' * 40)
      print(datum.get_headers())
      for row in datum.get_data():
        print(row)
      print('-' * 80)

