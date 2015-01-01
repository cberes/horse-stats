class RawRaceData:

  def __init__(self, race_date, location, metadata, headers, data):
    self.race_date = race_date
    self.location = location
    self.metadata = metadata
    self.headers = headers
    self.data = data

  def get_race_date(self):
    return self.race_date

  def get_location(self):
    return self.location

  def get_metadata(self):
    return self.metadata

  def get_headers(self):
    return self.headers

  def get_data(self):
    return self.data

