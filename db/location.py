from db.identifiable import Identifiable

class Location(Identifiable):

  def __init__(self, row_id = None, name = None):
    super(Location, self).__init__(row_id)
    self.name = name

  def get_name(self):
    return self.name

  def get_insert_sql(self):
    return """INSERT INTO location
(name)
VALUES (?)"""

  def get_insert_values(self):
    return (self.name,)

  def get_search_sql(self):
    return """SELECT _id FROM location
WHERE name = ?
LIMIT 1"""

  def get_search_values(self):
    return (self.name,)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

