class Identifiable:

  def __init__(self, identity):
    self.identity = identity

  def set_identity(self, identity):
    self.identity = identity

  def get_identity(self):
    return self.identity

  def needs_insert(self):
    return not self.identity

  def get_insert_sql(self):
    pass

  def get_insert_values(self):
    pass

  def get_search_sql(self):
    pass

  def get_search_values(self):
    pass

