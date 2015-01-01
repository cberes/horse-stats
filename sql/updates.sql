--update entry
--set finish_position = 3
--where _id = 94;

-- races where something is missing
select e._id, r.race_number + 1 as 'R#', h.name, e.time, e.time_last_quarter as time_q4, e.finish_position as finish, datetime(r.started, 'unixepoch', 'localtime') as time
from entry e
join race r on e.race_id = r._id
join horse h on e.horse_id = h._id
where (e.time is null or e.time_last_quarter is null or e.finish_position is null)
and r.started > strftime('%s', '2014-07-05 05:00:00')
order by r.started, e.horse_number
