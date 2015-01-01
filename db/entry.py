from db.identifiable import Identifiable
from db.race import Race
from db.horse import Horse
from db.person import Person

class Entry(Identifiable):

  def __init__(self, row_id = None, race = None, horse = None, driver = None,
                     trainer = None, horse_number = None, post_position = None,
                     finish_position = None, time = None, odds = None,
                     time_last_quarter = None, meds = None):
    super(Entry, self).__init__(row_id)
    self.race = race
    self.horse = horse
    self.driver = driver
    self.trainer = trainer
    self.horse_number = horse_number
    self.post_position = post_position
    self.finish_position = finish_position
    self.time = time
    self.time_last_quarter = time_last_quarter
    self.odds = odds
    self.meds = meds

  def get_insert_sql(self):
    return """INSERT INTO entry
(race_id, horse_id, driver_id, trainer_id, horse_number, post_position,
finish_position, time, time_last_quarter, odds, meds)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""

  def get_insert_values(self):
    return (self.race.get_identity(), self.horse.get_identity(),
            self.driver.get_identity(), self.trainer.get_identity(),
            self.horse_number, self.post_position, self.finish_position,
            self.time, self.time_last_quarter, self.odds, self.meds)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

