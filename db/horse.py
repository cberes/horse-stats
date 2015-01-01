from db.identifiable import Identifiable

class Horse(Identifiable):

  def __init__(self, row_id = None, name = None):
    super(Horse, self).__init__(row_id)
    self.name = name

  def get_insert_sql(self):
    return """INSERT INTO horse
(name)
VALUES (?)"""

  def get_insert_values(self):
    return (self.name,)

  def get_search_sql(self):
    return """SELECT _id, 1 AS priority FROM horse
WHERE name = ?
UNION ALL
SELECT _id, 2 AS priority FROM horse
WHERE replace(name, ' ', '') = replace(?, ' ', '')
ORDER BY priority ASC
LIMIT 1"""

  def get_search_values(self):
    return (self.name, self.name)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

