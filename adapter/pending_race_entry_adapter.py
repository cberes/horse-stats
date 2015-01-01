import re
from db.pending_entry import PendingEntry
from adapter.race_entry_adapter import RaceEntryAdapter

class PendingRaceEntryAdapter(RaceEntryAdapter):

  def __init__(self, race, headers, data):
    self.fail_if_bad_data_size(headers, data)

    number = self.parse_int(data[headers.index('HN')]) if 'HN' in headers else None
    post_position = self.text_or_none(data[headers.index('PP')]) if 'PP' in headers else None
    odds = self.parse_odds(data[headers.index('Odds')]) if 'Odds' in headers else None
    meds = self.text_or_none(data[headers.index('Meds')]) if 'Meds' in headers else None
    claiming = self.parse_money(data[headers.index('Claiming')]) if 'Claiming' in headers else None
    self.horse = self.parse_horse(data[headers.index('Horse')] if 'Horse' in headers else None)
    self.driver = self.parse_person(data[headers.index('Driver')] if 'Driver' in headers else None)
    self.trainer = self.parse_person(data[headers.index('Trainer')] if 'Trainer' in headers else None)

    self.entry = PendingEntry(race = race, horse = self.horse, driver = self.driver,
                              trainer = self.trainer, horse_number = number,
                              post_position = post_position, claiming = claiming,
                              odds = odds, meds = meds)

  def parse_money(self, s):
    return int(round(float(s.strip('$').replace(',', '')) * 100)) if s else None

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

