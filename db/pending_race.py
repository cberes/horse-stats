from db.identifiable import Identifiable
from db.location import Location

class PendingRace(Identifiable):

  def __init__(self, row_id = None, location = None, scheduled = None, number = None,
                     purse = None, gait = None, race_class = None, distance = None):
    super(PendingRace, self).__init__(row_id)
    self.location = location
    self.scheduled = scheduled
    self.number = number
    self.purse = purse
    self.gait = gait
    self.race_class = race_class
    self.distance = distance

  def get_insert_sql(self):
    return """INSERT INTO pending_race
(location_id, race_number, scheduled, purse, gait, race_class, distance)
VALUES (?, ?, ?, ?, ?, ?, ?)"""

  def get_insert_values(self):
    return (self.location.get_identity(), self.number, self.scheduled, self.purse,
            self.gait, self.race_class, self.distance)

  def get_search_sql(self):
    return """SELECT _id FROM pending_race
WHERE location_id = ? AND scheduled = ? AND race_number = ?
LIMIT 1"""

  def get_search_values(self):
    return (self.location.get_identity(), self.scheduled, self.number)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

