from db.identifiable import Identifiable
from db.race import Race
from db.horse import Horse
from db.person import Person

class PendingEntry(Identifiable):

  def __init__(self, row_id = None, race = None, horse = None, driver = None,
                     trainer = None, horse_number = None, post_position = None,
                     claiming = None, odds = None, meds = None):
    super(PendingEntry, self).__init__(row_id)
    self.race = race
    self.horse = horse
    self.driver = driver
    self.trainer = trainer
    self.horse_number = horse_number
    self.post_position = post_position
    self.claiming = claiming
    self.odds = odds
    self.meds = meds

  def get_insert_sql(self):
    return """INSERT INTO pending_entry
(race_id, horse_id, driver_id, trainer_id, horse_number, post_position, claiming, odds, meds)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"""

  def get_insert_values(self):
    return (self.race.get_identity(), self.horse.get_identity(),
            self.driver.get_identity() if self.driver else None,
            self.trainer.get_identity(), self.horse_number, self.post_position,
            self.claiming, self.odds, self.meds)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

