-- get: horses who competed in most races at a location
select h._id, h.name, count(*)
from horse h
join entry e on e.horse_id = h._id
join race r on e.race_id = r._id
where r.location_id = 1
group by h._id, h.name
having count(*) > 10
order by count(*) desc

select r._id as race_id,
min(d1._id) as first_driver, min(h1._id) as first_horse, min(t1._id) as first_trainer,
min(d2._id) as second_driver, min(h2._id) as second_horse, min(t2._id) as second_trainer,
min(d3._id) as third_driver, min(h3._id) as third_horse, min(t3._id) as third_trainer
from race r
left outer join entry e1 on e1.race_id = r._id and e1.finish_position = 1
left outer join entry e2 on e2.race_id = r._id and e2.finish_position = 2
left outer join entry e3 on e3.race_id = r._id and e3.finish_position = 3
left outer join horse h1 on h1._id = e1.horse_id
left outer join horse h2 on h2._id = e2.horse_id
left outer join horse h3 on h3._id = e3.horse_id
left outer join person d1 on d1._id = e1.driver_id
left outer join person d2 on d2._id = e2.driver_id
left outer join person d3 on d3._id = e3.driver_id
left outer join person t1 on t1._id = e1.trainer_id
left outer join person t2 on t2._id = e2.trainer_id
left outer join person t3 on t3._id = e3.trainer_id
group by r._id
order by r._id

select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id

select r._id as race_id, COALESCE(b.count, 0) as horse_races, COALESCE(c.count, 0) as driver_races,
d1._id as first_driver, h1._id as first_horse, t1._id as first_trainer,
d2._id as second_driver, h2._id as second_horse, t2._id as second_trainer,
d3._id as third_driver, h3._id as third_horse, t3._id as third_trainer
from race r
left outer join entry e1 on e1.race_id = r._id and e1.finish_position = 1
left outer join entry e2 on e2.race_id = r._id and e2.finish_position = 2
left outer join entry e3 on e3.race_id = r._id and e3.finish_position = 3
left outer join horse h1 on h1._id = e1.horse_id
left outer join horse h2 on h2._id = e2.horse_id
left outer join horse h3 on h3._id = e3.horse_id
left outer join person d1 on d1._id = e1.driver_id
left outer join person d2 on d2._id = e2.driver_id
left outer join person d3 on d3._id = e3.driver_id
left outer join person t1 on t1._id = e1.trainer_id
left outer join person t2 on t2._id = e2.trainer_id
left outer join person t3 on t3._id = e3.trainer_id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) b on b.race_id = r._id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join person d on e.driver_id = d._id
join entry e1 on e1.driver_id = d._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) c on c.race_id = r._id
order by r._id

-- get: driver, trainer, and horse by race and finish position
select min(d._id) as driver_id, min(h._id) as horse_id, min(t._id) as trainer_id
from race r
left outer join entry e on e.race_id = r._id
left outer join horse h on h._id = e.horse_id
left outer join person d on d._id = e.driver_id
left outer join person t on t._id = e.trainer_id
where r._id = ? and e.finish_position = ?
group by r._id
order by r._id

-- get: total count of earlier races by horses by race
select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id

-- get: history for a horse before a race
select e._id as entry_id, r._id as race_id, r.race_number, h._id as horse_id, h.name,
min(e1.time) / 1000.0 as min_time, max(e1.time) / 1000.0 as max_time,
avg(e1.time) / 1000.0 as avg_time, count(e1._id) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
where h._id  = ? -- and r._id = ?
group by e._id, r._id, r.race_number, e.finish_position, e.odds, h._id, h.name
order by r.started

-- get: total count of races in month
select count(*)
from race
where location_id = 1
and strftime('%m', started, 'unixepoch', 'localtime') = '07';

-- get: count of races in month in which horses had at least n previous races
select count(*)
from race r
join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) b on b.race_id = r._id
where b.count > 25
and r.location_id = 1 and r.purse < 700000
and strftime('%m', r.started, 'unixepoch', 'localtime') = '07'

-- get: races I would have won with a 3-horse exacta box based on fastest horses
select r._id as race_id, date(r.started, 'unixepoch', 'localtime') as 'day', r.race_number + 1 as '#',
COALESCE(b.count, 0) as horse_races, COALESCE(c.count, 0) as driver_races,
d1._id as first_driver, h1._id as first_horse, t1._id as first_trainer,
d2._id as second_driver, h2._id as second_horse, t2._id as second_trainer,
d3._id as third_driver, h3._id as third_horse, t3._id as third_trainer
from race r
left outer join entry e1 on e1.race_id = r._id and e1.finish_position = 1
left outer join entry e2 on e2.race_id = r._id and e2.finish_position = 2
left outer join entry e3 on e3.race_id = r._id and e3.finish_position = 3
left outer join horse h1 on h1._id = e1.horse_id
left outer join horse h2 on h2._id = e2.horse_id
left outer join horse h3 on h3._id = e3.horse_id
left outer join person d1 on d1._id = e1.driver_id
left outer join person d2 on d2._id = e2.driver_id
left outer join person d3 on d3._id = e3.driver_id
left outer join person t1 on t1._id = e1.trainer_id
left outer join person t2 on t2._id = e2.trainer_id
left outer join person t3 on t3._id = e3.trainer_id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) b on b.race_id = r._id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join person d on e.driver_id = d._id
join entry e1 on e1.driver_id = d._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) c on c.race_id = r._id
where h1._id in (
select h._id
from race rr
join entry e on e.race_id = rr._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < rr.started
where rr._id = r._id
group by h._id
order by avg(e1.time)
limit 3
) and h2._id in (
select h._id
from race rr
join entry e on e.race_id = rr._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < rr.started
where rr._id = r._id
group by h._id
order by avg(e1.time)
limit 3
)
and r.location_id = 1 and r.purse < 700000
and strftime('%m', r.started, 'unixepoch', 'localtime') = '07'
order by r.started;

-- get: races I would have won with a 3-horse exacta box based on fastest drivers
select r._id as race_id, date(r.started, 'unixepoch', 'localtime') as 'day', r.race_number + 1 as '#',
COALESCE(b.count, 0) as horse_races, COALESCE(c.count, 0) as driver_races,
d1._id as first_driver, h1._id as first_horse, t1._id as first_trainer,
d2._id as second_driver, h2._id as second_horse, t2._id as second_trainer,
d3._id as third_driver, h3._id as third_horse, t3._id as third_trainer
from race r
left outer join entry e1 on e1.race_id = r._id and e1.finish_position = 1
left outer join entry e2 on e2.race_id = r._id and e2.finish_position = 2
left outer join entry e3 on e3.race_id = r._id and e3.finish_position = 3
left outer join horse h1 on h1._id = e1.horse_id
left outer join horse h2 on h2._id = e2.horse_id
left outer join horse h3 on h3._id = e3.horse_id
left outer join person d1 on d1._id = e1.driver_id
left outer join person d2 on d2._id = e2.driver_id
left outer join person d3 on d3._id = e3.driver_id
left outer join person t1 on t1._id = e1.trainer_id
left outer join person t2 on t2._id = e2.trainer_id
left outer join person t3 on t3._id = e3.trainer_id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) b on b.race_id = r._id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join person d on e.driver_id = d._id
join entry e1 on e1.driver_id = d._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) c on c.race_id = r._id
where d1._id in (
select d._id
from race rr
join entry e on e.race_id = rr._id
join person d on e.driver_id = d._id
join entry e1 on e1.driver_id = d._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < rr.started
where rr._id = r._id
group by d._id
order by avg(e1.time)
limit 3
) and d2._id in (
select d._id
from race rr
join entry e on e.race_id = rr._id
join person d on e.driver_id = d._id
join entry e1 on e1.driver_id = d._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < rr.started
where rr._id = r._id
group by d._id
order by avg(e1.time)
limit 3
)
and r.location_id = 1
and strftime('%m', r.started, 'unixepoch', 'localtime') = '07'
order by r.started;

select eee.race_id, eee.horse_id, hat.avg_time - hcbat.avg_time as time_diff
from race rrr
join entry eee on eee.race_id = rrr._id
join (
-- get: horse's average time
select rr._id as race_id, ee.horse_id, avg(ee1.time) / 1000.0 as avg_time
from race rr
join entry ee on ee.race_id = rr._id
join entry ee1 on ee1.horse_id = ee.horse_id and ee1.race_id <> ee.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
group by rr._id, ee.horse_id
) hat on hat.race_id = rrr._id and hat.horse_id = eee.horse_id
join (
-- get: best average time of a horse's competirors for a race
select race_id, horse_id, min(avg_time) as avg_time from (
select rr._id as race_id, ee.horse_id, ee1.horse_id as other_horse_id, avg(ee1.time) / 1000.0 as avg_time
from race rr
join entry ee on ee.race_id = rr._id
join entry ee_o on ee_o.race_id = ee.race_id and ee_o.horse_id <> ee.horse_id
join entry ee1 on ee1.horse_id = ee_o.horse_id and ee1.race_id <> ee_o.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
-- need to group by other horse's ID, otherwise all are averaged together
group by rr._id, ee.horse_id, ee1.horse_id
) z group by race_id, horse_id
) hcbat on hcbat.race_id = rrr._id and hcbat.horse_id = eee.horse_id

-- get: races I would have won with a 3-horse exacta box based differences between a horse's average time and the best average time of its competitors
select r._id as race_id, date(r.started, 'unixepoch', 'localtime') as 'day', r.race_number + 1 as '#',
COALESCE(b.count, 0) as horse_races, COALESCE(c.count, 0) as driver_races,
d1._id as first_driver, h1._id as first_horse, t1._id as first_trainer,
d2._id as second_driver, h2._id as second_horse, t2._id as second_trainer,
d3._id as third_driver, h3._id as third_horse, t3._id as third_trainer
from race r
left outer join entry e1 on e1.race_id = r._id and e1.finish_position = 1
left outer join entry e2 on e2.race_id = r._id and e2.finish_position = 2
left outer join entry e3 on e3.race_id = r._id and e3.finish_position = 3
left outer join horse h1 on h1._id = e1.horse_id
left outer join horse h2 on h2._id = e2.horse_id
left outer join horse h3 on h3._id = e3.horse_id
left outer join person d1 on d1._id = e1.driver_id
left outer join person d2 on d2._id = e2.driver_id
left outer join person d3 on d3._id = e3.driver_id
left outer join person t1 on t1._id = e1.trainer_id
left outer join person t2 on t2._id = e2.trainer_id
left outer join person t3 on t3._id = e3.trainer_id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join horse h on e.horse_id = h._id
join entry e1 on e1.horse_id = h._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) b on b.race_id = r._id
left outer join (select r._id as race_id, count(*) as count
from race r
join entry e on e.race_id = r._id
join person d on e.driver_id = d._id
join entry e1 on e1.driver_id = d._id and e1.race_id <> e.race_id and e1.time not null and e1.time > 0
join race r1 on e1.race_id = r1._id and r1.started < r.started
group by r._id
) c on c.race_id = r._id
where h1._id in (
select eee.horse_id
from race rrr
join entry eee on eee.race_id = rrr._id
join (
-- get: horse's average time
select rr._id as race_id, ee.horse_id, avg(ee1.time) / 1000.0 as avg_time
from race rr
join entry ee on ee.race_id = rr._id
join entry ee1 on ee1.horse_id = ee.horse_id and ee1.race_id <> ee.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
group by rr._id, ee.horse_id
) hat on hat.race_id = rrr._id and hat.horse_id = eee.horse_id
join (
-- get: best average time of a horse's competirors for a race
select race_id, horse_id, min(avg_time) as avg_time from (
select rr._id as race_id, ee.horse_id, ee1.horse_id as other_horse_id, avg(ee1.time) / 1000.0 as avg_time
from race rr
join entry ee on ee.race_id = rr._id
join entry ee_o on ee_o.race_id = ee.race_id and ee_o.horse_id <> ee.horse_id
join entry ee1 on ee1.horse_id = ee_o.horse_id and ee1.race_id <> ee_o.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
-- need to group by other horse's ID, otherwise all are averaged together
group by rr._id, ee.horse_id, ee1.horse_id
) z group by race_id, horse_id
) hcbat on hcbat.race_id = rrr._id and hcbat.horse_id = eee.horse_id
where eee.race_id = r._id
order by hat.avg_time - hcbat.avg_time
limit 3
) and h2._id in (
select eee.horse_id
from race rrr
join entry eee on eee.race_id = rrr._id
join (
-- get: horse's average time
select rr._id as race_id, ee.horse_id, avg(ee1.time) / 1000.0 as avg_time
from race rr
join entry ee on ee.race_id = rr._id
join entry ee1 on ee1.horse_id = ee.horse_id and ee1.race_id <> ee.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
group by rr._id, ee.horse_id
) hat on hat.race_id = rrr._id and hat.horse_id = eee.horse_id
join (
-- get: best average time of a horse's competirors for a race
select race_id, horse_id, min(avg_time) as avg_time from (
select rr._id as race_id, ee.horse_id, ee1.horse_id as other_horse_id, avg(ee1.time) / 1000.0 as avg_time
from race rr
join entry ee on ee.race_id = rr._id
join entry ee_o on ee_o.race_id = ee.race_id and ee_o.horse_id <> ee.horse_id
join entry ee1 on ee1.horse_id = ee_o.horse_id and ee1.race_id <> ee_o.race_id
and ee1.time not null and ee1.time > 0
and ee1.time_last_quarter not null and ee1.time_last_quarter > 0
join race rr1 on ee1.race_id = rr1._id and rr1.started < rr.started
-- need to group by other horse's ID, otherwise all are averaged together
group by rr._id, ee.horse_id, ee1.horse_id
) z group by race_id, horse_id
) hcbat on hcbat.race_id = rrr._id and hcbat.horse_id = eee.horse_id
where eee.race_id = r._id
order by hat.avg_time - hcbat.avg_time
limit 3
)
and r.location_id = 1
and strftime('%m', r.started, 'unixepoch', 'localtime') = '07'
order by r.started;

-- get: for each horse's race, the earliest date/time of the other horse's last win
select race_id, horse_id, min(last_won) as coldest_horse_last_won from (
select e.race_id, e.horse_id, eo.horse_id as other_horse_id, max(r.started) as last_won
from race r
join entry e on e.race_id = r._id
join entry eo on eo.race_id = e.race_id and eo.horse_id <> e.horse_id
join entry e1 on e1.horse_id = eo.horse_id and e1.finish_position = 1
join race r1 on r1._id = e1.race_id and r1.started < r.started
group by e.race_id, e.horse_id, eo.horse_id) z
group by race_id, horse_id

-- get: for each horse's race, the earliest date/time of the other horse's last race
select race_id, horse_id, min(last_raced) as coldest_horse_last_raced from (
select e.race_id, e.horse_id, eo.horse_id as other_horse_id, max(r.started) as last_raced
from race r
join entry e on e.race_id = r._id
join entry eo on eo.race_id = e.race_id and eo.horse_id <> e.horse_id
join entry e1 on e1.horse_id = eo.horse_id
join race r1 on r1._id = e1.race_id and r1.started < r.started
group by e.race_id, e.horse_id, eo.horse_id) z
group by race_id, horse_id

-- get: for each race, average time difference between each horse and the fastest horse in that race
select e_0.race_id, e_0.horse_id, past.count, past.avg_time, past.min_time, past.max_time,
past.avg_time - best.best_time as time_diff, -- zero time_diff means this horse is the fastest for the race, greater values mean slower
-- use subquery to get the "rank" for this row
(select count(*) + 1 from (
select e_r.race_id, e_r.horse_id, avg(e_past.time) as avg_time
from race r_r
join entry e_r on e_r.race_id = r_r._id
join entry e_past on e_past.horse_id = e_r.horse_id and e_past.time is not null and e_past.time > 0
join race r_past on r_past._id = e_past.race_id and r_past.started < r_r.started
group by e_r.race_id, e_r.horse_id) ranks
where ranks.race_id = r_0._id and ranks.avg_time < past.avg_time
) as rank
from race r_0
join entry e_0 on e_0.race_id = r_0._id
-- join on this horse's past races to get its avg_time
join (
select e_1.race_id, e_1.horse_id, count(*) as count,
min(e_past.time) as min_time, max(e_past.time) as max_time, avg(e_past.time) as avg_time
from race r_1
join entry e_1 on e_1.race_id = r_1._id
join entry e_past on e_past.horse_id = e_1.horse_id and e_past.time is not null and e_past.time > 0
join race r_past on r_past._id = e_past.race_id and r_past.started < r_1.started
group by e_1.race_id, e_1.horse_id
) past on past.horse_id = e_0.horse_id and past.race_id = e_0.race_id
-- join to get the fastest horse by average time
join (
select race_id, horse_id, min(avg_time) as best_time from (
select e_1.race_id, e_1.horse_id, avg(e_past.time) as avg_time
from race r_1
join entry e_1 on e_1.race_id = r_1._id
join entry e_past on e_past.horse_id = e_1.horse_id and e_past.time is not null and e_past.time > 0
join race r_past on r_past._id = e_past.race_id and r_past.started < r_1.started
group by e_1.race_id, e_1.horse_id) past_for_best
group by race_id) best on best.race_id = e_0.race_id
where r_0._id = 5

-- get time differences for each horse in each pending race on a day
select e_0.race_id, e_0.horse_id,
date(r_0.scheduled, 'unixepoch', 'localtime') as 'day', r_0.race_number + 1 as 'race', round(r_0.purse / 100.0, 2) as purse,
e_0.horse_number as 'horse', h.name,
past.count, round(past.avg_time / 1000.0, 1) as avg_time, round(past.min_time / 1000.0, 1) as min_time, round(past.max_time / 1000.0, 1) as max_time,
last3.count as count_recent, round(last3.avg_time / 1000.0, 1) as avg_time_recent, round(last3.min_time / 1000.0, 1) as min_time_recent, round(last3.max_time / 1000.0, 1) as max_time_recent,
round((last3.avg_time - past.avg_time) / 1000.0, 1) as trend,
round((past.avg_time - best.best_time) / 1000.0, 1) as time_diff, -- zero time_diff means this horse is the fastest for the race, greater values mean slower
0 as rank
from pending_race r_0
join pending_entry e_0 on e_0.race_id = r_0._id
join horse h on h._id = e_0.horse_id
-- join on this horse's recent past races to get its avg_time
left outer join (
select e_1.race_id, e_1.horse_id, count(*) as count,
min(e_past.time) as min_time, max(e_past.time) as max_time, avg(e_past.time) as avg_time
from pending_race r_1
join pending_entry e_1 on e_1.race_id = r_1._id
join entry e_past on e_past.horse_id = e_1.horse_id and e_past.time is not null and e_past.time > 0
join race r_past on r_past._id = e_past.race_id and r_past.started < r_1.scheduled and (julianday(r_1.scheduled) - julianday(r_past.started)) / 86400.0 < 90.0
group by e_1.race_id, e_1.horse_id
) last3 on last3.horse_id = e_0.horse_id and last3.race_id = e_0.race_id
-- join on this horse's past races to get its avg_time
left outer join (
select e_1.race_id, e_1.horse_id, count(*) as count,
min(e_past.time) as min_time, max(e_past.time) as max_time, avg(e_past.time) as avg_time
from pending_race r_1
join pending_entry e_1 on e_1.race_id = r_1._id
join entry e_past on e_past.horse_id = e_1.horse_id and e_past.time is not null and e_past.time > 0 and e_past.finish_position < 5
join race r_past on r_past._id = e_past.race_id and r_past.started < r_1.scheduled
group by e_1.race_id, e_1.horse_id
) past on past.horse_id = e_0.horse_id and past.race_id = e_0.race_id
-- join to get the fastest horse by average time
left outer join (
select race_id, horse_id, min(avg_time) as best_time from (
select e_1.race_id, e_1.horse_id, avg(e_past.time) as avg_time
from pending_race r_1
join pending_entry e_1 on e_1.race_id = r_1._id
join entry e_past on e_past.horse_id = e_1.horse_id and e_past.time is not null and e_past.time > 0 and e_past.finish_position < 5
join race r_past on r_past._id = e_past.race_id and r_past.started < r_1.scheduled
group by e_1.race_id, e_1.horse_id) past_for_best
group by race_id) best on best.race_id = e_0.race_id
where date(r_0.scheduled, 'unixepoch', 'localtime') = '2015-01-14' and r_0.race_number = 7
order by r_0.scheduled, r_0.race_number, past.avg_time - best.best_time

