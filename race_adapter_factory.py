from adapter.race_adapter import RaceAdapter
from adapter.race_entry_adapter import RaceEntryAdapter
from db.entry import Entry

class RaceAdapterFactory:

  def create_race_adapter(self, location, race_number, race_date, metadata):
    return RaceAdapter(location, race_number, race_date, metadata)

  def create_race_entry_adapter(self, race, headers, entry_data):
    return RaceEntryAdapter(race, headers, entry_data)

  def get_entry_sql(self):
    return Entry().get_insert_sql()

