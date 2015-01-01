--
-- average time of race entries
--

create view horse_avg_time as
select e._id, r._id as race_id, r.race_number, h._id as horse_id, h.name,
min(e1.time) / 1000.0 as min_time, max(e1.time) / 1000.0 as max_time,
avg(e1.time) / 1000.0 as avg_time, count(e1._id) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
left outer join entry e1 on e1.horse_id = h._id and e1.time not null and e1.time > 0
left outer join race r1 on e1.race_id = r1._id and r1._id <> r._id and r1.started < r.started
group by e._id, r._id, r.race_number, e.finish_position, e.odds, h._id, h.name;

create view horse_avg_time_q4 as
select e._id, r._id as race_id, r.race_number, h._id as horse_id, h.name,
min(e1.time_last_quarter) / 1000.0 as min_time, max(e1.time_last_quarter) / 1000.0 as max_time,
avg(e1.time_last_quarter) / 1000.0 as avg_time, count(e1._id) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
left outer join entry e1 on e1.horse_id = h._id and e1.time not null and e1.time > 0
left outer join race r1 on e1.race_id = r1._id and r1._id <> r._id and r1.started < r.started
group by e._id, r._id, r.race_number, e.finish_position, e.odds, h._id, h.name;

create view horse_disqual as
select e._id, r._id as race_id, r.race_number, h._id as horse_id, h.name, count(e1._id) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
left outer join entry e1 on e1.horse_id = h._id and (e1.time is null or e1.time = 0)
left outer join race r1 on e1.race_id = r1._id and r1._id <> r._id and r1.started < r.started
group by e._id, r._id, r.race_number, e.finish_position, e.odds, h._id, h.name;

create view driver_avg_time as
select e._id, r._id as race_id, r.race_number, d._id as driver_id, d.firstname || ' ' || d.lastname as name,
min(e1.time) / 1000.0 as min_time, max(e1.time) / 1000.0 as max_time,
avg(e1.time) / 1000.0 as avg_time, count(e1._id) as count
from race r
join entry e on e.race_id = r._id
join person d on e.driver_id = d._id
left outer join entry e1 on e1.driver_id = d._id and e1.time not null and e1.time > 0
left outer join race r1 on e1.race_id = r1._id and r1._id <> r._id and r1.started < r.started
group by e._id, r._id, r.race_number, e.finish_position, e.odds, d._id, d.firstname, d.lastname;

create view driver_avg_time_q4 as
select e._id, r._id as race_id, r.race_number, d._id as driver_id, d.firstname || ' ' || d.lastname as name,
min(e1.time_last_quarter) / 1000.0 as min_time, max(e1.time_last_quarter) / 1000.0 as max_time,
avg(e1.time_last_quarter) / 1000.0 as avg_time, count(e1._id) as count
from race r
join entry e on e.race_id = r._id
join person d on e.driver_id = d._id
left outer join entry e1 on e1.driver_id = d._id and e1.time not null and e1.time > 0
left outer join race r1 on e1.race_id = r1._id and r1._id <> r._id and r1.started < r.started
group by e._id, r._id, r.race_number, e.finish_position, e.odds, d._id, d.firstname, d.lastname;

create view driver_disqual as
select e._id, r._id as race_id, r.race_number, d._id as driver_id, d.firstname || ' ' || d.lastname as name, count(e1._id) as count
from race r
join entry e on e.race_id = r._id
join person d on e.driver_id = d._id
left outer join entry e1 on e1.driver_id = d._id and (e1.time is null or e1.time = 0)
left outer join race r1 on e1.race_id = r1._id and r1._id <> r._id and r1.started < r.started
group by e._id, r._id, r.race_number, e.finish_position, e.odds, d._id, d.firstname, d.lastname;

