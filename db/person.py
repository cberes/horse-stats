from db.identifiable import Identifiable

class Person(Identifiable):

  def __init__(self, row_id = None, firstname = None, middle = None, lastname = None):
    super(Person, self).__init__(row_id)
    self.firstname = firstname
    self.middle = middle
    self.lastname = lastname

  def get_insert_sql(self):
    return """INSERT INTO person
(firstname, middle, lastname)
VALUES (?, ?, ?)"""

  def get_insert_values(self):
    return (self.firstname, self.middle, self.lastname)

  def get_search_sql(self):
    return """SELECT _id, 1 AS priority FROM person
WHERE firstname = ? AND lastname = ?
UNION ALL
SELECT _id, 2 AS priority FROM person
WHERE (firstname LIKE ? || '%' OR ? LIKE firstname || '%') AND lastname = ?
ORDER BY priority ASC
LIMIT 1"""

  def get_search_values(self):
    return (self.firstname, self.lastname, self.firstname, self.firstname, self.lastname)

  def __str__(self):
    return str(vars(self))

  def __repr__(self):
    return self.__str__()

