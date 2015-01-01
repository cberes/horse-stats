from db.identifiable import Identifiable
from db.location import Location

class Race(Identifiable):

  def __init__(self, row_id = None, location = None, started = None, number = None,
                     purse = None, gait = None, race_class = None,
                     conditions = None, distance = None, temp = None, allow = None):
    super(Race, self).__init__(row_id)
    self.location = location
    self.started = started
    self.number = number
    self.purse = purse
    self.gait = gait
    self.race_class = race_class
    self.conditions = conditions
    self.distance = distance
    self.temp = temp
    self.allow = allow

  def get_insert_sql(self):
    return """INSERT INTO race
(location_id, race_number, started, purse, gait, race_class, conditions, distance, temp, allow)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""

  def get_insert_values(self):
    return (self.location.get_identity(), self.number, self.started, self.purse,
            self.gait, self.race_class, self.conditions, self.distance,
            self.temp, self.allow)

  def get_search_sql(self):
    return """SELECT _id FROM race
WHERE location_id = ? AND started = ? AND race_number = ?
LIMIT 1"""

  def get_search_values(self):
    return (self.location.get_identity(), self.started, self.number)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

