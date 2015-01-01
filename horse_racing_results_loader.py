import sys
import itertools
import sqlite3
from datetime import datetime, date, time
from db.location import Location
from db.race import Race
from db.entry import Entry
from db.horse import Horse
from db.person import Person
from adapter.raw_race_data import RawRaceData
from race_adapter_factory import RaceAdapterFactory

class HorseRacingResultsLoader:

  def __init__(self):
    # connect to the database
    self.conn = sqlite3.connect('../../horses.db')
    # other properties
    self.race_adapter_factory = None

  def commit(self):
    # Save (commit) the changes
    self.conn.commit()

  def close(self):
    # We can also close the connection if we are done with it.
    # Just be sure any changes have been committed or they will be lost.
    self.conn.close()

  # insert an Identifiable
  def insert(self, row):
    if row.needs_insert():
      self.cursor.execute(row.get_insert_sql(), row.get_insert_values())
      row.set_identity(self.cursor.lastrowid)
      return True
    return False

  # look up matching row
  def lookup(self, row):
    if row is None:
      return True
    if row.needs_insert():
      self.cursor.execute(row.get_search_sql(), row.get_search_values())
      found = self.cursor.fetchone()
      if found is not None:
        row.set_identity(found[0])
        return True
    return False

  def set_race_adapter_factory(self, race_adapter_factory):
    self.race_adapter_factory = race_adapter_factory

  def load(self, data):
    if self.race_adapter_factory is None:
      self.race_adapter_factory = RaceAdapterFactory()

    self.cursor = self.conn.cursor()

    race_entries_to_insert = []
    race_number = 0
    for d in data:
      race_number = race_number + 1

      # race metadata
      # https://docs.python.org/3.1/library/itertools.html#recipes
      metadata = dict(itertools.zip_longest(*[iter(d.get_metadata())] * 2, fillvalue=""))
      ra = self.race_adapter_factory.create_race_adapter(d.get_location(), race_number - 1, d.get_race_date(), metadata)
      race = ra.get_race()

      # race entry headers and data
      headers = [x.strip(' :') for x in d.get_headers()]
      entries = [self.race_adapter_factory.create_race_entry_adapter(race, headers, entry_data) for entry_data in d.get_data()]

      # skip to next race if this one is
      if self.lookup(race):
        continue

      # insert race
      self.insert(race)

      # insert race entries
      for entry in entries:
        # insert horse
        if not self.lookup(entry.get_horse()):
          self.insert(entry.get_horse())
        # insert driver
        if not self.lookup(entry.get_driver()):
          self.insert(entry.get_driver())
        # insert trainer
        if not self.lookup(entry.get_trainer()):
          self.insert(entry.get_trainer())
        # add values to insert entry rows in one batch later
        race_entries_to_insert.append(entry.get_entry().get_insert_values())

    # insert race entries in a single batch
    self.cursor.executemany(self.race_adapter_factory.get_entry_sql(), race_entries_to_insert)

