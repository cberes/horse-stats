from race_adapter_factory import RaceAdapterFactory
from adapter.pending_race_adapter import PendingRaceAdapter
from adapter.pending_race_entry_adapter import PendingRaceEntryAdapter
from db.pending_entry import PendingEntry

class PendingRaceAdapterFactory(RaceAdapterFactory):

  def create_race_adapter(self, location, race_number, race_date, metadata):
    return PendingRaceAdapter(location, race_number, race_date, metadata)

  def create_race_entry_adapter(self, race, headers, entry_data):
    return PendingRaceEntryAdapter(race, headers, entry_data)

  def get_entry_sql(self):
    return PendingEntry().get_insert_sql()

